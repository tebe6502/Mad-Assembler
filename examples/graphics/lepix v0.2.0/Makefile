MADS_FLAGS=-l -t 

SRCS=lepix.asx atari.asx \
	dl.asx dli.asx vbl.asx cursor.asx font.asx utils.asx zoom.asx \
	joy.asx keyboard.asx mouse.asx \
	io.asx menu.asx undo.asx \
	mod_cin.asx mod_mic.asx mod_inp.asx mod_hip.asx mod_tip.asx

TABS=$(SRCS:%.asx=%.tab)
LSTS=$(SRCS:%.asx=%.lst)

default: lepix.xex

lepix.xex: $(SRCS)
	mads $< -o:$@ $(MADS_FLAGS)

all_types: $(SRCS)
	mads lepix.asx -o:lepixmic.xex $(MADS_FLAGS) -d:GFX_MODE=1
	mads lepix.asx -o:lepixinp.xex $(MADS_FLAGS) -d:GFX_MODE=2
	mads lepix.asx -o:lepixcin.xex $(MADS_FLAGS) -d:GFX_MODE=3
	mads lepix.asx -o:lepixhip.xex $(MADS_FLAGS) -d:GFX_MODE=4
	mads lepix.asx -o:lepixtip.xex $(MADS_FLAGS) -d:GFX_MODE=5
	perl -pe 's/\x0a/\x9b/g;' README > READMExl

run: lepix.xex
	a8run $<

clean:
	$(RM) -f lepix.xex lepix???.xex \
		$(TABS) $(LSTS) \
		*.tab *.TAB *.lst *.LST *.lab *.LAB \
		*.MACRO* READMExl

src-zip:
	zip lepix-src.zip \
		$(SRCS) Makefile README LICENSE INSTALL

