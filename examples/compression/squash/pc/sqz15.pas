// SQUASH V1.5 (29.11.2008) Tebe/Madteam
// kompresja wszystkich bajtow metoda Huffmana

// Free Pascal Compiler, http://www.freepascal.org/
// Compile: fpc -Mdelphi -vh -O3 sqz15.pas

// SQZ
// 0..15	naglowek
// 16..143	256 4-bitowych (nibbli) dlugosci kodow symboli, 1 bajt = 2 nibble
// 144..	spakowane dane, bez dodatkowych bitow sterujacych

// dekompresja polega na odtworzeniu drzewa na podstawie dlugosci kodow symboli


uses crt, sysutils;

var f: file;
    m: file of byte;
    
    err: word;
    
    p, a1,a2,a3,a4,stc0,stc1: integer;
    bit,all,ln,lnght,adres: integer;
    i,j,d,l,a,x,s, tre_i,hea_, tmp: integer;
    cut: byte;
    buf: array [0..256*1024] of byte;
    
    tab: array [0..255] of record
                            l: byte;
                            v: word;
                           end;
                           
    v: array [0..7] of byte;
    
    huf: array [0..256] of record
                            l: integer;
                            v: word;
                           end;
                           
    tre01: array [0..511] of word;
    
    pom: array [0..15] of byte;

    nam, map, hea, inp: string;

const
     msk:array [1..16] of word=
     ($8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100,$0080,$0040,$0020,
      $0010,$0008,$0004,$0002,$0001);

     head=16;


function _lo(a: integer): byte;
begin
 Result:=(a and $ff);
end;

function _hi(a: integer): byte;
begin
 Result:=(a shr 8) and $ff;
end;


procedure sav(b:byte);
begin
 write(m,b);
 inc(lnght);
end;

function bajt2: byte;
begin
  bajt2:=$80*v[0]+$40*v[1]+$20*v[2]+$10*v[3]+8*v[4]+4*v[5]+2*v[6]+v[7];
  fillchar(v,sizeof(v),0);
end;

procedure savbit(o:word;ol:byte);    { zapisz N bitow }
var i:byte;
begin
for i:=0 to ol-1 do begin
  v[s]:=(o and $8000) shr 15; o:=o shl 1; inc(s);
   if s>7 then begin sav(bajt2); s:=0; inc(j); end;
 end;
end;


procedure min(max_: integer);
begin                    {p - minimum   err - indeks wartosci}
 p:=$ffffff; err:=$100;
 
 for a:=0 to max_-1 do begin
  if (huf[a].l<p) and (huf[a].l<>0) then begin p:=huf[a].l; err:=a; end;
 end;
 
end;


procedure sort(max_s:integer);
begin
{
dlugosci kodow do tablicy zapasowej tre01
aby potem przywrocic stare uporzadkowanie
}
for a:=0 to max_s-1 do begin tre01[a]:=a; tre01[a+256]:=huf[a].l; end;

{ B U B B L E  sort za wolna, zastapila ja VFAST}
{
for i:=0 to max_s-1 do begin
 for j:=0 to max_s-1 do begin
  if tre01[i+256]<tre01[j+256] then begin
   p:=tre01[i+256]; tre01[i+256]:=tre01[j+256]; tre01[j+256]:=p;
   p:=tre01[i]; tre01[i]:=tre01[j]; tre01[j]:=p;
  end;
 end;
end;
}

{ V F A S T }

l:=0;
for j:=0 to 15 do begin
 for i:=0 to max_s-1 do begin
  if tre01[i+256]=j then begin tre01[l]:=i; inc(l); end;
 end;
end;

for i:=0 to 15 do pom[i]:=0;
 for i:=0 to max_s-1 do inc(pom[tre01[i+256]]);
l:=0;
 for i:=0 to 15 do begin
  for j:=1 to pom[i] do begin
   tre01[l+256]:=i; inc(l);
  end;
 end;

{for a:=0 to 63 do writeln(tre01[a+256],',',tre01[a]);halt;}
end;


{
generujemy kody na podstawie danych dlugosci bitow
}

{**** S H A N N O N - F A N O ****}

