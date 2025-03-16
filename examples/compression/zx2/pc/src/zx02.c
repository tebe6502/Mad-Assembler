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
#include <string.h>

#include "zx02.h"

#define MAX_OFFSET_ZX02  32640
#define MAX_OFFSET_ZX102 32511
#define MAX_OFFSET_FAST 2176

void reverse(unsigned char *first, unsigned char *last) {
    unsigned char c;

    while (first < last) {
        c = *first;
        *first++ = *last;
        *last-- = c;
    }
}

void print_usage(const char *prog) {
    fprintf(stderr,
            "Usage: %s [-f] [-c] [-b] [-q] input [output.zx02]\n"
            "  -f      Force overwrite of output file\n"
            "  -b      Compress backwards\n"
            "  -s      Use shorted Elias codes\n"
            "  -e      Inverted Elias code end bit\n"
            "  -1      ZX1 offset format\n"
            "  -o <n>  Use 'n' as starting offset\n"
            "  -p <n>  Skip 'n' bytes at input (compress with pre-buffer)\n"
            "  -m <n>  Compress with max offset 'n' bytes\n"
            "  -q      Quick non-optimal compression\n",
            prog);
    exit(1);
}

int main(int argc, char *argv[]) {

    zx02_state *s = calloc(sizeof(zx02_state), 1);

    s->initial_offset = 1;
    s->offset_limit = MAX_OFFSET_ZX02;

    int set_max_offset = 0;
    int force_overwrite = FALSE;
    char *input_name = 0;
    char *output_name = 0;
    unsigned char *output_data;
    FILE *ifp;
    FILE *ofp;
    int output_size;
    int partial_counter;
    int total_counter;
    int delta;
    int i;

    printf("ZX0 v2.2: Optimal data compressor by Einar Saukas\n");

    /* process optional parameters */
    for (i = 1; i < argc; i++) {
        int num;
        const char *arg = argv[i];
        if (*arg == '-') {
            char opt = arg[1];
            switch (opt) {
            case 'f':
                force_overwrite = TRUE;
                break;
            case 'b':
                s->backwards_mode = TRUE;
                break;
            case 's':
                s->elias_short_code = TRUE;
                break;
            case 'e':
                s->elias_ending_bit = TRUE;
                break;
            case 'q':
                s->offset_limit = MAX_OFFSET_FAST;
                break;
            case '1':
                s->zx1_mode = 1;
                if (s->offset_limit > MAX_OFFSET_ZX102)
                    s->offset_limit = MAX_OFFSET_ZX102;
                break;
            case 'o':
            case 'p':
            case 'm':
                if (arg[2] == ':' || arg[2] == '=')
                    num = atoi(arg + 3);
                else if (!arg[2] && i < argc - 1)
                    num = atoi(argv[++i]);
                else {
                    fprintf(stderr, "ERROR: option '-%c' needs integer argument\n", opt);
                    print_usage(argv[0]);
                }
                if (opt == 'o') {
                    s->initial_offset = num;
                } else  if (opt == 'm') {
                    set_max_offset = num;
                } else {
                    if (num < 0) {
                        fprintf(stderr, "ERROR: skipped bytes must be positive.\n");
                        exit(1);
                    }
                    s->skip = num;
                }
                break;
            default:
                if (opt != 'h')
                    fprintf(stderr, "ERROR: unknown option '-%c'\n", opt);
                print_usage(argv[0]);
            }
        } else if (!input_name)
            input_name = argv[i];
        else if (!output_name)
            output_name = argv[i];
        else {
            fprintf(stderr, "ERROR: extra argument '%s'\n", argv[i]);
            print_usage(argv[0]);
        }
    }

    if(set_max_offset) {
        if(set_max_offset > s->offset_limit || set_max_offset < 1) {
            fprintf(stderr, "ERROR: max offset must be between 1 and %d.\n",
                    s->offset_limit);
            exit(1);
        }
        s->offset_limit = set_max_offset;
    }

    if (s->initial_offset < 1 || s->initial_offset > s->offset_limit) {
        fprintf(stderr, "ERROR: initial offset must be between 1 and %d.\n",
                s->offset_limit);
        exit(1);
    }

    if (!input_name) {
        fprintf(stderr, "ERROR: missing input filename\n");
        print_usage(argv[0]);
    }

    /* determine output filename */
    if (!output_name) {
        output_name = (char *)malloc(strlen(input_name) + 6);
        strcpy(output_name, input_name);
        strcat(output_name, ".zx02");
    }

    /* open input file */
    ifp = fopen(input_name, "rb");
    if (!ifp) {
        fprintf(stderr, "ERROER: Cannot access input file %s\n", argv[i]);
        exit(1);
    }
    /* determine input size */
    fseek(ifp, 0L, SEEK_END);
    s->input_size = ftell(ifp);
    fseek(ifp, 0L, SEEK_SET);
    if (!s->input_size) {
        fprintf(stderr, "ERROR: Empty input file %s\n", argv[i]);
        exit(1);
    }

    /* validate skip against input size */
    if (s->skip >= s->input_size) {
        fprintf(stderr, "ERROR: Skipping entire input file %s\n", argv[i]);
        exit(1);
    }

    /* allocate input buffer */
    s->input_data = (unsigned char *)malloc(s->input_size);
    if (!s->input_data) {
        fprintf(stderr, "ERROR: Insufficient memory\n");
        exit(1);
    }

    /* read input file */
    total_counter = 0;
    do {
        partial_counter = fread(s->input_data + total_counter, sizeof(char),
                                s->input_size - total_counter, ifp);
        total_counter += partial_counter;
    } while (partial_counter > 0);

    if (total_counter != s->input_size) {
        fprintf(stderr, "ERROR: Cannot read input file %s\n", argv[i]);
        exit(1);
    }

    /* close input file */
    fclose(ifp);

    /* check output file */
    if (!force_overwrite && fopen(output_name, "rb") != NULL) {
        fprintf(stderr, "ERROR: Already existing output file %s\n", output_name);
        exit(1);
    }

    /* create output file */
    ofp = fopen(output_name, "wb");
    if (!ofp) {
        fprintf(stderr, "ERROR: Cannot create output file %s\n", output_name);
        exit(1);
    }

    /* conditionally reverse input file */
    if (s->backwards_mode)
        reverse(s->input_data, s->input_data + s->input_size - 1);

    /* generate output file */
    BLOCK *optim = optimize(s);
    output_data = compress(optim, s, &output_size, &delta);

    /* conditionally reverse output file */
    if (s->backwards_mode)
        reverse(output_data, output_data + output_size - 1);

    /* write output file */
    if (fwrite(output_data, sizeof(char), output_size, ofp) != output_size) {
        fprintf(stderr, "ERROR: Cannot write output file %s\n", output_name);
        exit(1);
    }

    /* close output file */
    fclose(ofp);

    /* done! */
    printf("File%s compressed%s from %d to %d bytes! (delta %d)\n",
           (s->skip ? " partially" : ""), (s->backwards_mode ? " backwards" : ""),
           s->input_size - s->skip, output_size, delta);

    return 0;
}
