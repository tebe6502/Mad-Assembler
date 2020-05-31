#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include <assert.h>

typedef enum {
	false,
	true
} bool;

#define USE_LITERAL_RUNS   1
#define VERIFY_COST_MODEL  0
#define DEFAULT_LENGTHS    "3/6/8/10:4/7/10/13"

enum {
	RUN_LIMIT = 0x100,
	OFFSET_LENGTH_LIMIT = 15
};

static const char decruncher[] = {
0x01,0x08,0x0b,0x08,0x39,0x05,0x9e,0x32,0x30,0x36,0x31,0x00,0x00,0x00,0x78,0xe6,
0x01,0xa2,0xff,0x9a,0xe8,0xbd,0x37,0x08,0x9d,0xc2,0x00,0xe8,0xd0,0xf7,0xa0,0x01,
0xca,0xbd,0x1a,0x08,0x9d,0x00,0xff,0x8a,0xd0,0xf6,0xce,0x22,0x08,0xce,0x25,0x08,
0x88,0xd0,0xed,0xa2,0x1a,0x4c,0xc6,0x00,0x00,0x00,0x00,0x00,0x38,0x20,0x8e,0x01,
0xd0,0x06,0x90,0x02,0xe6,0xfc,0x06,0xc4,0x90,0x3a,0xf0,0xf1,0xa9,0x00,0x2a,0x06,
0xc4,0xb0,0x09,0x06,0xc4,0xd0,0xf7,0x20,0x8e,0x01,0xd0,0xf2,0xd0,0x05,0x20,0x8e,
0x01,0x90,0xf0,0x85,0xff,0xa0,0x00,0xbd,0x00,0x00,0xe8,0xd0,0x03,0x20,0x98,0x01,
0x99,0x00,0x40,0xc8,0xc0,0x00,0xd0,0xef,0x98,0xf0,0xc9,0x18,0x65,0xfb,0x85,0xfb,
0x90,0x02,0xe6,0xfc,0xa9,0x20,0x06,0xc4,0xd0,0x03,0x20,0x8e,0x01,0x2a,0x90,0xf6,
0xa8,0xb9,0xa7,0x01,0xf0,0x10,0x06,0xc4,0xd0,0x07,0x84,0xc5,0x20,0x8e,0x01,0xa4,
0xc5,0x2a,0x90,0xf2,0x30,0x1f,0x85,0xc5,0xbd,0x00,0x00,0xe8,0xd0,0x03,0x20,0x98,
0x01,0x79,0xaf,0x01,0xb0,0x03,0xc6,0xc5,0x38,0x65,0xfb,0x85,0xc2,0xa5,0xc5,0x79,
0xb7,0x01,0x38,0xb0,0x09,0x79,0xaf,0x01,0x65,0xfb,0x85,0xc2,0xa9,0xff,0x65,0xfc,
0x85,0xc3,0xc0,0x04,0xa9,0x01,0xb0,0x16,0x06,0xc4,0xd0,0x03,0x20,0x8e,0x01,0x2a,
0x06,0xc4,0x90,0xf4,0xd0,0x05,0x20,0x8e,0x01,0x90,0xed,0xa8,0xf0,0x29,0x8d,0x83,
0x01,0xa0,0xff,0xc8,0xb1,0xc2,0x91,0xfb,0xc0,0xff,0xd0,0xf7,0x98,0x65,0xfb,0x85,
0xfb,0x4c,0xcc,0x00,0xbc,0x00,0x00,0x84,0xc4,0x26,0xc4,0xe8,0xd0,0x08,0xee,0x90,
0x01,0xe6,0xf3,0xee,0x34,0x01,0x60,0xc6,0x01,0x58,0x4c
};

// Some definitions for compiler independence
#ifdef _MSC_VER
#	include <malloc.h>
#	include <io.h>
#	define alloca _alloca
#	define inline __forceinline
#else
#	include <sys/stat.h>
#	include <alloca.h>
#	if defined(__GNUC__)
#		define inline __attribute__((always_inline))
#	endif
#endif

#undef min
#define remainder remainder_

// The main crunching structure
typedef struct {
	signed short match_length;
	unsigned short match_offset;

	union {
		signed hash_link;
		unsigned cumulative_cost;
	};
} lz_info;

typedef struct {
	unsigned char *src_data;
	unsigned src_begin;
	unsigned src_end;
	signed margin;

	FILE *dst_file;
	unsigned dst_bits;
	unsigned dst_used;

	lz_info *info;

	signed hash_table[0x100];
	unsigned char dst_literals[RUN_LIMIT * 2];

	// Some informational counters
	struct {
		unsigned output_size;
		unsigned short_freq[4];
		unsigned long_freq[4];
		unsigned literal_bytes;
		unsigned literal_runs;
		unsigned match_bytes;
		unsigned match_count;
		unsigned offset_distance;
	} stats;
} lz_context;

// A bit of global configuration data
typedef struct  {
	unsigned bits;
	unsigned base;
	signed limit;
} offset_length_t;

static offset_length_t cfg_short_offset[4];
static offset_length_t cfg_long_offset[4];
#define cfg_short_limit (cfg_short_offset[3].limit)
#define cfg_long_limit (cfg_long_offset[3].limit)

static bool cfg_per_page = false;


/******************************************************************************
 * Various utility functions and bithacks
 ******************************************************************************/
#define countof(n) (sizeof(n) / sizeof *(n))

inline unsigned _log2(unsigned value) {
#	ifdef __GNUC__
	enum { WORD_BITS = sizeof(unsigned) * CHAR_BIT };

	return (WORD_BITS - 1) ^ __builtin_clz(value);
#	else
	signed bits = -1;

	do
		++bits;
	while(value >>= 1);

	return bits;
#	endif
}

