/*
 * De-compressor for ZX02 files
 * ----------------------------
 *
 * (c) 2022 DMSC
 * Code under MIT license, see LICENSE file.
 */

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef NDEBUG
#define DPRINTF(...) fprintf(stderr, __VA_ARGS__)
#else
#define DPRINTF(...)                                                                       \
    do {                                                                                   \
    } while (0)
#endif

// Input / Output buffer size.
// backward mode don't support files bigger than one buffer.
#define BUF_SIZE (1 << 17)
#define BUF_MASK (BUF_SIZE - 1)

struct zx02_state {
    uint8_t bitr;      // bit reserve
    uint8_t extra_bit; // extra bit to inject
    uint16_t offset;   // last offset
    unsigned opos;     // output position
    unsigned epos;     // end output position
    unsigned ipos;     // input position
    unsigned iend;     // input end

    FILE *in;        // input file
    FILE *out;       // output file
    int elias_end;   // bit to end elias code (1 == standard)
    int elias_short; // short Elias codes
    int backward;    // backward encode/decode
    int zx1_mode;    // ZX1 mode
    uint8_t *output; // output data
    uint8_t *input;  // input data
    const char *err; // error message
};

int get_byte(struct zx02_state *s) {
    if (s->ipos == s->iend) {
        if (s->backward || s->ipos != (BUF_SIZE - 1))
            return EOF;
        size_t n = fread(s->input, 1, BUF_SIZE, s->in);
        if (!n)
            return EOF;
        s->iend = n - 1;
    }

    if (s->backward)
        s->ipos = s->ipos - 1;
    else
        s->ipos = s->ipos + 1;

    return s->input[s->ipos];
}

int get_bit(struct zx02_state *s) {
    int bit;
    if (s->extra_bit) {
        bit = s->extra_bit & 1;
        s->extra_bit = 0;
    } else {
        if (s->bitr == 0x80) {
            int c = get_byte(s);
            if (c == EOF) {
                s->err = "truncated input file";
                return 0;
            }
            bit = (c & 0x80) != 0;
            s->bitr = (c << 1) | 1;
        } else {
            bit = (s->bitr & 0x80) != 0;
            s->bitr = (s->bitr << 1);
        }
    }
    return bit;
}

void put_byte(struct zx02_state *s, uint8_t b) {
    s->output[s->opos] = b;
    if (s->backward)
        s->opos = BUF_MASK & (s->opos + BUF_MASK);
    else
        s->opos = BUF_MASK & (s->opos + 1);

    if (s->opos == s->epos) {
        if (!s->backward)
            fwrite(s->output, BUF_SIZE, 1, s->out);
        else
            fprintf(stderr, "output too large for backward mode\n");
    }
}

// Reads interlaced elias code
uint16_t get_elias(struct zx02_state *s) {
    uint16_t ret = 1;
    for (int i = 0; i <= 8; i++) {
        int b = get_bit(s);
        if (b == s->elias_end)
            return ret;

        // Short Elias codes omit last two bits.
        if (s->elias_short && ret == 0x80)
            return 0x100;

        ret = (ret << 1) | get_bit(s);
        if (ret > 0x100) {
            s->err = "unsupported Elias gamma value > 256";
            return 0;
        }
    }
    if (!s->err)
        s->err = "bad elias-gamma value";
    return 0;
}

void decode_literal(struct zx02_state *s) {
    uint16_t len = get_elias(s);
    DPRINTF("%x: lit(%d)\n", s->opos, len);
    if (!len)
        return;
    while (len--) {
        int c = get_byte(s);
        if (c == EOF) {
            s->err = "truncated input file";
            return;
        }
        put_byte(s, c);
    }
}

void decode_match(struct zx02_state *s, int len_add) {
    uint16_t len = get_elias(s) + len_add;
    unsigned pos = s->opos;
    DPRINTF("%x: match(%d, %d)\n", s->opos, len, s->offset);

    if (len > 0x100)
        len = len & 0xFF;

    if (s->backward)
        pos = BUF_MASK & (pos + s->offset + 1);
    else
        pos = BUF_MASK & (pos - s->offset - 1);

    if (!len)
        return;
    while (len--) {
        put_byte(s, s->output[pos]);

        if (s->backward)
            pos = BUF_MASK & (pos + BUF_MASK);
        else
            pos = BUF_MASK & (pos + 1);
    }
}

