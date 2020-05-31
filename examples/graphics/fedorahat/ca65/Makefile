CL65=cl65
CA65=ca65
CL65FLAGS=-g -t atari -C atari-asm.cfg
CA65FLAGS=-g -t atari

PROGS=\
      fedora.xex

OBJS=\
     atari-header.o\
     fedora.o\
     plot.o\
     math.o\

all: $(PROGS)

%.xex: $(OBJS)
	$(CL65) -o $@ $(CL65FLAGS) $^ -m $(@:.xex=.map) -Ln $(@:.xex=.lbl)

%.o: %.s
	$(CA65) -o $@ $(CA65FLAGS) $<

clean:
	-rm -f $(OBJS) $(PROGS) $(PROGS:.xex=.o) $(PROGS:.xex=.map) $(PROGS:.xex=.lbl)