inline bool wraps(unsigned cursor, unsigned length, unsigned limit) {
	return ((cursor + length) ^ cursor) >= limit;
}

inline unsigned remainder(signed cursor, signed window) {
	return -(cursor | -window);
}

inline unsigned min(unsigned a, unsigned b) {
	return (a < b) ? a : b;
}

#ifdef _MSC_VER
__declspec(noreturn)
#elif defined(__GNUC__)
__attribute__((noreturn))
__attribute__((format(printf, 1, 2)))
#endif
static void
#ifdef _MSC_VER
__cdecl
#endif
fatal(const char *format, ...) {
	va_list args;

	va_start(args, format);
	fputs("error: ", stderr);
	vfprintf(stderr, format, args);
	fputc('\n', stderr);
	va_end(args);

	exit(EXIT_FAILURE);
}



/******************************************************************************
 * Manage the output stream
 ******************************************************************************/
inline void _output_doflush(lz_context *ctx) {
	putc(ctx->dst_bits, ctx->dst_file);
	fwrite(ctx->dst_literals, ctx->dst_used, 1, ctx->dst_file);

	ctx->dst_bits = 1;
	ctx->dst_used = 0;
}

inline void output_open(lz_context *ctx, const char *name) {
	if(ctx->dst_file = fopen(name, "wb"), !ctx->dst_file)
		fatal("error: cannot create '%s'", name);

	ctx->dst_bits = 1;
	ctx->dst_used = 0;
}

inline void output_close(lz_context *ctx) {
	if(ctx->dst_bits != 1) {
		while(ctx->dst_bits < 0x100)
			ctx->dst_bits <<= 1;

		putc(ctx->dst_bits, ctx->dst_file);
	}

	fwrite(ctx->dst_literals, ctx->dst_used, 1, ctx->dst_file);
	ctx->stats.output_size = ftell(ctx->dst_file);
	fclose(ctx->dst_file);
}

inline void output_bit(lz_context *ctx, unsigned bit) {
	if(ctx->dst_bits >= 0x100)
		_output_doflush(ctx);

	ctx->dst_bits <<= 1;
	ctx->dst_bits += bit & 1;
}

inline void output_literal(lz_context *ctx, unsigned value) {
	ctx->dst_literals[ctx->dst_used++] = value;
}

inline unsigned output_bitsize(lz_context *ctx) {
	unsigned total;
	unsigned bitbuffer;

	total = ftell(ctx->dst_file);
	total += ctx->dst_used;
	total <<= 3;

	for(bitbuffer = ctx->dst_bits; bitbuffer > 1; bitbuffer >>= 1)
		++total;

	return total;
}


/******************************************************************************
 * Read file into memory and allocate per-byte buffers
 ******************************************************************************/
void read_input(lz_context *ctx, const char *name, bool is_cbm) {
	FILE *file;
	signed length;
	unsigned origin;

	if(file = fopen(name, "rb"), !file)
		fatal("unable to open '%s'", name);

#	ifdef _MSC_VER
	length = _filelength(_fileno(file));
#	else
	{
		struct stat stat;
		stat.st_size = 0;
		fstat(fileno(file), &stat);
		length = stat.st_size;
	}
#	endif

	if(length <= 0)
		fatal("cannot determine length of '%s'", name);

	{
		// Give us a sentinel for the info structure and prevent two-byte
		// hashing from overrunning the buffer
		unsigned count = length + 1;

		ctx->info = malloc(count *
			(sizeof *ctx->info + sizeof *ctx->src_data));
		ctx->src_data = (void *) &ctx->info[count];

		if(!ctx->info)
			fatal("cannot allocate memory buffer");

		if(fread(ctx->src_data, length, 1, file) != 1)
			fatal("cannot read '%s'", name);
	}

	// Deal with the PRG file header. We don't write the loading
	// address back out to compressed file, however we *do* need to
	// consider the decompression address when deciding whether a
	// run crosses a page or window boundary
	origin = 0;

	if(is_cbm) {
		length -= 2;

		if(length < 0) {
			fatal("CBM .prg file is too short to "
				"fit a 2-byte load address");
		}

		origin = *ctx->src_data++;
		origin += *ctx->src_data++ << 8;
	}

	ctx->info -= origin;
	ctx->src_data -= origin;
	ctx->src_begin = origin;
	ctx->src_end = origin + length;
}

// Cut out a specific part of the file to compress
inline void cut_input(lz_context *ctx, unsigned origin, unsigned limit) {
	ctx->src_begin += origin;
	ctx->src_end = min(ctx->src_end, ctx->src_begin + limit);
	if(ctx->src_begin > ctx->src_end)
		fatal("no data in address range %d %d", ctx->src_begin, ctx->src_end);
}


/******************************************************************************
 * Try to figure out what matches would be the most beneficial
 ******************************************************************************/
inline unsigned costof_run(unsigned run) {
	return _log2(run) * 2 + 1;
}

#if USE_LITERAL_RUNS
inline unsigned costof_literals(unsigned address, unsigned length) {
	unsigned cost;

	cost = length * 8;
	cost += costof_run(length);

	// Implicit matches cannot be used after the end of a page
	// when doing per-page rendering, hence an extra bit is
	// needed here
	if(cfg_per_page) {
		cost += wraps(address, length, RUN_LIMIT);
	// A type bit is still always needed after maximum length
	// run since another run may follow
	} else if(length == RUN_LIMIT)
		++cost;
	return cost;
}
#else
enum { COSTOF_LITERAL = 9 };
#endif

inline unsigned costof_match(const offset_length_t *class, signed offset, unsigned length) {
	unsigned cost = 3;

	while(offset > class->limit)
		++class;
	cost += class->bits;

	return cost + costof_run(length - 1);
}