int decode_offset(struct zx02_state *s) {
    if (s->zx1_mode)
    {
        int off;
        int lsb = get_byte(s);
        if (lsb == EOF) {
            s->err = "truncated input file";
            return 1;
        }
        if (lsb == 255) // Detect ending
            return 1;
        if (lsb & 1) {
            int msb = get_byte(s);
            if (lsb == EOF) {
                s->err = "truncated input file";
                return 1;
            }
            off = ((lsb >> 1) << 8) | msb;
            DPRINTF("offset(%x:%x=%d) ", lsb, msb, off);
        } else {
            off = lsb >> 1;
            DPRINTF("offset(%x=%d) ", lsb, off);
        }
        s->offset = off;
        return 0;
    }
    else
    {
        uint16_t msb = get_elias(s);
        if ((msb & 0xFF) == 0)
            return 1;
        msb = msb - 1;
        int off = get_byte(s);
        if (off == EOF) {
            s->err = "truncated input file";
            return 1;
        }
        DPRINTF("offset(%x:%02x=%d) ", msb, off, (msb << 7) | (off >> 1));
        // las bit in offset LSB is used as next bit to be read:
        s->extra_bit = 2 | (off & 1);
        s->offset = (msb << 7) | (off >> 1);
        return 0;
    }
}

int decode_loop(struct zx02_state *s) {
    int state = 0; // LITERAL
    while (1) {
        switch (state) {
        case 0:
            // Decode literal value:
            decode_literal(s);
            if (s->err)
                return 1;
            if (get_bit(s))
                state = 2;
            else
                state = 1;
            break;
        case 2:
            // Decode new offset:
            if (decode_offset(s))
                return s->err != 0;
            decode_match(s, 1);
            if (s->err)
                return 1;
            if (get_bit(s))
                state = 2;
            else
                state = 0;
            break;
        case 1:
            // Decode repeated offset:
            decode_match(s, 0);
            if (s->err)
                return 1;
            if (get_bit(s))
                state = 2;
            else
                state = 0;
            break;
        }
    }
}

// Decompress file
int decompress(struct zx02_state *s) {
    s->output = calloc(1, BUF_SIZE);
    s->opos = s->backward ? BUF_MASK : 0;
    s->epos = s->opos;
    s->bitr = 0x80;

    // Read "full" input
    s->input = calloc(1, BUF_SIZE);
    size_t ilen = fread(s->input, 1, BUF_SIZE, s->in);
    if (!ilen) {
        free(s->input);
        free(s->output);
        s->err = "empty input file";
        return 1;
    }
    s->ipos = s->backward ? ilen : -1;
    s->iend = s->backward ? 0 : ilen - 1;

    int e = decode_loop(s);

    if (s->opos != s->epos) {
        if (s->backward)
            fwrite(s->output + s->opos + 1, s->epos - s->opos, 1, s->out);
        else
            fwrite(s->output, s->opos, 1, s->out);
    }

    if (s->ipos != s->iend && !e) {
        s->err = "extra bytes at input";
        e = 1;
    }

    free(s->input);
    free(s->output);
    s->input = 0;
    s->output = 0;
    return e;
}

void print_help(const char *name) {
    fprintf(stderr,
            "Usage: %s [options] [input] [output]\n"
            "Options:\n"
            "  -b       backward encoded file\n"
            "  -s       use shorted Elias codes\n"
            "  -e       inverted Elias code end bit\n"
            "  -1       ZX1 offset format\n"
            "  -o <n>   use 'n' as starting offset\n"
            "\n"
            "If no output, write result to stdout.\n"
            "If no input, read from stdin.\n"
            "\n",
            name);
    exit(1);
}

int main(int argc, char **argv) {
    struct zx02_state s;
    memset(&s, 0, sizeof(s));

    const char *in_name = 0, *out_name = 0;

    for (int i = 1; i < argc; i++) {
        char *arg = argv[i];
        if (arg[0] == '-') {
            int c = arg[1];
            if (c == 'b')
                s.backward = 1;
            else if (c == 's')
                s.elias_short = 1;
            else if (c == 'e')
                s.elias_end = 1;
            else if (c == '1')
                s.zx1_mode = 1;
            else if (c == 'o') {
                i++;
                if (i >= argc) {
                    fprintf(stderr, "ERROR: missing value for option -o\n");
                    print_help(argv[0]);
                }
                s.offset = atoi(argv[i]);
            } else if (c == 'h')
                print_help(argv[0]);
            else {
                fprintf(stderr, "ERROR: unknown option -%c\n", c);
                print_help(argv[0]);
            }
        } else if (!in_name)
            in_name = arg;
        else if (!out_name)
            out_name = arg;
        else {
            fprintf(stderr, "ERROR: extra argument '%s'\n", arg);
            print_help(argv[0]);
        }
    }

    s.in = in_name ? fopen(in_name, "rb") : stdin;
    in_name = in_name ? in_name : "(stdin)";

    if (!s.in) {
        fprintf(stderr, "%s: can't open file - %s\n", in_name, strerror(errno));
        return 1;
    }

    s.out = out_name ? fopen(out_name, "wb") : stdout;
    out_name = out_name ? out_name : "(stdout)";

    if (!s.out) {
        fprintf(stderr, "%s: can't open output file - %s\n", out_name, strerror(errno));
        return 1;
    }

    if (decompress(&s)) {
        fprintf(stderr, "%s: error decoding - %s\n", in_name, s.err);
        return 1;
    }

    return 0;
}
