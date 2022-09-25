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
		output_bit(ctx, 1);
		output_bit(ctx, length >> bit);
	}

	output_bit(ctx, 0);

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

	// Write length
	length_bit = _log2(--length);
	output_bit(ctx, --length_bit >= 0);

	while(length_bit >= 0) {
		output_bit(ctx, length >> length_bit);
		output_bit(ctx, --length_bit < 0);
	}

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
	offset--;

	offset_bits = offset_class->bits;
	if (offset_bits > 7) {
		while(offset_bits & 7)
			output_bit(ctx, offset >> --offset_bits);
		if(offset_bits)
			output_literal(ctx, ~offset);
	} else {
		while(offset_bits & 7)
			output_bit(ctx, ~offset >> --offset_bits);
		if(offset_bits)
			output_literal(ctx, ~offset);
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
					"$%04x %smatch($%04x/$%04x, %u bytes)\n",
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

				// Check for overlap between written area and packed data, in case bump safety margin
				//read_pos = cursor - ctx->src_begin + length;
				//write_pos = output_bitsize(ctx) / 8 + 1;
				//if(read_pos > write_pos + ctx->margin) ctx->margin = read_pos - write_pos;

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
		write_pos = ((output_bitsize(ctx) | 7) + 1) / 8;
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

	// The sentinel is a maximum-length match, without offset
#	if USE_LITERAL_RUNS
	if(!implicit_match)
#	endif
	{
		output_bit(ctx, 0);
	}

	// Write length
	signed length_bit = _log2(RUN_LIMIT);
	output_bit(ctx, --length_bit >= 0);

	while(length_bit >= 0) {
		output_bit(ctx, RUN_LIMIT >> length_bit);
		output_bit(ctx, --length_bit < 0);
	}

	// Check for overlap between written area and packed data, in case bump safety margin
	read_pos = cursor - ctx->src_begin;
	write_pos = ((output_bitsize(ctx) | 7) + 1) / 8;
	if(read_pos > write_pos + ctx->margin) ctx->margin = read_pos - write_pos;

}


/******************************************************************************
 * Parse out the set of offset bit lengths from a descriptor string
 ******************************************************************************/