inline lz_info optimal_parsing_literal(const lz_info *info, unsigned cursor) {
	signed length;
	unsigned cost;
	lz_info result;

#	if USE_LITERAL_RUNS
	length = -info[cursor + 1].match_length;

	if(length > 0 && length < RUN_LIMIT)
		cost = info[cursor + ++length].cumulative_cost;
	else
#	endif
	{
		cost = info[cursor + 1].cumulative_cost;
		length = 1;
	}

#	if USE_LITERAL_RUNS
	cost += costof_literals(cursor, length);
#	else
	cost += COSTOF_LITERAL;
#	endif

	result.match_length = -length;
	result.cumulative_cost = cost;

	return result;
}

inline lz_info optimal_parsing (
	const lz_info *info,
	unsigned cursor,
	signed match_offset,
	unsigned match_length,
	unsigned match_limit,
	lz_info best_match
) {
	unsigned cost;

	if(match_length == 2) {
		if(match_offset <= cfg_short_limit) {
			cost = costof_match(cfg_short_offset, match_offset, match_length);
			goto try_short_match;
		} else if(++match_length > match_limit)
			return best_match;
	}

	do {
		cost = costof_match(cfg_long_offset, match_offset, match_length);
try_short_match:
		cost += info[cursor + match_length].cumulative_cost;

		if(cost < best_match.cumulative_cost) {
			best_match.match_offset = match_offset;
			best_match.match_length = match_length;
			best_match.cumulative_cost = cost;
		}
	} while(++match_length <= match_limit);

	return best_match;
}



/******************************************************************************
 * Determine the longest match for every position of the file
 ******************************************************************************/
inline signed *hashof(lz_context *ctx, unsigned a, unsigned b) {
	static const unsigned char random[] = {
		0x17, 0x80, 0x95, 0x4f, 0xc7, 0xd1, 0x15, 0x13,
		0x91, 0x57, 0x0f, 0x47, 0xd0, 0x59, 0xab, 0xf0,
		0xa7, 0xf5, 0x36, 0xc0, 0x24, 0x9c, 0xed, 0xfd,
		0xd4, 0xf3, 0x51, 0xb4, 0x8c, 0x97, 0xa3, 0x58,
		0xcb, 0x61, 0x78, 0xb1, 0x3e, 0x7e, 0xfb, 0x41,
		0x39, 0xa6, 0x8e, 0x10, 0xa1, 0xba, 0x62, 0xcd,
		0x94, 0x02, 0x0d, 0x2b, 0xdb, 0xd7, 0x44, 0x16,
		0x29, 0x4d, 0x68, 0x0a, 0x6b, 0x6c, 0xa2, 0xf8,
		0xc8, 0x9f, 0x25, 0xca, 0xbd, 0x4a, 0xc2, 0x35,
		0x53, 0x1c, 0x40, 0x04, 0x76, 0x43, 0xa9, 0xbc,
		0x46, 0xeb, 0x99, 0xe9, 0xf6, 0x5e, 0x8f, 0x8a,
		0xf1, 0x5d, 0x21, 0x33, 0x0b, 0x82, 0xdf, 0x52,
		0xea, 0x27, 0x22, 0x9a, 0x6f, 0xad, 0xe5, 0x83,
		0x11, 0xbe, 0xa4, 0x85, 0x1d, 0xb3, 0x77, 0xf4,
		0xef, 0xb7, 0xf2, 0x03, 0x64, 0x6d, 0x1b, 0xee,
		0x72, 0x08, 0x66, 0xc6, 0xc1, 0x06, 0x56, 0x81,
		0x55, 0x60, 0x70, 0x8d, 0x23, 0xb2, 0x65, 0x5b,
		0xff, 0x4c, 0xb9, 0x7a, 0xd6, 0xe6, 0x19, 0x9b,
		0xb5, 0x49, 0x7d, 0xd8, 0x45, 0x1a, 0x84, 0x32,
		0xdd, 0xbf, 0x9e, 0x2f, 0xd2, 0xec, 0x92, 0x0e,
		0xe8, 0x7c, 0x7f, 0x00, 0x86, 0xde, 0xb6, 0xcf,
		0x05, 0x69, 0xd5, 0x37, 0xe4, 0x30, 0x3c, 0xe1,
		0x4b, 0xaa, 0x3b, 0x2d, 0xda, 0x5c, 0xcc, 0x67,
		0x20, 0xb0, 0x6a, 0x1f, 0xf9, 0x01, 0xac, 0x2e,
		0x71, 0xf7, 0xfc, 0x3f, 0x42, 0xd3, 0xbb, 0xa8,
		0x38, 0xce, 0x12, 0x96, 0xe2, 0x14, 0x87, 0x4e,
		0x63, 0x07, 0xae, 0xdc, 0xa5, 0xc9, 0x0c, 0x90,
		0xe7, 0xd9, 0x09, 0x2a, 0xc4, 0x3d, 0x5a, 0x34,
		0x8b, 0x88, 0x98, 0x48, 0xfa, 0xc3, 0x26, 0x75,
		0xfe, 0xa0, 0x7b, 0x50, 0x2c, 0x89, 0x18, 0x9d,
		0x3a, 0x73, 0x6e, 0x5f, 0xc5, 0xaf, 0xb8, 0x74,
		0x93, 0xe3, 0x79, 0x28, 0xe0, 0x1e, 0x54, 0x31
	};

	size_t bucket = random[a] ^ b;
	return &ctx->hash_table[bucket];
}

inline void generate_hash_table(lz_context *ctx) {
	unsigned cursor;

	const unsigned src_end = ctx->src_end;
	const unsigned char *src_data = ctx->src_data;
	lz_info *info = ctx->info;

	for(cursor = 0; cursor < countof(ctx->hash_table); ++cursor)
		ctx->hash_table[cursor] = INT_MIN;

	for(cursor = ctx->src_begin; cursor != src_end; ++cursor) {
		signed *hash_bucket = hashof (
			ctx,
			src_data[cursor + 0],
			src_data[cursor + 1]
		);

		info[cursor].hash_link = *hash_bucket;
		*hash_bucket = cursor;
	}
}

