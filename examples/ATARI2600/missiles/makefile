MADS=${HOME}/Programs/mads/mads
CAR=/dev/shm/missiles.a26
ASM=main.asm

all: compile run

compile:
	rm -f $(CAR)
	$(MADS) $(ASM) -x -o:$(CAR)

run:
	stella $(CAR)

save:
	cp $(CAR) .
