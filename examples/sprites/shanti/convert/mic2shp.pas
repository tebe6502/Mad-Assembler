program mic2pmg;

{$APPTYPE CONSOLE}

uses
  SysUtils;

type
  tpmg = record p0,p1,p2,p3,m: byte end;

var
  pmg: array of tpmg;

const
  _width = 40;

  _ofset = 0;

  tand : array [0..7] of byte = ($80,$40,$20,$10,8,4,2,1);


procedure save_pmg(p0,p1,p2,p3, m: byte);
var i: integer;
begin

 i:=High(pmg);

 pmg[i].p0:=p0;
 pmg[i].p1:=p1;
 pmg[i].p2:=p2;
 pmg[i].p3:=p3;

 pmg[i].m:=m;


 SetLength(pmg, i+2);

end;


procedure cnv(fnam: string; gap: string = '0');
var f, i: integer;
    buf: array [0..47] of byte;
    m, p0,p1,p2,p3: byte;
    vgap: byte;
begin

 val(gap, vgap, i);

 vgap:=vgap shl 1;		// skip columns


 f:= FileOpen(fnam, fmOpenRead);
 FileSeek(f, 0, 0);

 while true do begin

  i:=FileRead(f, buf, _width);

  if i<>_width then Break;

// Player 0
  p0:=0;

  if buf[_ofset + vgap] and $40<>0 then p0:=p0 or $80;
  if buf[_ofset + vgap] and $10<>0 then p0:=p0 or $40;
  if buf[_ofset + vgap] and $04<>0 then p0:=p0 or $20;
  if buf[_ofset + vgap] and $01<>0 then p0:=p0 or $10;

  if buf[_ofset + vgap + 1] and $40<>0 then p0:=p0 or 8;
  if buf[_ofset + vgap + 1] and $10<>0 then p0:=p0 or 4;
  if buf[_ofset + vgap + 1] and $04<>0 then p0:=p0 or 2;
  if buf[_ofset + vgap + 1] and $01<>0 then p0:=p0 or 1;

// Player 1
  p1:=0;

  if buf[_ofset + vgap] and $80<>0 then p1:=p1 or $80;
  if buf[_ofset + vgap] and $20<>0 then p1:=p1 or $40;
  if buf[_ofset + vgap] and $08<>0 then p1:=p1 or $20;
  if buf[_ofset + vgap] and $02<>0 then p1:=p1 or $10;

  if buf[_ofset + vgap + 1] and $80<>0 then p1:=p1 or 8;
  if buf[_ofset + vgap + 1] and $20<>0 then p1:=p1 or 4;
  if buf[_ofset + vgap + 1] and $08<>0 then p1:=p1 or 2;
  if buf[_ofset + vgap + 1] and $02<>0 then p1:=p1 or 1;

   p2:=0;
   p3:=0;
   m:=0;

{
// Player 2
  p2:=0;

  if buf[_ofset + vgap+2] and $40<>0 then p2:=p2 or $80;
  if buf[_ofset + vgap+2] and $10<>0 then p2:=p2 or $40;
  if buf[_ofset + vgap+2] and $04<>0 then p2:=p2 or $20;
  if buf[_ofset + vgap+2] and $01<>0 then p2:=p2 or $10;

  if buf[_ofset + vgap+3] and $40<>0 then p2:=p2 or 8;
  if buf[_ofset + vgap+3] and $10<>0 then p2:=p2 or 4;
  if buf[_ofset + vgap+3] and $04<>0 then p2:=p2 or 2;
  if buf[_ofset + vgap+3] and $01<>0 then p2:=p2 or 1;

// Player 3
  p3:=0;

  if buf[_ofset + vgap+2] and $80<>0 then p3:=p3 or $80;
  if buf[_ofset + vgap+2] and $20<>0 then p3:=p3 or $40;
  if buf[_ofset + vgap+2] and $08<>0 then p3:=p3 or $20;
  if buf[_ofset + vgap+2] and $02<>0 then p3:=p3 or $10;

  if buf[_ofset + vgap+3] and $80<>0 then p3:=p3 or 8;
  if buf[_ofset + vgap+3] and $20<>0 then p3:=p3 or 4;
  if buf[_ofset + vgap+3] and $08<>0 then p3:=p3 or 2;
  if buf[_ofset + vgap+3] and $02<>0 then p3:=p3 or 1;

// Missiles
  m:=0;

  if buf[_ofset + vgap+4] and $40<>0 then m:=m or $02;
  if buf[_ofset + vgap+4] and $10<>0 then m:=m or $01;

  if buf[_ofset + vgap+4] and $80<>0 then m:=m or $08;
  if buf[_ofset + vgap+4] and $20<>0 then m:=m or $04;

  if buf[_ofset + vgap+4] and $04<>0 then m:=m or $20;
  if buf[_ofset + vgap+4] and $01<>0 then m:=m or $10;

  if buf[_ofset + vgap+4] and $08<>0 then m:=m or $80;
  if buf[_ofset + vgap+4] and $02<>0 then m:=m or $40;
}
  save_pmg(p0,p1,p2,p3, m);

 end;

 FileClose(f);
end;


procedure SavePMG(fnam: string);
var i, j, y, s, k: integer;
   // txt: textfile;
begin

 fnam:=ChangeFileExt(fnam,'.asm');

// assignfile(txt, fnam); rewrite(txt);

 s:=0;

 for k:=0 to 7 do begin

	writeln();
	writeln('.local'#9,'shp',k);

	writeln(#13#10'_01');

	for i:=0 to 255 do begin

		for j:=0 to 15 do
			if (pmg[s + j].p0 = i) or (pmg[s + j].p1 = i) then begin
				writeln(#9'lda #',i);

				for y:=0 to 15 do begin
					if (pmg[s + y].p0 = i) then writeln(#9'sta sprites+$400+',y,',x');
					if (pmg[s + y].p1 = i) then writeln(#9'sta sprites+$500+',y,',x');
				end;

				Break;
			end;

	end;

	writeln();
	writeln(#9'jmp multi.ret01');

	writeln(#13#10'_23');

	for i:=0 to 255 do begin

		for j:=0 to 15 do
			if (pmg[s + j].p0 = i) or (pmg[s + j].p1 = i) then begin
				writeln(#9'lda #',i);

				for y:=0 to 15 do begin
					if (pmg[s + y].p0 = i) then writeln(#9'sta sprites+$600+',y,',x');
					if (pmg[s + y].p1 = i) then writeln(#9'sta sprites+$700+',y,',x');
				end;

				Break;
			end;

	end;

	writeln();
	writeln(#9'jmp multi.ret23');

	writeln('.endl');

	inc(s, 16);
 end;

// closefile(txt);
end;



begin

 SetLength(pmg, 1);

 if ParamCount > 1 then
  cnv(ParamStr(1), ParamStr(2))
 else
  cnv(ParamStr(1));

 SavePMG(ParamStr(1));

 SetLength(pmg, 1);

end.