inline void find_matches(lz_context *ctx, unsigned window) {
	const unsigned src_begin = ctx->src_begin;
	const unsigned src_end = ctx->src_end;
	const unsigned char *src_data = ctx->src_data;
	lz_info *info = ctx->info;

	unsigned offset_limit = min(window, cfg_long_limit);
	unsigned cursor = ctx->src_end;

	info[cursor].cumulative_cost = 0;

	while(cursor != src_begin) {
		unsigned match_length;
		signed cursor_limit;
		unsigned length_limit;
		signed *hash_bucket;
		signed hash_link;
		lz_info best_match;

		--cursor;

		match_length = 1;
		cursor_limit = cursor - offset_limit;

		length_limit = RUN_LIMIT;
		length_limit = min(length_limit, remainder(cursor, window));
		length_limit = min(length_limit, src_end - cursor);

		hash_bucket = hashof (
			ctx,
			src_data[cursor + 0],
			src_data[cursor + 1]
		);

		assert((unsigned) *hash_bucket == cursor);
		hash_link = info[cursor].hash_link;
		*hash_bucket = hash_link;

		best_match = optimal_parsing_literal(info, cursor);

		while(hash_link >= cursor_limit) {
			unsigned match_limit = remainder(hash_link, window);
			match_limit = min(match_limit, length_limit);

			if(match_length != match_limit) {
				unsigned i = match_length + 1;

				if(!memcmp(&src_data[cursor], &src_data[hash_link], i)) {
					for(; i != match_limit; ++i) {
						if(src_data[cursor + i] != src_data[hash_link + i])
							break;
					}

					assert(i <= match_limit);

					best_match = optimal_parsing (
						info,
						cursor,
						cursor - hash_link,
						match_length + 1,
						i,
						best_match
					);

					match_length = i;

					if(match_length == RUN_LIMIT)
						break;
				}
			}

			hash_link = info[hash_link].hash_link;
		}

		info[cursor] = best_match;
	}
}


/******************************************************************************
 * Write the generated matches and literal runs
 ******************************************************************************/
#if USE_LITERAL_RUNS
inline void encode_literals (
	lz_context *ctx,
	unsigned cursor,
	unsigned length
) {
	signed bit;
	const unsigned char *data;
	unsigned start = length;

	ctx->stats.literal_bytes += length;
	++ctx->stats.literal_runs;

	bit = _log2(length);
	while(--bit >= 0) {
		output_bit(ctx, 0);
		output_bit(ctx, length >> bit);
	}

	output_bit(ctx, 1);

	data = &ctx->src_data[cursor];
	do
		output_literal(ctx, data[start - length--]);
	while(length);
}
#endif

inline void encode_match (
	lz_context *ctx,
	signed offset,
	unsigned length
) {
	unsigned offset_bits;
	unsigned offset_prefix;
	const offset_length_t *offset_class;
	signed length_bit;

	++ctx->stats.match_count;
	ctx->stats.match_bytes += length;
	ctx->stats.offset_distance += offset;

	// Write initial length bit
	length_bit = _log2(--length);
	output_bit(ctx, --length_bit < 0);

	// Write offset prefix
	if(length == 2 - 1) {
		assert(offset <= cfg_short_limit);
		offset_prefix = 0;
		offset_class = cfg_short_offset;

		while(offset > offset_class->limit) {
			++offset_class;
			++offset_prefix;
		}

		++ctx->stats.short_freq[offset_prefix];

		// Note that the encoding for short matches is reversed relative to
		// the long ones in order to expose holes in the decruncher's offset
		// tables
		offset_prefix = ~offset_prefix;
	} else {
		assert(offset <= cfg_long_limit);
		offset_prefix = 0;
		offset_class = cfg_long_offset;

		while(offset > offset_class->limit) {
			++offset_class;
			++offset_prefix;
		}

		++ctx->stats.long_freq[offset_prefix];
	}

	output_bit(ctx, offset_prefix >> 1);
	output_bit(ctx, offset_prefix >> 0);

	// Write offset payload
	offset -= offset_class->base;
	offset = ~offset;

	offset_bits = offset_class->bits;
	while(offset_bits & 7)
		output_bit(ctx, offset >> --offset_bits);

	if(offset_bits)
		output_literal(ctx, offset);

	// Write any remaining length bits
	while(length_bit >= 0) {
		output_bit(ctx, length >> length_bit);
		output_bit(ctx, --length_bit < 0);
	}
}

