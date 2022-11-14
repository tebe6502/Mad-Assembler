MADS=${HOME}/Programs/mads/mads
CRT=/dev/shm/rainbow.a28
ASM=main.asm

all: compile run

compile:
	rm -f $(CRT)
	$(MADS) $(ASM) -x -o:$(CRT)

run:
	stella $(CRT)

save:
	cp $(CRT) .
