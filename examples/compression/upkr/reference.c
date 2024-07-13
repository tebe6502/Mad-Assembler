#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define OFFSET_BITS 16
#define LENGTH_BITS 16
#define OFFSET_PROBS ((OFFSET_BITS)*2-1)
#define LENGTH_PROBS ((LENGTH_BITS)*2-1)

static const uint8_t *src;
static uint16_t state;
static int bitBuf;
static uint8_t probs[1 + 255 + 1 + OFFSET_PROBS + LENGTH_PROBS];

static int getBit(int index)
{
	while (state < 0x8000) {
		bitBuf = (bitBuf << 1) & 0x1ff;
		if (bitBuf == 0x100)
			bitBuf = *src++ << 1 | 1;
		state = state << 1 | bitBuf >> 8;
	}
	int prob = probs[index];
	int bit = (state & 0xff) < prob ? 1 : 0;
	if (bit)
		state = prob * (state >> 8) + (state & 0xff);
	else
		state = (256 - prob) * (state >> 8) + (state & 0xff) - prob;
	probs[index] = prob + (bit << 4) - ((prob + 8) >> 4);
	return bit;
}

static uint16_t getLen(int index)
{
	uint16_t len = 0x8000;
	for (; !getBit(index); index += 2)
		len = len >> 1 | getBit(index + 1) << 15;
	len = len >> 1 | 0x8000;
	while ((len & 1) == 0)
		len >>= 1;
	return len >> 1;
}

size_t unupkr(uint8_t *unpacked, const uint8_t *packed)
{
	src = packed;
	uint8_t *dest = unpacked;
	state = 0;
	bitBuf = 0x80;
	memset(probs, 0x80, sizeof(probs));

	bool wasLiteral = true;
	int offset = 0;
	for (;;) {
		if (getBit(0)) {
			if (!wasLiteral || !getBit(256)) {
				offset = getLen(257) - 1;
				if (offset == 0)
					return dest - unpacked;
			}
			uint16_t length = getLen(257 + OFFSET_PROBS);
			do {
				*dest = dest[-offset];
				dest++;
			} while (--length > 0);
			wasLiteral = false;
		}
		else {
			uint16_t literal = 1;
			while (literal < 0x100)
				literal = literal << 1 | getBit(literal);
			*dest++ = literal;
			wasLiteral = true;
		}
	}
}

int main(int argc, char** argv)
{
	uint8_t packed[65536];
	FILE *f = fopen(argv[1], "rb");
	fread(packed, 1, sizeof(packed), f);
	fclose(f);

	uint8_t unpacked[65536];
	size_t unpacked_len = unupkr(unpacked, packed);

	f = fopen(argv[2], "wb");
	fwrite(unpacked, 1, unpacked_len, f);
	fclose(f);
	return 0;
}