inline void write_output(lz_context *ctx, bool show_trace) {
	unsigned cursor;

	bool implicit_match = false;

	unsigned src_end = ctx->src_end;
	unsigned read_pos;
	unsigned write_pos;

	lz_info *info = ctx->info;
	signed length;

	ctx->margin = 0;
	for(cursor = ctx->src_begin; cursor < src_end; cursor += length) {
		length = info[cursor].match_length;

		if(length > 0) {
			unsigned offset;

#			if USE_LITERAL_RUNS
			if(!implicit_match)
#			endif
			{
				output_bit(ctx, 0);
			}

			offset = info[cursor].match_offset;
			encode_match(ctx, offset, length);

			if(show_trace) {
				printf (
					"$%04x %smatch(-%u/$%04x, %u bytes)\n",
					cursor,
					implicit_match ? "" : "explicit-",
					offset,
					cursor - offset,
					length
				);
			}

#			if USE_LITERAL_RUNS
			implicit_match = false;
#			endif
		} else {
			length = -length;
			output_bit(ctx, 1);

#			if USE_LITERAL_RUNS
			{

				// Normally a match implicitly follows a literal run except for the
				// case of a maximum length literal run, or for when the the streaming
				// version crosses into the next page
				if(cfg_per_page)
					implicit_match = !wraps(cursor, length, RUN_LIMIT);
				else
					implicit_match = length < RUN_LIMIT;

				// The parser may generate a short run followed by one or more maximum
				// length runs for split literals. This needs to be avoided manually
				// by reversing the order
				if(implicit_match) {
					signed next_length = -info[cursor + length].match_length;
					if(next_length > 0) {
						info[cursor].match_length = -next_length;
						info[cursor + next_length].match_length = -length;
						length = next_length;

						assert(length == RUN_LIMIT);
						implicit_match = false;
					}
				}

				encode_literals(ctx, cursor, length);
			}
#			else
			output_literal(ctx, ctx->src_data[cursor]);
#			endif

			if(show_trace) {
				printf (
					"$%04x literal(%u bytes)\n",
					cursor,
					length
				);
			}
		}
		// Check for overlap between written area and packed data, in case bump safety margin
		read_pos = cursor - ctx->src_begin + length;
		write_pos = output_bitsize(ctx) / 8 + 1;
		if(read_pos > write_pos + ctx->margin) ctx->margin = read_pos - write_pos;

	}

#	if VERIFY_COST_MODEL
	{
		unsigned expected = info[ctx->src_begin].cumulative_cost;
		unsigned actual = output_bitsize(ctx);

		if(expected != actual) {
			printf (
				"expected: %u\n"
				"actual:   %u\n",
				expected,
				actual
			);
		}
	}
#	endif

	// The sentinel is a maximum-length match
#	if USE_LITERAL_RUNS
	if(!implicit_match)
#	endif
	{
		output_bit(ctx, 0);
	}

	encode_match(ctx, 1, RUN_LIMIT + 1);
}


/******************************************************************************
 * Parse out the set of offset bit lengths from a descriptor string
 ******************************************************************************/
static void prepare_offset_lengths(offset_length_t *table, size_t count) {
	unsigned base;
	unsigned limit = 0;
	unsigned previous = 0;

	do {
		unsigned int bits = table->bits;

		if(bits <= previous)
			fatal("offset lengths must be listed in ascending order");
		previous = bits;
		if(bits > OFFSET_LENGTH_LIMIT)
			fatal("offset lengths cannot be wider than %u bits", OFFSET_LENGTH_LIMIT);

		base = limit + 1;
		limit += 1 << bits;
		table->base = base;
		table->limit = limit;
		++table;
	} while(--count);
}

inline bool parse_offset_lengths(const char *text) {
	if(sscanf(text, "%u/%u/%u/%u:%u/%u/%u/%u",
		&cfg_short_offset[0].bits, &cfg_short_offset[1].bits,
		&cfg_short_offset[2].bits, &cfg_short_offset[3].bits,
		&cfg_long_offset[0].bits, &cfg_long_offset[1].bits,
		&cfg_long_offset[2].bits, &cfg_long_offset[3].bits) != 8) {
		return false;
	}
	prepare_offset_lengths(cfg_short_offset, 4);
	prepare_offset_lengths(cfg_long_offset, 4);
	return true;
}


/******************************************************************************
 * Generate decruncher the tables corresponding to a particular offset length
 * sequence.
 * These are admittedly rather convoluted and tied tightly to how matches are
 * handled in the implementation. See the source for details
 ******************************************************************************/

static char single_offset (
	const offset_length_t *class,
	unsigned shift
) {
	signed offset = class->base + 1;
	if(class->bits > 8)
		offset += 0x8000;
	else if(class->bits == 8)
		offset += 0x0100;
	offset = -offset;
	offset >>= shift;
	offset &= 0xFF;

	return offset;
}

static void write_single_offset (
	FILE *file,
	const offset_length_t *class,
	unsigned shift
) {
	char binary[9];

	signed offset = class->base + 1;
	if(class->bits > 8)
		offset += 0x8000;
	else if(class->bits == 8)
		offset += 0x0100;
	offset = -offset;
	offset >>= shift;
	offset &= 0xFF;

	{
		char *digit = &binary[8];
		*digit = '\0';
		do {
			*--digit = (offset & 1)["01"];
			offset >>= 1;
		} while(digit != binary);
	}

	fprintf (
		file,
		"%s\t\t.byte %%%s\t\t;%u-%u%s\n",
		class->bits < shift ? ";" : "",
		binary,
		class->base,
		class->limit,
		class->bits < shift ? " (unreferenced)" : ""
	);
}

inline void write_offsets(FILE* file) {
	static const char const length_codes[] = {
		0,
		0xff,
		0x7f,
		0x3f,
		0x1f,
		0x0f,
		0x07,
		0x03,
		0x00,
		0xbf,
		0x5f,
		0x2f,
		0x17,
		0x0b,
		0x05,
		0x02
	};

	ptrdiff_t i;

	for(i = 0; i <= 3; ++i) {
		unsigned bits = cfg_long_offset[i].bits;
		fputc(length_codes[bits], file);
	}
	for(i = 3; i >= 0; --i) {
		unsigned bits = cfg_short_offset[i].bits;
		fputc(length_codes[bits], file);
	}
	for(i = 0; i <= 3; ++i)
		fputc(single_offset(&cfg_long_offset[i], 0), file);
	for(i = 3; i >= 0; --i)
		fputc(single_offset(&cfg_short_offset[i], 0), file);
	// MSB of base offsets
	for(i = 0; i <= 3; ++i)
		fputc(single_offset(&cfg_long_offset[i], 8), file);
	for(i = 3; i >= 0; --i)
		fputc(single_offset(&cfg_short_offset[i], 8), file);
}

