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

#ifndef NDEBUG
#define DPRINTF(...) fprintf(stderr, __VA_ARGS__)
#else
#define DPRINTF(...)                                                                       \
    do {                                                                                   \
    } while (0)
#endif

unsigned char *output_data;
int output_index;
int input_index;
int bit_index;
int bit_mask;
int diff;
int backtrack;
int bit_size;

void read_bytes(int n, int *delta) {
    input_index += n;
    diff += n;
    if (*delta < diff)
        *delta = diff;
}

void write_byte(int value) {
    output_data[output_index++] = value;
    DPRINTF("[%02x]", value);
    bit_size += 8;
    diff--;
}

void write_bit(int value) {
    if (backtrack) {
        if (value)
            output_data[output_index - 1] |= 1;
        backtrack = FALSE;
        DPRINTF("%c", value ? 'B' : 'b');
    } else {
        if (!bit_mask) {
            bit_mask = 128;
            bit_index = output_index;
            output_data[output_index++] = 0;
            diff--;
        }
        if (value)
            output_data[bit_index] |= bit_mask;
        bit_mask >>= 1;
        bit_size++;
        DPRINTF("%d", value ? 1 : 0);
    }
}

void write_interlaced_elias_gamma(zx02_state *s, int value) {
    int i;
    if (!value)
        value = 0x100;

    DPRINTF(" EG(%x): ", value);
    for (i = 2; i <= value; i <<= 1)
        ;
    i >>= 1;
    while (i >>= 1) {
        write_bit(!s->elias_ending_bit);
        if (s->elias_short_code && i == 1 && value == 0x100)
            break;
        write_bit(value & i);
    }
    if (!s->elias_short_code || value != 0x100)
        write_bit(!!s->elias_ending_bit);
}

unsigned char *compress(BLOCK *optimal, zx02_state *s, int *output_size, int *delta) {
    BLOCK *prev;
    BLOCK *next;
    int length;
    int optbits = optimal->bits;
    int i;
    int last_offset = s->initial_offset;

    /* calculate and allocate output buffer */
    if (s->zx1_mode) {
        /* we need to add 9 bits for END marker */
        *output_size = (optimal->bits + 9 + 7) / 8;
        optbits = optimal->bits + 9;
    } else {
        /* we need to add 18 bits for END marker */
        *output_size = (optimal->bits + 18 + 7) / 8;
        optbits = optimal->bits + 18;
    }

    output_data = (unsigned char *)malloc(*output_size);
    bit_size = 0;
    if (!output_data) {
        fprintf(stderr, "Error: Insufficient memory\n");
        exit(1);
    }

    /* un-reverse optimal sequence */
    prev = NULL;
    while (optimal) {
        DPRINTF("[%d:%d:%d]->", optimal->index, optimal->offset, optimal->bits);
        next = optimal->chain;
        optimal->chain = prev;
        prev = optimal;
        optimal = next;
    }
    DPRINTF("0\n");

    /* initialize data */
    diff = *output_size - s->input_size + s->skip;
    *delta = 0;
    input_index = s->skip;
    output_index = 0;
    bit_mask = 0;
    backtrack = TRUE;

    /* generate output */
    int last_literal = 0;
    for (optimal = prev->chain; optimal; prev = optimal, optimal = optimal->chain) {
        length = optimal->index - prev->index;

        DPRINTF("\n{%x}:", input_index);
        if (!optimal->offset) {
            /* copy literals indicator */
            DPRINTF("L-");
            write_bit(0);

            /* copy literals length */
            write_interlaced_elias_gamma(s, length);

            DPRINTF(" ");
            /* copy literals values */
            for (i = 0; i < length; i++) {
                write_byte(s->input_data[input_index]);
                read_bytes(1, delta);
            }
            last_literal = 1;
        } else if (optimal->offset == last_offset && last_literal) {
            /* copy from last offset indicator */
            DPRINTF("R-");
            write_bit(0);

            /* copy from last offset length */
            write_interlaced_elias_gamma(s, length);
            read_bytes(length, delta);
            last_literal = 0;
        } else {
            /* copy from new offset indicator */
            DPRINTF("M-");
            write_bit(1);

            if (s->zx1_mode) {
                int off = optimal->offset - 1;
                if( off < 128 )
                    /* copy from new offset LSB */
                    write_byte(off << 1);
                else {
                    /* copy from new offset MSB */
                    write_byte((off >> 7) | 1);
                    DPRINTF(" ");
                    /* copy from new offset LSB */
                    write_byte(off & 255);
                }
            } else {
                /* copy from new offset MSB */
                write_interlaced_elias_gamma(s, (optimal->offset - 1) / 128 + 1);

                /* copy from new offset LSB */
                DPRINTF(" ");
                write_byte(((optimal->offset - 1) % 128) << 1);

                /* copy from new offset length */
                backtrack = TRUE;
            }
            write_interlaced_elias_gamma(s, length - 1);

            read_bytes(length, delta);

            last_offset = optimal->offset;
            last_literal = 0;
        }
    }

    /* end marker */
    DPRINTF("\nbit size data:  %d bits (%d bytes)\n", bit_size, (bit_size + 7) / 8);
    write_bit(1);
    if (s->zx1_mode)
        write_byte(255);
    else
        write_interlaced_elias_gamma(s, 256);

    int real_size = (bit_size + 7) / 8;
    if( real_size != *output_size )
    {
        fprintf(stderr, "WARNING: optimal/real sizes mismatch by %d bytes\n",
                *output_size - real_size);
        *output_size = real_size;
    }
    fprintf(stderr, "bit size data: opt %d bits (%d bytes), real %d bits (%d bytes)\n", optbits, *output_size, bit_size, (bit_size + 7) / 8);
    DPRINTF("\nbit size TOTAL: %d bits (%d bytes)\n", bit_size, (bit_size + 7) / 8);
    /* done! */
    return output_data;
}
