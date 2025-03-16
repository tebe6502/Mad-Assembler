/*
 * (c) Copyright 2021 by Einar Saukas. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of its author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>

#include "zx02.h"

#define MAX_SCALE 50

int offset_ceiling(zx02_state *s, int index) {
    return index > s->offset_limit     ? s->offset_limit
           : index < s->initial_offset ? s->initial_offset
                                       : index;
}

int elias_gamma_bits(zx02_state *s, int value) {
    int bits = 1;
    // Return a really big number to limit range to valid values
    if (value < 1 || value > 0x100)
        return 1024;
    // Optimization: don't send last 2 bits on limit value:
    if (s->elias_short_code && value == 0x100)
        bits = -1;
    while (value >>= 1)
        bits += 2;
    return bits;
}

int elias_gamma_bits_1(zx02_state *s, int value) {
    if (value == 1)
        return elias_gamma_bits(s, 256);
    else if (value > 256)
        return 1024;
    else
        return elias_gamma_bits(s, value - 1);
}

int offset_bits(zx02_state *s, int value) {
    if (s->zx1_mode)
        return (value > 127) ? 17 : 9;
    else
        return 8 + elias_gamma_bits(s, value / 128 + 1);
}

BLOCK *optimize(zx02_state *s) {
    BLOCK **last_literal;
    BLOCK **last_match;
    BLOCK **optimal;
    int *match_length;
    int *best_length;
    int best_length_size;
    int bits;
    int index;
    int offset;
    int length;
    int bits2;
    int dots = 2;

    if (s->initial_offset >= s->input_size)
        s->initial_offset = s->input_size - 1;

    int max_offset = offset_ceiling(s, s->input_size - 1);

    /* allocate all main data structures at once */
    last_literal = (BLOCK **)calloc(max_offset + 1, sizeof(BLOCK *));
    last_match = (BLOCK **)calloc(max_offset + 1, sizeof(BLOCK *));
    optimal = (BLOCK **)calloc(s->input_size, sizeof(BLOCK *));
    match_length = (int *)calloc(max_offset + 1, sizeof(int));
    best_length = (int *)calloc(s->input_size, sizeof(int));
    if (!last_literal || !last_match || !optimal || !match_length || !best_length) {
        fprintf(stderr, "Error: Insufficient memory\n");
        exit(1);
    }
    if (s->input_size > 1)
        best_length[1] = 1;

    /* start with fake block */
    assign(&last_match[s->initial_offset],
           allocate(-1, s->skip - 1, s->initial_offset, NULL));

    printf("[");

    /* process remaining bytes */
    for (index = s->skip; index < s->input_size; index++) {
        best_length_size = 1;
        max_offset = offset_ceiling(s, index);
        for (offset = 1; offset <= max_offset; offset++) {
            /* Check that we have a matching byte at this offset */
            if (index != s->skip && index >= offset &&
                s->input_data[index] == s->input_data[index - offset]) {
                /* copy from last offset, only if code at this offset was a literal */
                if (last_literal[offset]) {
                    length = index - last_literal[offset]->index;
                    bits = last_literal[offset]->bits + 1 + elias_gamma_bits(s, length);
                    assign(&last_match[offset],
                           allocate(bits, index, offset, last_literal[offset]));
                    if (!optimal[index] || optimal[index]->bits > bits)
                        assign(&optimal[index], last_match[offset]);
                }
                /* copy from new offset */
                match_length[offset]++;
                if (best_length_size < match_length[offset]) {
                    bits = optimal[index - best_length[best_length_size]]->bits +
                           elias_gamma_bits_1(s, best_length[best_length_size]);
                    do {
                        best_length_size++;
                        bits2 = optimal[index - best_length_size]->bits +
                                elias_gamma_bits_1(s, best_length_size);
                        if (bits2 <= bits) {
                            best_length[best_length_size] = best_length_size;
                            bits = bits2;
                        } else {
                            best_length[best_length_size] =
                                best_length[best_length_size - 1];
                        }
                    } while (best_length_size < match_length[offset]);
                }
                length = best_length[match_length[offset]];
                bits = optimal[index - length]->bits + offset_bits(s, offset) +
                       elias_gamma_bits_1(s, length);
                if (!last_match[offset] || last_match[offset]->index != index ||
                    last_match[offset]->bits > bits) {
                    assign(&last_match[offset],
                           allocate(bits, index, offset, optimal[index - length]));
                    if (!optimal[index] || optimal[index]->bits > bits)
                        assign(&optimal[index], last_match[offset]);
                }
            } else {
                /* copy literals */
                match_length[offset] = 0;
                if (last_match[offset]) {
                    length = index - last_match[offset]->index;
                    bits = last_match[offset]->bits + 1 + elias_gamma_bits(s, length) +
                           length * 8;
                    assign(&last_literal[offset],
                           allocate(bits, index, 0, last_match[offset]));
                    if (!optimal[index] || optimal[index]->bits > bits)
                        assign(&optimal[index], last_literal[offset]);
                }
            }
        }

        /* indicate progress */
        if (index * MAX_SCALE / s->input_size > dots) {
            printf(".");
            fflush(stdout);
            dots++;
        }
    }

    printf("]\n");

    return optimal[s->input_size - 1];
}
