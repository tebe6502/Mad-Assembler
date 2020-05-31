
// RLE_ENCODER V1.2 (24.03.2010) by Tebe/Madteam

// Free Pascal Compiler, http://www.freepascal.org/
// fpc -Mdelphi -v -O3 rle.pas


program rle_encoder;

{$APPTYPE CONSOLE}

//uses
//  SysUtils;

var
  f: file;
  len: integer;

  buf: array [0..$FFFF+1] of byte;
  tmp: array [0..$FF] of byte;

  fsrc, fdst: string;


function IntToStr(const a: integer): string;
var t: string;
begin
 str(a, t);

 Result := t;
end;


procedure save_rle(const a, ile: byte);
begin
 tmp[0]:=(ile-1) shl 1;
 tmp[1]:=a;

 blockwrite(f,tmp,2);
end;


procedure save_str(var x: integer);
var a, i: byte;
begin

 i:=0;

 while (x<=len) and (i<=127) do begin

  a:=buf[x]; tmp[i]:=a;

  if (a=buf[x+1]) and (a=buf[x+2]) then Break;

  inc(x); inc(i);
 end;

 dec(i);

 a:=(i shl 1) or 1;

 blockwrite(f,a,1);
 blockwrite(f,tmp,i+1);
end;


procedure rle;
var licz, a: byte;
    old, x: integer;
begin

x:=0;

while x<=len do begin

  old:=x;
  a:=buf[x]; licz:=1; inc(x);

  while (a=buf[x]) and (x<=len) do begin
   inc(licz); inc(x);

   if licz=127 then Break;
  end;


  if licz>2 then
   save_rle(a,licz)
  else begin
   x:=old;
   save_str(x);
  end;

end;


a:=0; blockwrite(f,a,1);


writeln('RLE Compress: '+IntToStr(FileSize(f)));

closefile(f);

end;


procedure Syntax;
begin
 writeln('Compresses a file in the RLE format.');
 writeln('Usage: rle input_file rle_file');

 halt(2);
end;


begin

  if ParamCount=0 then Syntax;


  fsrc:=ParamStr(1);
  fdst:=ParamStr(2);

  if (fsrc='') or (fdst='') then Syntax;


  assignfile(f,fsrc); reset(f,1);

  if FileSize(f)>$FFFF then begin
   writeln('Max file size = 64kb.');
   closefile(f);
   exit;
  end;

  blockread(f,buf,sizeof(buf),len);
  closefile(f);

  buf[len]:=buf[len-1] xor $ff;

  dec(len);

//  if fdst='' then fdst:=ChangeFileExt(fsrc,'.rle');

  assignfile(f,fdst); rewrite(f,1);

  writeln('Load file: '+fsrc);
  writeln('File size: '+IntToStr(len+1));

  rle;

  halt(0);
end.