procedure fano(max_i:integer);
begin

sort(max_i);  { sortujemy dlugosci bitow }
p:=0;         { code }
err:=0;       { code increment }
l:=0;         { last bit length }

for i:=max_i-1 downto 0 do begin

 if tre01[i+256]<>0 then begin
 p:=p+err;
  if tre01[i+256]<>l then begin l:=tre01[i+256]; err:=msk[l]{1 shl (16-l);} end;
  huf[tre01[i]].v:=p xor $ffff; huf[tre01[i]].l:=tre01[i+256];
 end;
end;

end;




{
huf.l - liczba wystepowan danego elementu /T
huf.v - kod elementu /T
tre01 - lewy i prawy lisc galezi /T
tre_i - indeks nowej galezi w drzewie /W
p     - wartosc minimalna liczby wystepowan elementu /W
err   - indeks wartosci minimalnej /W
j     - wysokosc drzewka /W
}

{**** H U F F M A N ****}

procedure hufman(max_h:integer);
begin

tre_i:=0;
err:=0;
fillchar(tre01,sizeof(tre01),0);
for a:=0 to 255 do huf[a].v:=a;        { huf.v - wartosci 0..255 }
                                       { huf.l - ilosc danego elementu }
{* TWORZENIE DRZEWKA *}                { stc0,p - wartosc min }
while err<>$100 do begin               { stc1,err - indeks min w huf.l}
min(max_h); stc0:=p; stc1:=err; huf[err].l:=0;        { 1 wartosc minimalna }
min(max_h); huf[err].l:=0;                            { 2 wartosc minimalna }

tre01[tre_i]:=huf[stc1].v;             { nowa galaz }
tre01[tre_i+1]:=huf[err].v;
huf[stc1].l:=stc0+p;            { nowa liczba elementow, suma 1 i 2 minimum }
huf[stc1].v:=tre_i div 2+$100; inc(tre_i,2);             { wpisz kod galezi }
end;

dec(tre_i,2); j:=tre_i div 2;          { wysokosc drzewka(j) }

{* SZUKANIE KOMBINACJI BITOW W DRZEWKU *}
for x:=0 to max_h-1 do begin
a:=x;
i:=0;
l:=0;
err:=$8000;      { kod bitowy 10000... }
huf[x].v:=0;

while (i div 2)<j do begin
 while (tre01[i]<>a) and (i<tre_i) do inc(i);
 if i<tre_i then begin
  huf[x].v:=huf[x].v or (i and 1)*err; err:=err shr 1;
{  write(i and 1);}
  inc(l); if l>15 then begin writeln('Fatal error!'); halt; end;  { ???? }
  a:=(i div 2)+$100;
 end;
end;

huf[x].l:=l;               { dlugosc kodu w bitach }
end;

{ wyjatek gdy j=0 czyli w drzewku wystapil tylko jeden element }
{ wstawiamy dodatkowy element (xor $ff) aby depacker zadzialal }
 if j=0 then begin huf[stc1].l:=1; huf[stc1 xor $ff].l:=1; end;
end;




{ M A I N }
begin
all:=0;

writeln('SQUASH V1.5 by MADTEAM (1997-2008)');

if paramcount<1 then begin
writeln('Usage: SQZ [file] [hex adres, -u]');
writeln('[-c] cut 6byte of source file (header)');
writeln('[hex adres] create DOS file');
halt;
end;

inp:=paramstr(1);
nam:=paramstr(2);
cut:=0; if nam='-c' then cut:=1;

hea_:=1; if (nam='-c') or (nam='') then hea_:=0;

{* zamienia txt na adres hex *}
if hea_=1 then begin
adres:=0; d:=1;
for i:=length(nam) downto 1 do begin
 val(nam[i],j,p);
 case nam[i] of
  'a','A':j:=10;
  'b','B':j:=11;
  'c','C':j:=12;
  'd','D':j:=13;
  'e','E':j:=14;
  'f','F':j:=15;
 end;
adres:=adres+j*d; d:=d*16;
end;
end;


map:=inp;

nam:=map; delete(nam,pos('.',nam),4);