static void prepare_offset_lengths(offset_length_t *table, size_t count) {
	unsigned limit = 0;
	unsigned previous = 0;

	do {
		unsigned int bits = table->bits;

		if(bits <= previous)
			fatal("offset lengths must be listed in ascending order");
		previous = bits;
		if(bits > OFFSET_LENGTH_LIMIT)
			fatal("offset lengths cannot be wider than %u bits", OFFSET_LENGTH_LIMIT);

		limit = 1 << bits;
		table->base = 0;
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

inline void write_offsets(FILE* file) {
	unsigned bits;
	unsigned value;
	static const char const length_codes[] = {
		0x00,
		0x7f,
		0xbf,
		0xdf,
		0xef,
		0xf7,
		0xfb,
		0xfd,
		0x00,
		0x00, //XXX TODO can't use value for 9 as beq lz_far would tehn take effect :-( maybe use $ff for 8 and skip eor #$ff? how to test without clobbering carry? all values eor #$ff? -> before eor: beq lz_far?
		0x80,
		0xc0,
		0xe0,
		0xf0,
		0xf8,
		0xfc
	};

	bits = cfg_long_offset[0].bits;
	value = length_codes[bits];
	fputc(value, file);

	bits = cfg_short_offset[0].bits;
	value = length_codes[bits];
	fputc(value, file);
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
	enum { INFINITE_WINDOW = (unsigned) INT_MIN };

	const char *program_name;
	const char *input_name;
	char *output_name;
	unsigned name_length;
	unsigned window;
	unsigned cut_origin;
	unsigned cut_limit;
	bool show_stats;
	bool show_trace;
	unsigned i;
	bool is_cbm = true;
	unsigned opt_addr = 0;
	unsigned margin;
	unsigned packed_size;
	unsigned source_size;

	lz_context ctx;

	// Parse the command line
	program_name = *argv;
	output_name = NULL;
	window = INFINITE_WINDOW;
	cut_origin = 0;
	cut_limit = INT_MAX;
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
		} else if(argc >= 3 && !strcmp(*argv, "--cut-input")) {
			cut_origin = read_number(*++argv);
			cut_limit = read_number(*++argv);
			//cut_origin = strtoul(*++argv, NULL, 0);
			//cut_limit = strtoul(*++argv, NULL, 0);
			argc -= 2;
		} else if(!strcmp(*argv, "--per-page")) {
			cfg_per_page = true;
		} else if(argc >= 2 && !strcmp(*argv, "--offset-lengths")) {
			if(!parse_offset_lengths(*++argv))
				break;
			--argc;
		} else if(!strcmp(*argv, "--statistics")) {
			show_stats = true;
		} else if(!strcmp(*argv, "--trace-coding")) {
			show_trace = true;
		} else {
			break;
		}
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
			"\t[--statistics]\n"
			"\t[--trace-coding]\n"
			"\t{input.prg|bin}\n",
			program_name
		);
		return EXIT_FAILURE;
	}

	input_name = *argv;

	// Check extension to figure out whether it's a .PRG file
	name_length = 0;

	for(i = 0; input_name[i]; ++i) {
		switch(input_name[i]) {
		case '/':
		case '\\':
		case ':':
			name_length = 0;
			break;
		case '.':
			name_length = i;
			break;
		}
	}

	if(!name_length) {
		name_length = i;
	}
	if (is_cbm) {
		if(window != INFINITE_WINDOW) {
			fprintf(stderr, "warning: sliding-window used with "
				"a PRG file\n");
		}
	}

	// If necessary generate output file by substituting the
	// extension for .lz
	if(!output_name) {
		static const char extension[] = ".lz";

		output_name = alloca(name_length + sizeof extension);

		memcpy(output_name, input_name, name_length);
		memcpy(&output_name[name_length], extension, sizeof extension);
	}

	read_input(&ctx, input_name, is_cbm);
	cut_input(&ctx, cut_origin, cut_limit);

	// Do the compression
	generate_hash_table(&ctx);
	find_matches(&ctx, window);

	output_open(&ctx, output_name);

	// Add 2 blank bytes here first, as the address can not be calculated yet
	fputc(0, ctx.dst_file);
	fputc(0, ctx.dst_file);
	// Add the depack address
	fputc(ctx.src_begin & 0xff, ctx.dst_file);
	fputc(ctx.src_begin >> 8, ctx.dst_file);

	write_output(&ctx, show_trace);
	output_close(&ctx);

	if(ctx.dst_file = fopen(output_name, "rb+"), !ctx.dst_file)
		fatal("error: cannot create '%s'", output_name);
	fseek(ctx.dst_file, 0L, SEEK_END);
	packed_size = ftell(ctx.dst_file);

	source_size = ctx.src_end - ctx.src_begin;
	margin = ctx.margin + packed_size - source_size;

	if (is_cbm) packed_size -= 2;

	printf("safety-margin: %d bytes\n", margin);
	printf("source size: $%04x (%d)\n", source_size, source_size);
	printf("packed size: $%04x (%d)\n", packed_size, packed_size);

	opt_addr = ctx.src_end - packed_size + margin;
	//printf("optimal load address: $%04x (%d)\n", opt_addr, opt_addr);
	printf("source load: $%04x-$%04x\n", ctx.src_begin, ctx.src_end);
	printf("packed load: $%04x-$%04x\n", opt_addr, opt_addr + packed_size);

	fseek(ctx.dst_file, 0, SEEK_SET);
	fputc(opt_addr & 0xff, ctx.dst_file);
	fputc(opt_addr >> 8, ctx.dst_file);
	fclose(ctx.dst_file);

	// Display some statistics gathered in the process
	if(show_stats)
		print_statistics(&ctx, stdout);
	return EXIT_SUCCESS;
}