inline void write_offset_tables(const char *name) {
	static const char long_title[] = "\t\t;Long (>2 byte matches)\n";
	static const char short_title[] = "\t\t;Short (2 byte matches)\n";

	static const char *const length_codes[] = {
		NULL,
		"11111111", // 1-bits
		"01111111", // 2-bits
		"00111111", // 3-bits
		"00011111", // 4-bits
		"00001111", // 5-bits
		"00000111", // 6-bits
		"00000011", // 7-bits
		"00000000", // 8-bits: This needs a bit of special-processing
		"10111111", // 9-bits
		"01011111", // 10-bits
		"00101111", // 11-bits
		"00010111", // 12-bits
		"00001011", // 13-bits
		"00000101", // 14-bits
		"00000010"  // 15-bits
	};

	ptrdiff_t i;
	unsigned near_longs;

	// Open the target file
	FILE *file = fopen(name, "w");
	if(!file)
		fatal("cannot create '%s'", name);

	// Bit lengths
	fprintf(file, "_lz_moff_length\n");
	fprintf(file, long_title);
	near_longs = 0;
	for(i = 0; i <= 3; ++i) {
		unsigned bits = cfg_long_offset[i].bits;
		fprintf(file, "\t\t.byte %%%s\t\t;%u bits\n",
			length_codes[bits], bits);
		if(bits < 8)
			++near_longs;
	}
	fprintf(file, short_title);
	for(i = 3; i >= 0; --i) {
		unsigned bits = cfg_short_offset[i].bits;
		fprintf(file, "\t\t.byte %%%s\t\t;%u bits\n",
			length_codes[bits], bits);
	}
	// LSB of base offsets
	fprintf(file, "_lz_moff_adjust_lo\n");
	fprintf(file, long_title);
	for(i = 0; i <= 3; ++i)
		write_single_offset(file, &cfg_long_offset[i], 0);
	fprintf(file, short_title);
	for(i = 3; i >= 0; --i)
		write_single_offset(file, &cfg_short_offset[i], 0);
	// MSB of base offsets
	fprintf(file, "_lz_moff_adjust_hi = *-%u\n", near_longs);
	fprintf(file, long_title);
	for(i = 0; i <= 3; ++i)
		write_single_offset(file, &cfg_long_offset[i], 8);
	fprintf(file, short_title);
	for(i = 3; i >= 0; --i)
		write_single_offset(file, &cfg_short_offset[i], 8);

	fclose(file);
}


/******************************************************************************
 * Print some basic statistics about the encoding of the file
 ******************************************************************************/
inline void print_statistics(const lz_context *ctx, FILE *file) {
	unsigned input_size = ctx->src_end - ctx->src_begin;

	fprintf (
		file,
		"input file:\t"    "%u bytes\n"
		"output file:\t"   "%u bytes, %u bits (%.2f%% ratio)\n"
		"short offsets:\t" "{ %u-%u: %u, %u-%u: %u, %u-%u: %u, %u-%u: %u }\n"
		"long offsets:\t"  "{ %u-%u: %u, %u-%u: %u, %u-%u: %u, %u-%u: %u }\n"
		"%u matches:\t"    "%u bytes, %f avg\n"
		"%u literals:\t"   "%u bytes, %f avg\n"
		"avg offset:\t"    "%f bytes\n",

		input_size,
		ctx->stats.output_size,
		ctx->info->cumulative_cost,
		100.0 * ctx->stats.output_size / input_size,

		cfg_short_offset[0].base,
		cfg_short_offset[0].limit,
		ctx->stats.short_freq[0],
		cfg_short_offset[1].base,
		cfg_short_offset[1].limit,
		ctx->stats.short_freq[1],
		cfg_short_offset[2].base,
		cfg_short_offset[2].limit,
		ctx->stats.short_freq[2],
		cfg_short_offset[3].base,
		cfg_short_offset[3].limit,
		ctx->stats.short_freq[3],
		cfg_long_offset[0].base,
		cfg_long_offset[0].limit,
		ctx->stats.long_freq[0],
		cfg_long_offset[1].base,
		cfg_long_offset[1].limit,
		ctx->stats.long_freq[1],
		cfg_long_offset[2].base,
		cfg_long_offset[2].limit,
		ctx->stats.long_freq[2],
		cfg_long_offset[3].base,
		cfg_long_offset[3].limit,
		ctx->stats.long_freq[3],

		ctx->stats.match_count,
		ctx->stats.match_bytes,
		(double) ctx->stats.match_bytes / ctx->stats.match_count,

		ctx->stats.literal_runs,
		ctx->stats.literal_bytes,
		(double) ctx->stats.literal_bytes / ctx->stats.literal_runs,

		(double) ctx->stats.offset_distance / ctx->stats.match_count
	);
}

/******************************************************************************
 * Helper functions
 ******************************************************************************/
signed read_number(char* arg) {
	if(arg[0] == '$') return strtoul(arg + 1, NULL, 16);
	else if(arg[0] == '0' && arg[1] == 'x') return strtoul(arg + 2, NULL, 16);
	return strtoul(arg, NULL, 10);
}

unsigned compress(lz_context* ctx, char* output_name, unsigned window) {
	unsigned packed_size;

	generate_hash_table(ctx);
	find_matches(ctx, window);
	output_open(ctx, output_name);
	write_output(ctx, 0);
	output_close(ctx);

	if(ctx->dst_file = fopen(output_name, "rb+"), !ctx->dst_file)
		fatal("error: cannot create '%s'", output_name);
	fseek(ctx->dst_file, 0L, SEEK_END);
	packed_size = ftell(ctx->dst_file);
	fclose(ctx->dst_file);
	return packed_size;
}

/******************************************************************************
 * The main function
 ******************************************************************************/
