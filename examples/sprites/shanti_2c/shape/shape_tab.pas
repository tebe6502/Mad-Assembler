uses crt;


var f: file;

    bf: array [0..255] of byte;

    dt: array [0..16*256-1] of byte;

    err: smallint;

    i, j: integer;




begin

assign(f, 'shape.obx'); reset(f, 1);
blockread(f, bf, sizeof(bf), err);
closefile(f);


for j:=0 to 15 do begin

 dt[$0000+j]:=bf[j*16];
 dt[$0100+j]:=bf[j*16+1];
 dt[$0200+j]:=bf[j*16+2];
 dt[$0300+j]:=bf[j*16+3];
 dt[$0400+j]:=bf[j*16+4];
 dt[$0500+j]:=bf[j*16+5];
 dt[$0600+j]:=bf[j*16+6];
 dt[$0700+j]:=bf[j*16+7];
 dt[$0800+j]:=bf[j*16+8];
 dt[$0900+j]:=bf[j*16+9];
 dt[$0a00+j]:=bf[j*16+10];
 dt[$0b00+j]:=bf[j*16+11];
 dt[$0c00+j]:=bf[j*16+12];
 dt[$0d00+j]:=bf[j*16+13];
 dt[$0e00+j]:=bf[j*16+14];
 dt[$0f00+j]:=bf[j*16+15];

end;



assign(f, 'shape.bin'); rewrite(f, 1);
blockwrite(f, dt, sizeof(dt), err);
closefile(f);


end.