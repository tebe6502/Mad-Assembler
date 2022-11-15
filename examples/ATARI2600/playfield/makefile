MADS=${HOME}/Programs/mads/mads
CAR=/dev/shm/playfield.a26
ASM=main.asm

all: compile run

compile:
	rm -f $(CAR)
	$(MADS) $(ASM) -x -o:$(CAR)

run:
	stella $(CAR)

save:
	cp $(CAR) .