int
#ifdef _MSC_VER
__cdecl
#endif
main(int argc, char *argv[]) {
#define OUTPUT_NONE	0
#define OUTPUT_RAW	1
#define OUTPUT_SFX	2
#define OUTPUT_LEVEL	3

	enum { INFINITE_WINDOW = (unsigned) INT_MIN };

	const char *program_name;
	const char *input_name;
	char *output_name;
	unsigned name_length;
	unsigned window;
	unsigned cut_origin;
	unsigned cut_limit;
	const char *emit_offset_tables;
	bool show_stats;
	bool show_trace;
	bool is_cbm = true;
	unsigned opt_addr = 0;
	unsigned margin;
	unsigned packed_size;
	unsigned source_size;
	char lengths[24];
	unsigned lbits[6], sbits[6];
	unsigned lbest, sbest;
	unsigned iterations = 0;

	unsigned decruncher_size = 0;
	signed start_addr = -1;
	unsigned data_addr = 0;
	bool write_tables = false;

	signed output_type = OUTPUT_LEVEL;

	lz_context ctx;

	// Parse the command line
	program_name = *argv;
	output_name = NULL;
	window = INFINITE_WINDOW;
	cut_origin = 0;
	cut_limit = INT_MAX;
	emit_offset_tables = NULL;
	show_stats = false;
	show_trace = false;
	memset(&ctx.stats, 0, sizeof ctx.stats);
	parse_offset_lengths(DEFAULT_LENGTHS);

	while(++argv, --argc) {
		if(argc >= 2 && !strcmp(*argv, "-o")) {
			output_name = *++argv;
			--argc;
		} else if(argc >= 2 && !strcmp(*argv, "--window")) {
			window = strtoul(*++argv, NULL, 0);
			--argc;

			if(window < RUN_LIMIT || ((window - 1) & window)) {
				fatal("window size must be a power of two "
					"larger than 0x%x", RUN_LIMIT);
			}

			// This implicitly forces paged rendering
			cfg_per_page = true;
		} else if(argc >= 2 && !strcmp(*argv, "--sfx")) {
			start_addr = read_number(*++argv);
			output_type = OUTPUT_SFX;
			write_tables = true;
			--argc;
		} else if(argc >= 2 && !strcmp(*argv, "--raw")) {
			output_type = OUTPUT_RAW;
		} else if(argc >= 2 && !strcmp(*argv, "--level")) {
			output_type = OUTPUT_LEVEL;
		} else if(argc >= 3 && !strcmp(*argv, "--cut-input")) {
			cut_origin = read_number(*++argv);
			cut_limit = read_number(*++argv);
			argc -= 2;
		} else if(!strcmp(*argv, "--best-offset-tables")) {
			iterations = 4;
		} else if(!strcmp(*argv, "--per-page")) {
			cfg_per_page = true;
		} else if(argc >= 2 && !strcmp(*argv, "--offset-lengths")) {
			if(!parse_offset_lengths(*++argv))
				break;
			--argc;
		} else if(argc >= 2 && !strcmp(*argv, "--emit-offset-tables")) {
			emit_offset_tables = *++argv;
			--argc;
		} else if(!strcmp(*argv, "--include-tables")) {
			write_tables = true;
		} else if(!strcmp(*argv, "--statistics")) {
			show_stats = true;
		} else if(!strcmp(*argv, "--trace-coding")) {
			show_trace = true;
		} else if(!strcmp(*argv, "--binfile")) {
			is_cbm = false;
		} else {
			break;
		}
	}

	if(emit_offset_tables) {
		write_offset_tables(emit_offset_tables);
		// It allowed to just generate the offset tables
		if(!argc)
			return EXIT_SUCCESS;
	}

	if(argc != 1) {
		fprintf (
			stderr,
			"syntax: %s\n"
			"\t[-o output.lz]\n"
			"\t[--window window-size]\n"
			"\t[--per-page]\n"
			"\t[--cut-input origin size]\n"
			"\t[--offset-lengths s1/s2/s3/s4:l1/l2/l3/l4]\n"
			"\t[--emit-offset-tables tables.asm]\n"
			"\t[--statistics]\n"
			"\t[--trace-coding]\n"
			"\t[--binfile]\n"
			"\t[--best-offset-tables]\n"
			"\t[--include-tables]\n"
			"\t[--sfx startaddr]\n"
			"\t[--level]\n"
			"\t[--raw]\n"
			"\t{input-file}\n",
			program_name
		);
		return EXIT_FAILURE;
	}

	input_name = *argv;

	if (is_cbm) {
		if(window != INFINITE_WINDOW) {
			fprintf(stderr, "warning: sliding-window used with "
				"a PRG file\n");
		}
	} else {
		if (output_type == OUTPUT_SFX || output_type == OUTPUT_LEVEL) {
			fprintf(stderr, "error: sfx/level not supported with raw binaries\n");
			return EXIT_FAILURE;
		}
	}

	// If necessary generate output file by substituting the
	// extension for .lz
	if(!output_name) {
		static const char extension[] = ".lz";
		name_length = sizeof input_name + 1;

		output_name = alloca(name_length + sizeof extension);

		memcpy(output_name, input_name, name_length);
		memcpy(&output_name[name_length], extension, sizeof extension);
	}

	decruncher_size = sizeof decruncher;

	read_input(&ctx, input_name, is_cbm);
	cut_input(&ctx, cut_origin, cut_limit);

	if (iterations > 0) {
		unsigned temp, j;
		setbuf(stdout, NULL);
		lbits[0] = sbits[0] = 0;
		lbits[1] = sbits[1] = 1;
		lbits[2] = sbits[2] = 13;
		lbits[3] = sbits[3] = 14;
		lbits[4] = sbits[4] = 15;
		lbits[5] = sbits[5] = 16;

		packed_size = 0;
		while (iterations--) {
			for (j = 1; j < 5; j++) {
				sbest = 0;
				for (sbits[j] = sbits[j-1] + 1; sbits[j] < sbits[j+1]; sbits[j]++) {
					sprintf(lengths,"%u/%u/%u/%u:%u/%u/%u/%u",sbits[1],sbits[2],sbits[3],sbits[4],lbits[1],lbits[2],lbits[3],lbits[4]);
					parse_offset_lengths(lengths);
					temp = compress(&ctx, output_name, window);
					if (sbest == 0 || temp < packed_size) {
						printf("best bitlengths: %s        \r", lengths);
						sbest = sbits[j]; packed_size = temp;
					}
				}
				sbits[j] = sbest;

				lbest = 0;
				for (lbits[j] = lbits[j-1] + 1; lbits[j] < lbits[j+1]; lbits[j]++) {
					sprintf(lengths,"%u/%u/%u/%u:%u/%u/%u/%u",sbits[1],sbits[2],sbits[3],sbits[4],lbits[1],lbits[2],lbits[3],lbits[4]);
					parse_offset_lengths(lengths);
					temp = compress(&ctx, output_name, window);
					if (lbest == 0 || temp < packed_size) {
						printf("best bitlengths: %s        \r", lengths);
						lbest = lbits[j]; packed_size = temp;
					}
				}
				lbits[j] = lbest;
			}
		}

		sprintf(lengths,"%u/%u/%u/%u:%u/%u/%u/%u",sbits[1],sbits[2],sbits[3],sbits[4],lbits[1],lbits[2],lbits[3],lbits[4]);
		parse_offset_lengths(lengths);
		printf("best bitlengths: %s        \n", lengths);
	}

	// Do the compression
	generate_hash_table(&ctx);
	find_matches(&ctx, window);

	output_open(&ctx, output_name);

	if(output_type == OUTPUT_LEVEL) {
		// Add 2 blank bytes here first, as the address can not be calculated yet
		fputc(0, ctx.dst_file);
		fputc(0, ctx.dst_file);
	} else if(output_type == OUTPUT_SFX) {
		// Output decruncher with loadadress 0x801
		fwrite(decruncher, decruncher_size, 1, ctx.dst_file);
	}

	if(output_type == OUTPUT_LEVEL) {
		// Add depack address
		fputc(ctx.src_begin & 0xff, ctx.dst_file);
		fputc(ctx.src_begin >> 8, ctx.dst_file);
	}
	if(output_type == OUTPUT_SFX) {
		// Add depack address
		fputc(start_addr & 0xff, ctx.dst_file);
		fputc(start_addr >> 8, ctx.dst_file);
	}

	if(write_tables) write_offsets(ctx.dst_file);

	write_output(&ctx, show_trace);
	output_close(&ctx);

	if(ctx.dst_file = fopen(output_name, "rb+"), !ctx.dst_file)
		fatal("error: cannot create '%s'", output_name);
	fseek(ctx.dst_file, 0L, SEEK_END);
	packed_size = ftell(ctx.dst_file);
	source_size = ctx.src_end - ctx.src_begin;
	margin = ctx.margin + packed_size - source_size;

	if(output_type == OUTPUT_LEVEL) {
		// Optimal load address
		packed_size -= 2;
	} else if(output_type == OUTPUT_SFX) {
		packed_size -= decruncher_size;
	}

	printf("safety-margin: %d bytes\n", margin);
	printf("source size: $%04x (%d)\n", source_size, source_size);
	printf("packed data: $%04x (%d)\n", packed_size, packed_size);

	if(output_type == OUTPUT_LEVEL) {
		opt_addr = ctx.src_end - packed_size + margin;
		printf("source load: $%04x-$%04x\n", ctx.src_begin, ctx.src_end);
		printf("packed load: $%04x-$%04x\n", opt_addr, opt_addr + packed_size);
		printf("output filetype: level\n");
	} else if(output_type == OUTPUT_SFX) {
		printf("start address: $%04x (%d)\n", start_addr, start_addr);
		printf("final size: $%04x (%d)\n", packed_size + decruncher_size, packed_size + decruncher_size);
		printf("output filetype: sfx\n");
	} else {
		printf("output filetype: raw\n");
	}

	if(output_type == OUTPUT_LEVEL) {
		// Fix optimal load address to file
		fseek(ctx.dst_file, 0, SEEK_SET);
		fputc(opt_addr & 0xff, ctx.dst_file);
		fputc(opt_addr >> 8, ctx.dst_file);
	} else if (output_type == OUTPUT_SFX) {
		packed_size -= 26;
		data_addr = decruncher_size + packed_size - 0xff + 0x800 + 24;

		// Set up depacker values
		fseek(ctx.dst_file, 0x1f, SEEK_SET);
		fputc((packed_size >> 8) + 1, ctx.dst_file);

		fseek(ctx.dst_file, 0x22, SEEK_SET);
		fputc(data_addr & 0xff, ctx.dst_file);
		fputc(data_addr >> 8, ctx.dst_file);

		fseek(ctx.dst_file, 0x34, SEEK_SET);
		fputc((0x10000 - packed_size) & 0xff, ctx.dst_file);

		fseek(ctx.dst_file, 0x69, SEEK_SET);
		fputc((0x10000 - packed_size) >> 8, ctx.dst_file);
		fseek(ctx.dst_file, 0xaa, SEEK_SET);
		fputc((0x10000 - packed_size) >> 8, ctx.dst_file);
		fseek(ctx.dst_file, 0x106, SEEK_SET);
		fputc((0x10000 - packed_size) >> 8, ctx.dst_file);

		fseek(ctx.dst_file, 0x71, SEEK_SET);
		fputc(ctx.src_begin & 0xff, ctx.dst_file);
		fputc(ctx.src_begin >> 8, ctx.dst_file);
	}
	fclose(ctx.dst_file);

	// Display some statistics gathered in the process
	if(show_stats)
		print_statistics(&ctx, stdout);
	return EXIT_SUCCESS;
}
