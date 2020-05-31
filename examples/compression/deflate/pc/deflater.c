/* deflater - compress in the DEFLATE format
   by Piotr Fusik <fox@scene.pl>
   Last modified: 2007-06-17
   
   Compile using:
   gcc -s -O2 -o deflater deflater.c -lz */

#include <stdio.h>
#include <zlib.h>

int main(int argc, char *argv[])
{
	FILE *fp;
	static char inbuf[63000];
	static char outbuf[63000];
	size_t inlen;
	size_t outlen;
	z_stream stream;

	if (argc != 3) {
		fprintf(stderr,
			"Compresses a file in the DEFLATE format.\n"
			"Usage: deflater input_file deflated_file\n"
		);
		return 1;
	}

	fp = fopen(argv[1], "rb");
	if (fp == NULL) {
		perror(argv[1]);
		return 1;
	}
	inlen = fread(inbuf, 1, sizeof(inbuf), fp);
	fclose(fp);

	stream.next_in = inbuf;
	stream.avail_in = inlen;
	stream.next_out = outbuf;
	stream.avail_out = sizeof(outbuf);
	stream.zalloc = (alloc_func) 0;
	stream.zfree = (free_func) 0;
	if (deflateInit2(&stream, Z_BEST_COMPRESSION, Z_DEFLATED,
		-MAX_WBITS, 9, Z_DEFAULT_STRATEGY) != Z_OK) {
		fprintf(stderr, "deflater: deflateInit2 failed\n");
		return 1;
	}
	if (deflate(&stream, Z_FINISH) != Z_STREAM_END) {
		fprintf(stderr, "deflater: deflate failed\n");
		return 1;
	}
	if (deflateEnd(&stream) != Z_OK) {
		fprintf(stderr, "deflater: deflateEnd failed\n");
		return 1;
	}

	fp = fopen(argv[2], "wb");
	if (fp == NULL) {
		perror(argv[2]);
		return 1;
	}
	outlen = fwrite(outbuf, 1, stream.total_out, fp);
	fclose(fp);
	if (outlen != stream.total_out) {
		perror(argv[2]);
		return 1;
	}

	printf("Compressed %s (%d bytes) to %s (%d bytes)\n",
		argv[1], inlen, argv[2], outlen);
	return 0;
}