fillchar(buf,sizeof(buf),0);

if not(FileExists(map)) then begin write('File "',map,'" not found.'#13#10); halt; end;


assignfile(m, nam+'.sqz'); rewrite(m);   { Open to write SQZ file }

assignfile(f,map); reset(f,1);           { Load }

if FileSize(f)>sizeof(buf) then begin write('File to long.'); halt; end;

if cut<>0 then blockread(f,buf,6,err);

blockread(f,buf,sizeof(buf), ln);
closefile(f);

if cut<>0 then dec(ln, 6);


lnght:=0;

{ **** all **** }
d:=ln;
fillchar(huf,sizeof(huf),0); for a:=0 to d-1 do inc(huf[buf[a]].l);
hufman(256);
 for a:=0 to 255 do tab[a].l:=huf[a].l; fano(256);
 for a:=0 to 255 do tab[a].v:=huf[a].v;
{j:=0; s:=0; for a:=0 to d-1 do savbit(huf[buf[a]].v,huf[buf[a]].l);
if s<>0 then begin sav(bajt2); inc(j); end; writeln(d,'-',j,'=',d-j);}

seek(m,head);                        { dlugosci kodow 4bit'owe }
s:=0; for a:=0 to 255 do savbit(tab[a].l shl 12,4);


{ **** S A V E **** }
{ zapisujemy spakowany plik, bit prefiksu(0,1) - unpack lub ofset+len }
bit:=0;
for a:=0 to ln-1 do begin
  savbit(tab[buf[a]].v, tab[buf[a]].l);
  inc(bit, tab[buf[a]].l);
end;
if s<>0 then sav(bajt2);      { zapisz ostatnie bity }

{***** S T O R E D *****}
{if lnght>ln then begin
rewrite(m); seek(m,head); bit:=0;
 for a:=0 to ln-1 do begin write(m,buf[a]); inc(bit,8); end;
lnght:=ln; tmp:=0; a1:=0; a2:=head;
end;}


gotoxy(wherex,wherey); err:=wherex;
tmp:=100-round(((lnght+16)/ln)*100);                        { stopien kompresji }
writeln('File:',inp,'   Ratio:',tmp,'%','   Original:',ln,'   Packed:',lnght+16);

all:=all+bit;


seek(m,0);

{
0..2    PCK                                 3byte
3       stopien kompresji - 7bit            1byte /tmp
4..5    dlugosc danych przed kompresja      2byte /ln
6..7    dlugosc danych po kompresji         2byte /lnght
8..9    liczba znacznikow 1bitowych         2byte /a1
10..11  ofset do spakowanych danych         2byte /a2
12..13  ofset przesuniecia danych           2byte /a3

14..15  niewykorzystane

/dlugosci kodow dla 3 drzew - 4bit   288byte/
}

a2:=head+128;
a3:=ln-lnght-head+16;
a4:=0; a1:=0;                       { nieuzywane w tej wersji }

hea:='PCK'+chr(byte(tmp))+chr(_lo(ln))+chr(_hi(ln));
hea:=hea+chr(_lo(lnght-128))+chr(_hi(lnght-128));
hea:=hea+chr(_lo(a1))+chr(_hi(a1));
hea:=hea+chr(_lo(a2))+chr(_hi(a2));
hea:=hea+chr(_lo(a3))+chr(_hi(a3));
hea:=hea+chr(_lo(a4))+chr(_hi(a4));

for a:=1 to head do write(m, byte(hea[a]));

closefile(m);

assignfile(f,nam+'.sqz'); reset(f,1); ln:=filesize(f);
blockread(f,buf,ln,err); closefile(f);

assignfile(f,nam+'.sqz'); rewrite(f,1);

if hea_=1 then begin
 writeln('þ Save header');
 pom[0]:=$ff; pom[1]:=$ff;
 pom[2]:=_lo(adres+a3); pom[3]:=_hi(adres+a3);
 pom[4]:=_lo(adres+a3+ln-1); pom[5]:=_hi(adres+a3+ln-1);
 blockwrite(f,pom,6,err);
end;

blockwrite(f,buf,ln);

closefile(f);

end.