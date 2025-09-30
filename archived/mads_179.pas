(*----------------------------------------------------------------------------*)
(*  Mad-Assembler by Tomasz Biela (aka Tebe/Madteam)                          *)
(*                                                                            *)
(*  support 6502, 65816, Sparta DOS X, virtual banks                          *)
(*  .LOCAL, .MACRO, .PROC, .STRUCT, .ARRAY, .REPT, .PAGES, .WHILE, .TEST      *)
(*                                                                            *)
(*  last changes: 30.11.2007                                                  *)
(*----------------------------------------------------------------------------*)

// Free Pascal Compiler, http://www.freepascal.org/
// fpc -Mdelphi -v -O3 mads.pas

program MADS;

{$APPTYPE CONSOLE}

//uses SysUtils;

type

    _typStrREG = string [4];
    _typStrSMB = string [8];
    _typStrINT = string [16];

    _argArray  = array [0..31] of byte;

    _strArray  = array of string;
    _intArray  = array of integer;
    _carArray  = array of cardinal;

    labels  = record
                nam: cardinal;    // identyfikator etykiety (CRC32)
                adr: cardinal;    // wartosc etykiety
                ofs: integer;     // wartosc etykiety przed zmiana adresu asemblacji
                len: integer;     // dlugosc etykiety w bajtach <1..65535>
                bnk: word;        // licznik wirtualnych bankow przypisany do etykiety <0..$FF>, na potrzeby MADS'a jest on typu WORD
                blk: integer;     // blok przypisany etykiecie
                rel: Boolean;     // czy relokowac
                lln: integer;     // dlugosc bloku .LOCAL
                pas: byte;        // numer przebiegu dla danej etykiety
                typ: char;
              end;

    wywolyw = record
                 zm: string;      // wiersz listingu
                 pl: string;      // nazwa pliku ktorego zawartosc asemblujemy
                 nr: integer;     // numer linii listingu
              end;

    stosife = record
                _elseif: Boolean; // czy wystapilo .ELSEIF
               _if_test: Boolean; // stan IF_TEST
                  _else: Boolean; // czy wystapilo .ELSE
                _okelse: integer; // numer aktualnego poziomu .IF
              end;

   relocLab = record
                adr: integer;     // adres relokowalny
                idx: integer;     // indeks do T_SMB lub T_SIZ
                blk: integer;     // numer segmentu
                blo: integer;     // numer bloku
                bnk: word;        // bank
              end;

   relocSmb = record
                smb: _typStrSMB;  // 8 znakowy symbol SMB dla systemu SDX
                use: Boolean;     // czy w programie nastapilo odwolanie do symbolu
              end;

   extLabel = record
               adr: cardinal;     // adres pod ktorym wystapila etykieta external
               bnk: word;         // bank w ktorym wystapila etykieta external
               idx: integer;      // index do T_EXT
              end;

   usingLab = record
               lok: integer;      // nr poziomu lokalnego
               lab: string;       // etykieta
              end;

   pubTab   = record
               nam: string;       // nazwa etykiety publicznej
               typ: Boolean;      // aktualny adres asemblacji
              end;

   mesTab   = record
               pas: byte;         // numer przebiegu
               mes: string;       // tresc komunikatu bledu
              end;

   locTab   = record
               nam: string;       // nazwa bloku .LOCAL
               adr: integer;      // aktualny adres asemblacji
               idx: integer;      // indeks do tablicy T_LAB
               ofs: integer;      // poprzedni adres asemblacji
              end;

   arrayTab = record
                adr: cardinal;    // adres tablicy
                bnk: word;        // bank przypisany tablicy
                idx: integer;     // maksymalny index tablicy
                siz: byte;        // wielkosc pola tablicy B-YTE, W-ORD, L-ONG, D-WORD
                len: integer;     // dlugosc tablicy w bajtach
                ofs: integer;
              end;

   varTab   = record
               lok: integer;      // nr poziomu lokalnego
               nam: string;       // nazwa zmiennej
               siz: byte;         // rozmiar zmiennej
               cnt: integer;      // wielokrotnosc rozmiaru zmiennej
               war: cardinal;     // wartosc poczatkowa zmiennej
               adr: integer;      // adres zmiennych jesli zostal okreslony
                id: integer;      // identyfikator grupy etykiet deklarowanych przez .VAR w tym samym bloku
              end;

   stctTab  = record
                 id: integer;     // numer struktury (identyfikator)
                 no: integer;     // numer pozycji w strukturze (-1 gdy nie sa to pola struktury)
                adr: cardinal;    // adres struktury
                bnk: word;        // bank przypisany strukturze
                idx: integer;     // index do dodatkowej struktury
                ofs: integer;     // ofset od poczatku struktury
                siz: integer;     // rozmiar danych definiowanych przez pole struktury 1..4 (B-YTE..D-WORD)
                                  // lub calkowita dlugosc danych definiowanych przez strukture
                rpt: integer;     // liczba powtorzen typu SIZ (SIZ*RPT = rozmiar calkowity pola)
                lab: string;      // etykieta wystepujaca w .STRUCT
              end;

    procTab = record
                nam: string;      // nazwa procedury .PROC
                str: integer;     // indeks do T_MAC z nazwami parametrow
                adr: cardinal;    // adres procedury
                ofs: integer;
                bnk: word;        // bank przypisany procedurze
                par: integer;     // liczba parametrow procedury
                ile: integer;     // liczba bajtow zajmowana przez parametry procedury
                typ: char;        // typ procedury __pDef, __pReg
                reg: byte;        // kolejnosc rejestrow CPU
                use: Boolean;     // czy procedura zostala uzyta w programie, czy pominac ja podczas asemblacji
                len: cardinal;    // dlugosc procedury w bajtach
              end;

    pageTab = record
                adr: integer;     // poczatkowa strona pamieci
                cnt: integer;     // liczba stron pamieci
              end;

    rSizTab = record
               siz: char;
               msb: byte;
              end;

    endTab  = record
               kod: byte;
               adr: integer;
               old: integer;
              end;

   extName  = record
                nam: string;      // nazwa etykiety external
                siz: char;        // zadeklarowany rozmiar etykiety od 1..4 bajtow
                prc: Boolean;     // czy etykieta external jest deklaracja procedury
              end;

    heaMad  = record
               nam: string;       // nazwa etykiety
               adr: cardinal;     // adres przypisany etykiecie
               bnk: byte;         // bank przypissany etykiecie
               typ: char;         // typ etykiety (P-procedura, V-zmienna, C-stala)
               idx: integer;      // index do tablicy T_PRC gdy etykiecie external przypisano procedure
              end;

    int5    = record              // nowy typ dla OBLICZ_MNEMONIK
                 l: byte;         // liczba bajtow skladajaca sie na rozkaz CPU
                 h: _argArray;    // argumenty rozkazu
                 i: integer;      // ofset do tablic
               tmp: byte;         // bajt pomocniczy
              end;

    relVal  = record
               use: Boolean;
               cnt: integer;
              end;


    _bckAdr = array [0..1] of integer;

    c64kb   = array [0..$FFFF] of cardinal;
    m64kb   = array [0..$FFFF] of byte;
    m4kb    = array [0..4095] of byte;
    t256i   = array [0..255] of integer;
    t256c   = array [0..255] of cardinal;

var lst, lab, hhh, mmm: textfile;
    dst: file;

    label_type: char = 'V';

    pass, status, memType: byte;

    bank: word;

    __link_stack_pointer_old, __link_stack_address_old, __link_proc_vars_adr_old: cardinal;
    __link_stack_pointer, __link_stack_address, __link_proc_vars_adr, optdef: cardinal;
    opt : cardinal = 3;         // OPT default value

    blok, proc_lokal: integer;
    whi_idx, while_nr, ora_nr, test_nr, test_idx, sym_idx, org_ofset: integer;
    hea_i, rel_ofs, struct_idx, wyw_idx, struct_id, array_idx, buf_i: integer;
    proc_nr, lc_nr, lokal_nr, rel_idx, smb_idx, var_id, usi_idx: integer;
    line, line_err, line_all, line_add, ___rept_ile, {org_ofs,} ext_idx, extn_idx: integer;
    pag_idx, end_idx, pub_idx, var_idx, struct_adres, ifelse, ds_empty: integer;
    siz_idx    : integer = 1;
    struct_cnt : integer = -1;
    adres      : integer = -$FFFF;

    nul : int5;

    while_name, test_name: string;
    path, name, t, global_name, proc_name, def_label, str_blad: string;
    end_string, plik_h, plik_hm, plik_lst, plik_obj: string;
    plik_lab, plik_mac, plik_asm, macro_nr, lokal_name: string;

    struct_used : record
                   use: Boolean;     // czy powstala struktura danych
                   idx: integer;     // index do struktury zalozyciela
                   cnt: integer;     // licznik pozycji struktury
                  end;

    array_used  : record
                   idx: integer;
                   typ: char;
                  end;

    ext_used    : record
                   use: Boolean;
                   idx: integer;
                   siz: char;
                  end;

    dreloc      : record
                   use: Boolean;     // czy wystapila dyrektywa .RELOC
                   sdx: Boolean;     // czy wystapil pseudo rozkaz BLK SPARTA
                   siz: char;        // rozmiar etykiety
                  end;

    dlink       : record
                   use: Boolean;     // czy linkujemy blok z adresem ladowania $0000
                   stc: Boolean;     // czy sprawdzalismy adresy stosu
                   len: integer;     // dlugosc bloku linkowanego
                   emp: integer;     // dlugosc pustego bloku
                  end;

    skip        : record
                   use: Boolean;     // czy zostal wywolany pseudorozkaz skoku
                   xsm: Boolean;     // czy wystapilo laczenie mnemonikow w stylu XASM-a
                   hlt: Boolean;     // blokada TEST_SKIPA jesli przetwarzamy makra rozdzielone znakiem ':'
                   idx: integer;     // indeks do tablicy T_SKP
                   cnt: byte;        // liczba odlozonych adresow w przod
                  end;

    blkupd      : record
                   adr: Boolean;     // czy wystapilo BLK UPDATE ADDRESS
                   ext: Boolean;     // czy wystapilo BLK UPDATE EXTERNAL
                   pub: Boolean;     // czy wystapilo BLK UPDATE PUBLIC
                   sym: Boolean;     // czy wystapilo BLK UPDATE SYMBOL
                   new: Boolean;     // czy wystapilo BLK UPDATE NEW SYMBOL
                  end;

    binary_file : record
                   use: Boolean;
                   adr: integer;
                  end;

    raw          : record
                    use: Boolean;
                    old: integer;
                   end;

    hea_ofs      : record
                    adr: integer;
                    old: integer;
                   end;


    variable    : Boolean = false;
    klamra_used : Boolean = false;
    noWarning   : Boolean = false;
    lst_off     : Boolean = false;
    macro       : Boolean = false;
    labFirstCol : Boolean = false;
    test_symbols: Boolean = false;
    overflow    : Boolean = false;
    blokuj_zapis: Boolean = false;
    FOX_ripit   : Boolean = false;
    blocked     : Boolean = false;
    rel_used    : Boolean = false;
    sav_lab_no  : Boolean = false;
    put_used    : Boolean = false;
    exclude_proc: Boolean = false;
    mne_used    : Boolean = false;
    data_out    : Boolean = false;
    aray        : Boolean = false;
    white_spaces: Boolean = true;
    dta_used    : Boolean = false;
    struct      : Boolean = false;
    pisz        : Boolean = false;
    rept        : Boolean = false;
    rept_run    : Boolean = false;
    empty       : Boolean = false;
    reloc       : Boolean = false;
    branch      : Boolean = false;
    vector      : Boolean = false;
    silent      : Boolean = false;
    bez_lst     : Boolean = false;
    icl_used    : Boolean = false;
    komentarz   : Boolean = false;
    case_used   : Boolean = false;
    full_name   : Boolean = false;
    else_used   : Boolean = false;
    elseif_used : Boolean = false;
    proc        : Boolean = false;
    run_macro   : Boolean = false;
    loop_used   : Boolean = false;
    org         : Boolean = false;
    over        : Boolean = false;
    open_ok     : Boolean = false;
    list_lab    : Boolean = false;
    list_hhh    : Boolean = false;
    list_mmm    : Boolean = false;
    list_mac    : Boolean = false;
    next_pass   : Boolean = false;

    regA        : Boolean = true; // rozmiar rejestrow dla OPT T+ (track sep rep)
    regX        : Boolean = true; // true = 8bit, false = 16bit
    regY        : Boolean = true;

    first_org   : Boolean = true;
    if_test     : Boolean = true;
    hea         : Boolean = true;

    analizuj_plik__   : procedure (var a:string; old_str:string);
    analizuj_mem__    : procedure (var start,koniec:integer; var old,a,old_str:string; const p_max:integer; const rp:Boolean);

    oblicz_mnemonik__ : function (var i:integer; var a,old:string): int5;
    ___wartosc_noSPC  : function (var zm,old:string; var i:integer; sep,typ:Char): Int64;


    imes:      t256i;
    tCRC16:    t256i;
    tCRC32:    t256c;

    // zmienna przechowujaca 2 adresy wstecz
    t_bck: _bckAdr;

    // hashowane mnemoniki i tryby adresowania
    hash: m64kb;

    // bufor dla dyrektywy .GET i .PUT
    t_get: m64kb;

    // bufor dla dyrektywy .LINK
    t_lnk: m64kb;

    // bufor dla wpisywanych danych do .ARRAY
    t_tmp: c64kb;

    // bufor dla odczytu plikow przez INS, maksymalna dlugosc pliku to 64KB
    t_ins: m64kb;

    // bufor pamieci dla zapisu
    t_buf: m4kb;

    // T_HEA zapamieta dlugosc bloku
    t_hea: _intArray;

    // tablica przechowujaca adres naprzod
    t_skp: _intArray;

    // T_LIN przechowuje polaczone znakiem '\' linie listingu (rozbite na wiersze)
    t_lin: _strArray;

    // T_MAC zapamieta linie z makrami, procedurami, petlami .REPT
    t_mac: _strArray;
    
    // T_PTH zapamieta sciezki poszukiwan dla INS i ICL
    t_pth: _strArray;

    // T_SYM zapamieta nowe symbole dla SDX (blk update new i_settd 'i_settd')
    t_sym: _strArray;

    // T_LOC zapamieta nazwy obszarow .LOCAL
    t_loc: array of locTab;

    // MESSAGES - komunikaty o bledach i ostrzezeniach
    messages: array of mesTab;

    // T_PUB zapamieta nazwy etykiet .PUBLIC
    t_pub: array of pubTab;

    // T_VAR zapamieta nazwy etykiet .VAR
    t_var: array of varTab;

    // T_END zapamieta kolejnosci wywolywania dyrektyw .MACRO, .PROC, .LOCAL, .STRUCT, .ARRAY itd.
    t_end: array of endTab;

    // T_SIZ zapamieta rozmiary argumentow
    t_siz: array of rSizTab;

    // T_MAD zapamieta etykiety dla pliku naglowkowego *.HEA (-hm)
    t_mad: array of heaMad;

    // T_PAG zapamieta paremetry dla dyrektywy .PAGE
    t_pag: array of pageTab;

    // T_USI zapamieta paremetry dla dyrektywy .USE [.USING]
    t_usi: array of usingLab;

    // T_EXT  zapamieta adresy wystapienia etykiet external
    // T_EXTN zapamieta deklaracje etykiet external
    t_ext: array of extLabel;
    t_extn: array of extName;

    // T_ARR zapamieta parametry tablic .ARRAY
    t_arr: array of arrayTab;

    // T_REL zapamieta relokowalne adresy etykiet SDX
    t_rel: array of relocLab;

    // T_SMB zapamieta relokowalne adresy symboli SDX
    t_smb: array of relocSmb;

    // T_PRC zapamieta parametry procedury .PROC
    t_prc: array of procTab;

    // T_LAB zapamieta etykiety
    t_lab: array of labels;

    // T_WYW zapamieta linie z wywolywanymi makrami, pomocne przy wyswietlaniu linii z bledem
    t_wyw: array of wywolyw;

    // T_STR zapamieta nazwy struktur .STRUCT
    t_str: array of stctTab;

    // stos dla operacji .IF .ELSE .ENDIF
    if_stos: array of stosife;


    pass_end : byte = 2;       // pass = <0..2>


 // komunikaty
 mes: array [0..2579] of char=(
{0}  chr(ord('V') + $80),'a','l','u','e',' ','o','u','t',' ','o','f',' ','r','a','n','g','e',
{1}  chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','I','F',
{2}  chr(ord('d') + $80),'e','c','l','a','r','e','d',' ','t','w','i','c','e',
{3}  chr(ord('S') + $80),'t','r','i','n','g',' ','e','r','r','o','r',
{4}  chr(ord('E') + $80),'x','t','r','a',' ','c','h','a','r','a','c','t','e','r','s',' ','o','n',' ','l','i','n','e',
{5}  chr(ord('U') + $80),'n','d','e','c','l','a','r','e','d',' ','l','a','b','e','l',' ',
{6}  chr(ord('N') + $80),'o',' ','m','a','t','c','h','i','n','g',' ','b','r','a','c','k','e','t',
{7}  chr(ord('N') + $80),'e','e','d',' ','p','a','r','e','n','t','h','e','s','i','s',
{8}  chr(ord('I') + $80),'l','l','e','g','a','l',' ','c','h','a','r','a','c','t','e','r',':',' ',
{9}  chr(ord('R') + $80),'e','s','e','r','v','e','d',' ','w','o','r','d',' ',
{10} chr(ord('N') + $80),'o',' ','O','R','G',' ','s','p','e','c','i','f','i','e','d',
{11} chr(ord('C') + $80),'P','U',' ','d','o','e','s','n','''','t',' ','h','a','v','e',' ','s','o',' ','m','a','n','y',' ','r','e','g','i','s','t','e','r','s',
{12} chr(ord('I') + $80),'l','l','e','g','a','l',' ','i','n','s','t','r','u','c','t','i','o','n',' ',

{13} chr(ord('V') + $80),'a','l','u','e',' ','o','u','t',' ','o','f',' ','r','a','n','g','e',

{14} chr(ord('I') + $80),'l','l','e','g','a','l',' ','a','d','d','r','e','s','s','i','n','g',' ','m','o','d','e',' ','(','C','P','U',' ','6','5',
{15} chr(ord('L') + $80),'a','b','e','l',' ','n','a','m','e',' ','r','e','q','u','i','r','e','d',
{16} chr(ord('I') + $80),'n','v','a','l','i','d',' ','o','p','t','i','o','n',
{17} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D',
{18} chr(ord('C') + $80),'a','n','n','o','t',' ','o','p','e','n',' ','o','r',' ','c','r','e','a','t','e',' ','f','i','l','e',
{19} chr(ord('N') + $80),'e','s','t','e','d',' ','o','p','-','c','o','d','e','s',' ','n','o','t',' ','s','u','p','p','o','r','t','e','d',
{20} chr(ord('M') + $80),'i','s','s','i','n','g',' ','''','}','''',
{21} chr(ord('B') + $80),'r','a','n','c','h',' ','o','u','t',' ','o','f',' ','r','a','n','g','e',' ','b','y',' ','$',
{22} chr(ord(' ') + $80),'b','y','t','e','s',
{23} chr(ord('U') + $80),'n','e','x','p','e','c','t','e','d',' ','e','n','d',' ','o','f',' ','l','i','n','e',
{24} chr(ord('F') + $80),'i','l','e',' ','i','s',' ','t','o','o',' ','s','h','o','r','t',
{25} chr(ord('F') + $80),'i','l','e',' ','i','s',' ','t','o','o',' ','l','o','n','g',
{26} chr(ord('D') + $80),'i','v','i','d','e',' ','b','y',' ','z','e','r','o',
{27} chr(ord('^') + $80),' ','n','o','t',' ','r','e','l','o','c','a','t','a','b','l','e',
{28} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','L','O','C','A','L',
{29} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','L',
{30} chr(ord('U') + $80),'s','e','r',' ','e','r','r','o','r',
{31} chr(ord('O') + $80),'p','e','r','a','n','d',' ','o','v','e','r','f','l','o','w',
{32} chr(ord('B') + $80),'a','d',' ','s','i','z','e',' ','s','p','e','c','i','f','i','e','r',
{33} chr(ord('S') + $80),'i','z','e',' ','s','p','e','c','i','f','i','e','r',' ','n','o','t',' ','r','e','q','u','i','r','e','d',
{34} chr(ord(' ') + $80),         // !!! zarezerwowane !!!  USER ERROR
{35} chr(ord('U') + $80),'n','d','e','c','l','a','r','e','d',' ','m','a','c','r','o',' ',
{36} chr(ord('C') + $80),'a','n','''','t',' ','r','e','p','e','a','t',' ','t','h','i','s',' ','d','i','r','e','c','t','i','v','e',
{37} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','I','F',
{38} chr(ord('L') + $80),'a','b','e','l',' ','n','o','t',' ','r','e','q','u','i','r','e','d',
{39} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','P','R','O','C',
{40} chr(ord('I') + $80),'m','p','r','o','p','e','r',' ','n','u','m','b','e','r',' ','o','f',' ','a','c','t','u','a','l',' ','p','a','r','a','m','e','t','e','r','s',
{41} chr(ord('I') + $80),'n','c','o','m','p','a','t','i','b','l','e',' ','t','y','p','e','s',' ',
{42} chr(ord('.') + $80),'E','N','D','I','F',' ','e','x','p','e','c','t','e','d',
{43} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','R',
{44} chr(ord('S') + $80),'M','B',' ','l','a','b','e','l',' ','t','o','o',' ','l','o','n','g',
{45} chr(ord('T') + $80),'o','o',' ','m','a','n','y',' ','b','l','o','c','k','s',
{46} chr(ord('B') + $80),'a','d',' ','p','a','r','a','m','e','t','e','r',' ','t','y','p','e',' ',
{47} chr(ord('B') + $80),'a','d',' ','p','a','r','a','m','e','t','e','r',' ','n','u','m','b','e','r',
{48} chr(ord(' ') + $80),'l','i','n','e','s',' ','o','f',' ','s','o','u','r','c','e',' ','a','s','s','e','m','b','l','e','d',
{49} chr(ord(' ') + $80),'b','y','t','e','s',' ','w','r','i','t','t','e','n',' ','t','o',' ','t','h','e',' ','o','b','j','e','c','t',' ','f','i','l','e',
{50} chr(ord('m') + $80),'a','d','s',' ','1','.','7','.','9',
{51} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','R','E','P','T',
{52} chr(ord('B') + $80),'a','d',' ','o','r',' ','m','i','s','s','i','n','g',' ','s','i','n','u','s',' ','p','a','r','a','m','e','t','e','r',
{53} chr(ord('O') + $80),'n','l','y',' ','R','E','L','O','C',' ','b','l','o','c','k',
{54} chr(ord('L') + $80),'a','b','e','l',' ','t','a','b','l','e',':',
{55} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','S','T','R','U','C','T',
{56} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','S',
{57} chr(ord('C') + $80),'a','n',' ','n','o','t',' ','u','s','e',' ','r','e','c','u','r','s','i','v','e',' ','s','t','r','u','c','t','u','r','e','s',
{58} chr(ord('I') + $80),'m','p','r','o','p','e','r',' ','s','y','n','t','a','x',
{59} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','A','R','R','A','Y',
{60} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','A',
{61} chr(ord('C') + $80),'P','U',' ','d','o','e','s','n','''','t',' ','h','a','v','e',' ','r','e','g','i','s','t','e','r',' ',
{62} chr(ord('C') + $80),'o','n','s','t','a','n','t',' ','e','x','p','r','e','s','s','i','o','n',' ','v','i','o','l','a','t','e','s',' ','s','u','b','r','a','n','g','e',' ','b','o','u','n','d','s',
{63} chr(ord('B') + $80),'a','d',' ','r','e','g','i','s','t','e','r',' ','s','i','z','e',
{64} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','P','A','G','E','S',
{65} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','P','G',
{66} chr(ord('I') + $80),'n','f','i','n','i','t','e',' ','r','e','c','u','r','s','i','o','n',
{67} chr(ord('D') + $80),'e','f','a','u','l','t',' ','a','d','d','r','e','s','s','i','n','g',' ','m','o','d','e',
{68} chr(ord('U') + $80),'n','k','n','o','w','n',' ','d','i','r','e','c','t','i','v','e',' ',
{69} chr(ord('U') + $80),'n','r','e','f','e','r','e','n','c','e','d',' ','p','r','o','c','e','d','u','r','e',' ',
{70} chr(ord('P') + $80),'a','g','e',' ','e','r','r','o','r',' ','a','t',' ',
{71} chr(ord('I') + $80),'l','l','e','g','a','l',' ','i','n','s','t','r','u','c','t','i','o','n',' ','a','t',' ','R','E','L','O','C',' ','b','l','o','c','k',
{72} chr(ord('U') + $80),'n','r','e','f','e','r','e','n','c','e','d',' ','d','i','r','e','c','t','i','v','e',' ','.','E','N','D',
{73} chr(ord('U') + $80),'n','d','e','f','i','n','e','d',' ','s','y','m','b','o','l',' ',
{74} chr(ord('I') + $80),'n','c','o','r','r','e','c','t',' ','h','e','a','d','e','r',' ','f','o','r',' ','t','h','i','s',' ','f','i','l','e',' ','t','y','p','e',
{75} chr(ord('I') + $80),'n','c','o','m','p','a','t','i','b','l','e',' ','s','t','a','c','k',' ','p','a','r','a','m','e','t','e','r','s',
{76} chr(ord('Z') + $80),'e','r','o',' ','p','a','g','e',' ','R','E','L','O','C',' ','b','l','o','c','k',
{77} chr(ord(' ') + $80),'(','B','A','N','K','=',        // od 77 kolejnosc wystapienia istotna
{78} chr(ord(' ') + $80),'(','B','L','O','K','=',
{79} chr(ord('L') + $80),'a','b','e','l',' ',
{80} chr(ord(')') + $80),' ','E','R','R','O','R',':',' ',
{81} chr(ord('0') + $80),'2',')',
{82} chr(ord('8') + $80),'1','6',')',
{83} chr(ord('O') + $80),'R','G',' ','s','p','e','c','i','f','i','e','d',' ','a','t',' ','R','E','L','O','C',' ','b','l','o','c','k',
{84} chr(ord('C') + $80),'a','n','''','t',' ','s','k','i','p',' ','o','v','e','r',' ','t','h','i','s',
{85} chr(ord('A') + $80),'d','d','r','e','s','s',' ','r','e','l','o','c','a','t','i','o','n',' ','o','v','e','r','l','o','a','d',
{86} chr(ord('N') + $80),'o','t',' ','r','e','l','o','c','a','t','a','b','l','e',
{87} chr(ord('U') + $80),'n','d','e','f','i','n','e','d',' ','v','a','r','i','a','b','l','e',' ','a','d','d','r','e','s','s',
{88} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','W','H','I','L','E',
{89} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','W',
{90} chr(ord('B') + $80),'L','K',' ','U','P','D','A','T','E',' ',
{91} chr(ord('A') + $80),'D','D','R','E','S','S',
{92} chr(ord('E') + $80),'X','T','E','R','N','A','L',
{93} chr(ord('P') + $80),'U','B','L','I','C',
{94} chr(ord('S') + $80),'Y','M','B','O','L',
{95} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','T','E','S','T',
{96} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','E','N','D','T',
{97} chr(ord('M') + $80),'i','s','s','i','n','g',' ','.','M','A','C','R','O',
{98} chr(ord('S') + $80),'k','i','p','p','i','n','g',' ','o','n','l','y',' ','t','h','e',' ','f','i','r','s','t',' ','i','n','s','t','r','u','c','t','i','o','n',
{99} chr(ord('R') + $80),'e','p','e','a','t','i','n','g',' ','o','n','l','y',' ','t','h','e',' ','l','a','s','t',' ','i','n','s','t','r','u','c','t','i','o','n',
{100} chr(ord('O') + $80),'n','l','y',' ','S','D','X',' ','R','E','L','O','C',' ','b','l','o','c','k',
{101} chr(ord('L') + $80),'i','n','e',' ','t','o','o',' ','l','o','n','g',
{102} chr(ord('C') + $80),'o','n','s','t','a','n','t',' ','e','x','p','r','e','s','s','i','o','n',' ','e','x','p','e','c','t','e','d',
{103} chr(ord('C') + $80),'a','n',' ','n','o','t',' ','d','e','c','l','a','r','e',' ','l','a','b','e','l',' ',
{104} chr(ord(' ') + $80),'a','s',' ','p','u','b','l','i','c',
{105} chr(ord('W') + $80),'r','i','t','i','n','g',' ','l','i','s','t','i','n','g',' ','f','i','l','e','.','.','.',
{106} chr(ord('W') + $80),'r','i','t','i','n','g',' ','o','b','j','e','c','t',' ','f','i','l','e','.','.','.',
{107} chr(ord('W') + $80),'r','i','t','i','n','g',' ','r','a','w',' ','f','i','l','e','.','.','.',
{108} chr(ord('C') + $80),'a','n','''','t',' ','f','i','l','l',' ','f','r','o','m',' ','h','i','g','h','e','r',' ','t','o',' ','l','o','w','e','r',' ','m','e','m','o','r','y',' ','l','o','c','a','t','i','o','n',
{109} chr(ord('U') + $80),'s','e',' ','.','R','E','P','T',' ','d','i','r','e','c','t','i','v','e',
{110} chr(ord('N') + $80),'o',' ','i','n','s','t','r','u','c','t','i','o','n',' ','t','o',' ','r','e','p','e','a','t',

{111} chr(ord('m') + $80),'a','d','s',' ','1','.','7','.','9',#13,#10,
     'S','y','n','t','a','x',':',' ','m','a','d','s',' ','s','o','u','r','c','e',' ','[','o','p','t','i','o','n','s',']',#13,#10,
     '-','b',':','a','d','d','r','e','s','s',#9,'G','e','n','e','r','a','t','e',' ','b','i','n','a','r','y',' ','f','i','l','e',' ','a','t',' ','s','p','e','c','i','f','i','c',' ','a','d','d','r','e','s','s',#13,#10,
     '-','c',#9,#9,'L','a','b','e','l',' ','c','a','s','e',' ','s','e','n','s','i','t','i','v','i','t','y',#13,#10,
     '-','d',':','l','a','b','e','l','=','v','a','l','u','e',#9,'D','e','f','i','n','e',' ','a',' ','l','a','b','e','l',#13,#10,
//     '-','e',#9,#9,'E','a','t',' ','w','h','i','t','e',' ','s','p','a','c','e','s',#13,#10,
     '-','f',#9,#9,'L','a','b','e','l',' ','a','t',' ','f','i','r','s','t',' ','c','o','l','u','m','n',#13,#10,
     '-','h','c','[',':','f','i','l','e','n','a','m','e',']',#9,'H','e','a','d','e','r',' ','f','i','l','e',' ','f','o','r',' ','C','C','6','5',#13,#10,
     '-','h','m','[',':','f','i','l','e','n','a','m','e',']',#9,'H','e','a','d','e','r',' ','f','i','l','e',' ','f','o','r',' ','M','A','D','S',#13,#10,
     '-','i',':','p','a','t','h',#9,#9,'A','d','d','i','t','i','o','n','a','l',' ','i','n','c','l','u','d','e',' ','d','i','r','e','c','t','o','r','i','e','s',#13,#10,
     '-','l','[',':','f','i','l','e','n','a','m','e',']',#9,'G','e','n','e','r','a','t','e',' ','l','i','s','t','i','n','g',#13,#10,
     '-','m',':','f','i','l','e','n','a','m','e',#9,'F','i','l','e',' ','w','i','t','h',' ','m','a','c','r','o',' ','d','e','f','i','n','i','t','i','o','n',#13,#10,
     '-','o',':','f','i','l','e','n','a','m','e',#9,'S','e','t',' ','o','b','j','e','c','t',' ','f','i','l','e',' ','n','a','m','e',#13,#10,
     '-','p',#9,#9,'P','r','i','n','t',' ','f','u','l','l','y',' ','q','u','a','l','i','f','i','e','d',' ','f','i','l','e',' ','n','a','m','e','s',' ','i','n',' ','l','i','s','t','i','n','g',#13,#10,
     '-','s',#9,#9,'S','i','l','e','n','t',' ','m','o','d','e',#13,#10,
     '-','t','[',':','f','i','l','e','n','a','m','e',']',#9,'L','i','s','t',' ','l','a','b','e','l',' ','t','a','b','l','e',#13,#10,
     '-','x',#9,#9,'E','x','c','l','u','d','e',' ','u','n','r','e','f','e','r','e','n','c','e','d',' ','p','r','o','c','e','d','u','r','e','s',

     chr($80) );


const
  __equ    = $80;       // kody pseudo rozkazow
  __opt    = $81;
  __org    = $82;
  __ins    = $83;
  __end    = $84;
  __dta    = $85;
  __icl    = $86;
  __run    = $87;       // RUN
  __nmb    = $88;
  __ini    = $89;       // INI-RUN = 2  !!! koniecznie !!!
//  __bot    = $8a;       // BOT aktualnie nie oprogramowany
  __rmb    = $8b;
  __lmb    = $8c;
  __ert    = $8d;
//  __ift    = $8e;       // -> .IF
//  __els    = $8f;       // -> .ELSE
//  __eif    = $90;       // -> .ENDIF
//  __eli    = $91;       // -> .ELSEIF
  __smb    = $92;
  __blk    = $93;
  __ext    = $94;

  __cpbcpd = $97;       // kody makro rozkazow __cpbcpd..__jskip
  __adbsbb = $98;
  __phrplr = $99;
  __adwsbw = $9A;
  __BckSkp = $9B;
  __inwdew = $9C;
  __addsub = $9D;
  __movaxy = $9E;
  __jskip  = $9F;       // koniec kodów makro rozkazów

  __macro  = $A0;       // kody dyrektyw, kolejnosc wg tablicy 'MAC' + $A0
  __if     = $A1;
  __endif  = $A2;
  __endm   = $A3;
  __exit   = $A4;
  __error  = $A5;
  __else   = $A6;
  __print  = $A7;
  __proc   = $A8;
  __endp   = $A9;
  __elseif = $AA;
  __local  = $AB;
  __endl   = $AC;
  __rept   = $AD;
  __endr   = $AE;

  __byte   = $AF;       // kody dla .BYTE, .WORD, .LONG, .DWORD
//  __word   = $B0;      // nastepuja po sobie, !!! koniecznie !!!
//  __long   = $B1;
  __dword  = $B2;

  __byteValue = __byte-1;     // zastapi operacje (...-__byte+1)

  __struct = $B3;
  __ends   = $B4;
  __ds     = $B5;
  __symbol = $B6;
  __fl     = $B7;
  __array  = $B8;
  __enda   = $B9;
  __get    = $BA;
  __put    = $BB;
  __sav    = $BC;
  __pages  = $BD;
  __endpg  = $BE;
  __reloc  = $BF;
  __dend   = $C0;       // zastepuje dyrektywy .ENDL, .ENDP, .ENDS, .ENDM itd.
  __link   = $C1;
  __extrn  = $C2;       // odpowiednik pseudo rozkazu EXT
  __public = $C3;       // odpowiednik dla .GLOBAL, .GLOBL

  __reg    = $C4;       // __REG, __VAR koniecznie w tej kolejnosci
  __var    = $C5;

  __or     = $C6;
  __by     = $C7;
  __he     = $C8;
  __wo     = $C9;
  __en     = $CA;
  __sb     = $CB;
  __while  = $CC;
  __endw   = $CD;
  __test   = $CE;
  __endt   = $CF;
//  __switch = $D0;       // SWITCH, ENDSW, CASE - nie oprogramowane
//  __endsw  = $D1;
//  __case   = $D2;
  __def    = $D3;
  __nowarn = $D4;
  __using  = $D5;

  __over   = __using;   // koniec kodow dyrektyw


  __nill   = $F0;
  __addEqu = $F1;
  __xasm   = $F2;

  __blkSpa = $F3;
  __blkRel = $F4;
  __blkEmp = $F5;

  __struct_run_noLabel = $F6;          // ostatni wolny tutaj kod to $F7


  __rel    = $0000;                    // wartosc dla etykiet relokowalnych

  __relASM = $0100;                    // adres asemblacji dla bloku .RELOC

  __relHea = ord('M')+ord('R') shl 8;  // naglowek 'MR' dla bloku .RELOC


  __id_param   = $FFF8;   // !!! zaczynamy koniecznie od __ID_PARAM !!!
  __id_array   = $FFF9;
  __dta_struct = $FFFA;
  __id_ext     = $FFFB;
  __id_smb     = $FFFC;
  __id_macro   = $FFFD;
  __id_struct  = $FFFE;
  __id_proc    = $FFFF;


  __array_val  = byte (__id_array);
  __macro_run  = byte (__id_macro);
  __struct_run = byte (__id_struct);
  __proc_run   = byte (__id_proc);

  __hea_dos      = $FFFF;  // naglowek dla bloku DOS
  __hea_reloc    = $0000;  // naglowek dla bloku .RELOC
  __hea_public   = $FFED;  // naglowek dla bloku aktualizacji symboli pyblic
  __hea_external = $FFEE;  // naglowek dla bloku aktualizacji symboli external
  __hea_address  = $FFEF;  // naglowek dla bloku aktualizacji adresow relokowalnych

  __pDef = 'D';            // Default
  __pReg = 'R';            // Registry
  __pVar = 'V';            // Variable


 mads_stack: array [0..2] of string[14] =
 ('@STACK_POINTER', '@STACK_ADDRESS', '@PROC_VARS_ADR');

 tType: array [1..4] of char =
 ('B','A','T','F');                   // typy uzywane wewnetrznie przez MADS

 relType: array [1..7] of char =
 ('B','W','L','D','<','>','^');       // typy zapisywane w relokowalnych plikach

 PathDelim: char = '/';


function _pth(const a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  test dla roznych znakow PathDelim                                         *)
(*----------------------------------------------------------------------------*)
begin
 _pth := (a in ['/','\'])
end;


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje i tabulatory                     *)
(*----------------------------------------------------------------------------*)
begin
 if a<>'' then
  while a[i] in [' ',#9] do inc(i);
end;


procedure __inc(var i:integer; var a:string);
begin

 if i>length(a) then exit;

 inc(i);
 omin_spacje(i,a);
 
end;


function UpCas_(const a: char): char;
begin
 if not(case_used) then Result:=UpCase(a) else Result:=a;
end;


function ata2int(const a: byte): byte;
(*----------------------------------------------------------------------------*)
(*  zamiana znakow ATASCII na INTERNAL                                        *)
(*----------------------------------------------------------------------------*)
begin
 Result:=a;

 case (a and $7f) of
    0..31: inc(Result,64);
   32..95: dec(Result,32);
 end;

end;


function IntToStr(const a: Int64): string;
var tmp: _typStrINT;
begin
 str(a, tmp);

 Result := tmp;
end;


function StrToInt(var a: string): Int64;
var i: integer;
begin
 val(a,Result, i);
end;


procedure flush_dst;
(*----------------------------------------------------------------------------*)
(*  oproznienie bufora zapisu                                                 *)
(*----------------------------------------------------------------------------*)
begin
 if buf_i>0 then blockwrite(dst,t_buf,buf_i);
 buf_i:=0;
end;


procedure put_dst(const a: byte);
(*----------------------------------------------------------------------------*)
(*  zapisz do bufora zapisu                                                   *)
(*----------------------------------------------------------------------------*)
begin
  t_buf[buf_i]:=a; inc(buf_i);
  if buf_i>=sizeof(t_buf) then flush_dst;
end;


function Hex(a:cardinal; b:shortint): string;
(*----------------------------------------------------------------------------*)
(*  zamiana na zapis hexadecymalny                                            *)
(*  'B' okresla maksymalna liczbe nibbli do zamiany                           *)
(*  jesli sa jeszcze jakies wartosci to kontynuuje zamiane                    *)
(*----------------------------------------------------------------------------*)
var v: byte;

const
    tHex: array [0..15] of char =
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

begin
 Result:='';

 while (b>0) or (a<>0) do begin

  v := byte(a);
  Result:=tHex[v shr 4] + tHex[v and $0f] + Result;

  a:=a shr 8;

  dec(b,2);
 end;

end;


function load_mes(const b: integer): string;
(*----------------------------------------------------------------------------*)
(*  tworzymy STRING z komunikatem nr w 'B'                                    *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 i:=imes[b]-imes[b-1];

 SetLength(Result,i);
 move(mes[imes[b-1]],Result[1],i);
end;


function GetFilePath(var a: string): string;
(*----------------------------------------------------------------------------*)
(*  z pelnej nazwy pliku wycinamy sciezke (ExtractFilePath)                   *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin
 Result:='';

 if a<>'' then begin
  i:=length(a);
  while not(_pth(a[i])) and (i>=1) do dec(i);

//  Result:=copy(a,1,i);
  Result:=a;
  SetLength(Result,i);
 end;
end;


function GetFileName(var a: string): string;
(*----------------------------------------------------------------------------*)
(*  z pelnej nazwy pliku wycinamy nazwe pliku (ExtractFileName)               *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin
 Result:='';

 if a<>'' then begin
  i:=length(a);
  while not(_pth(a[i])) and (i>=1) do dec(i);

  Result:=copy(a,i+1,length(a));
 end;    

end;


function show_full_name(var a:string; const b,c:Boolean): string;
var pth: string;
begin
 pth:=GetFilePath(a);

 Result:=a;

 if b then begin

  if pth='' then Result:=path+Result;

 end else Result:=GetFileName(Result);

 if c then Result:='Source: '+Result;
end;


procedure warning(const a: byte);
(*----------------------------------------------------------------------------*)
(*  wyswietla ostrzezenie, nie przerywa asemblacji                            *)
(*----------------------------------------------------------------------------*)
var txt: string;
begin

 if not(noWarning) then begin

  txt:=load_mes(a+1);

  case a of
    8: txt:=txt+'?';
   69: txt:=txt+str_blad;
   70: txt:=txt+'$'+HEX(adres,4);
  end;

  writeln(show_full_name(global_name,full_name,false)+' ('+IntToStr(line)+') WARNING: '+txt);

 end;

// noWarning:=false;

 status:=status or 1;    // wartosc kodu wyjscia gdy wystapilo jakiekolwiek ostrzezenie
end;


procedure madH_save(var b:integer; var s:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy plik naglowkowy MADS'a                                         *)
(*----------------------------------------------------------------------------*)
var okej: Boolean;
    tst: char;
    i: integer;
begin

 tst:=s[1];

 okej:=false;

 for i:=High(t_mad)-1 downto 0 do
  if t_mad[i].bnk=b then
   if t_mad[i].typ=tst then begin okej:=true; Break end;

 if okej then begin
  writeln(mmm,#13#10,'; ',s);
  for i:=High(t_mad)-1 downto 0 do
   if t_mad[i].bnk=b then
    if t_mad[i].typ=tst then writeln(mmm,t_mad[i].nam,#9,'=',#9,'$',Hex(t_mad[i].adr,4));
 end;

end;


procedure new_message(var a: string);
var i: integer;
begin

 if a='' then exit;

 i:=High(messages);

 messages[i].pas:=pass;
 messages[i].mes:=a;

 SetLength(messages,i+2);

 a:='';
end;


procedure koniec(const err: byte);
(*----------------------------------------------------------------------------*)
(*  ERR = 0  bez bledow                                                       *)
(*  ERR = 1  tylko komunikaty WARNING                                         *)
(*  ERR = 2  blad i zatrzymanie asemblacji                                    *)
(*  ERR = 3  bledne parametry dla MADS'a                                      *)
(*----------------------------------------------------------------------------*)
var a, b: integer;
    g: file;
    f: textfile;
    ok: Boolean;
    txt: string;
begin

 if open_ok then begin
  Flush(lst);  CloseFile(lst);
  Flush_dst;   CloseFile(dst);

 // sprawdzamy dlugosc 'PLIK_OBJ'
  AssignFile(g,plik_obj); FileMode:=0; Reset(g,1); a:=integer( FileSize(g) ); CloseFile(g);

 // sprawdzamy liczbe wierszy w 'PLIK_LST'
  AssignFile(f,plik_lst); FileMode:=0; Reset(f);
  b:=0;
  while not(eof(f)) do begin
   ReadLn(f,t); inc(b);
   if b>2 then Break;
  end;
  CloseFile(f);

  if list_lab then CloseFile(lab);


  if (b<3) or (err>1) then begin
   Erase(lst);                          // usuwamy plik LST
   if list_lab then Erase(lab);
  end else
   if (opt and 4>0) then begin
    txt:=load_mes(105+1);
    if not(silent) then new_message(txt);
   end;


  if (a=0) or (err>1) then
   Erase(dst)                           // usuwamy plik OBX
  else begin
   txt:=load_mes(106+ord(raw.use)+1);
   if not(silent) then new_message(txt);
  end;


  if over then
   if end_string<>'' then write(end_string);


  if over and not(silent) then begin

//   if end_string<>'' then write(end_string);

   if err<>2 then begin
     txt:=IntToStr(line_all)+load_mes(48+1)+' in '+IntToStr(pass_end)+' pass';
     new_message(txt);

     if a>0 then begin
      txt:=IntToStr(a)+load_mes(49+1);
      new_message(txt);
     end;

   end;

  end;

 end;


 if list_mmm then begin

  b:=0;
  while b<256 do begin

   ok:=false;
   for a:=High(t_mad)-1 downto 0 do
    if t_mad[a].bnk=b then begin ok:=true; Break end;

   if ok then begin

    if b>0 then writeln(mmm,#13#10,' lmb #',b,#9#9,'; BANK #',b);

    txt:='CONSTANS';   madH_save(b,txt);   // constans
    txt:='VARIABLES';  madH_save(b,txt);   // variables
    txt:='PROCEDURES'; madH_save(b,txt);   // procedures

   end;

   inc(b);
  end;

  CloseFile(mmm);
 end;
 
 if list_hhh then begin
  writeln(hhh,#13#10+'#endif');
  CloseFile(hhh);
 end;


 for a:=0 to High(messages)-1 do
  if messages[a].pas < 16 then begin

   if a<>High(messages)-1 then
    writeln(messages[a].mes)
   else
    write(messages[a].mes);
             
   for b:=High(messages)-1 downto 0 do    // usuwamy powtarzajace sie komunikaty
//    if messages[b].pas=messages[a].pas then
     if messages[b].mes=messages[a].mes then messages[b].pas:=$ff;

  end;

 writeln;

 Halt(err);
end;


function TestFile(var a: string): Boolean;
(*----------------------------------------------------------------------------*)
(*  sprawdzamy istnienie pliku na dysku bez udzialu 'SysUtils',               *)
(*  jest to odpowiednik funkcji 'FileExists'                                  *)
(*----------------------------------------------------------------------------*)
var pl: textfile;
    IORes: integer;
begin
 Result:=true;

 AssignFile(pl, a);
 {$I-}
 FileMode:=0;
 Reset(pl);
 {$I+ }
 IORes:=IOResult;

 if IORes<>0 then Result:=false else CloseFile(pl);
end;


procedure just_t(const a:cardinal);
var len: integer;
begin

 len:=length(t);

 if not(len>31) then
  if len+3>29 then begin
   t:=t+' +';
   while length(t)<32 do t:=t+' ';
  end else
   t:=t+' '+Hex(a,2);

end;


procedure bank_adres(a: integer);
begin
 if (dreloc.use) and (a-rel_ofs>=0) then dec(a,rel_ofs);

 if bank>0 then t:=t+Hex(bank,2)+',';

 if a>=0 then t:=t+Hex(a,4);
end;


procedure save_dst(const a: byte);
var x, y, ex, ey: integer;
    bl: Boolean;
    znk: char;
begin
 if (pass=pass_end) and (opt and 2>0) then begin

  if org then begin

   SetLength(t,7);

   if hea and (opt and 1>0) then t:=t+'FFFF> ';

   x:=adres;
   y:=t_hea[hea_i];

   if dreloc.use then begin
    dec(x,rel_ofs);
    dec(y,rel_ofs);
   end;

   if hea_ofs.adr>=0 then begin
    y:=hea_ofs.adr+(y-x); x:=hea_ofs.adr;
   end;

   if x<=y then begin
    ex:=x; ey:=y
   end else begin
    ey:=x; ex:=y
   end;

   znk:='-';
   if blok>0 then begin       // dlugosc bloku relokowalnego
    y:=y-x+1; znk:=','
   end;

   if adres>=0 then begin
    if ex>ey then bank_adres(t_hea[hea_i-1]+1) else bank_adres(x);
    if (ex<=ey) and (opt and 1>0) then t:=t+znk+Hex(y,4)+'>';
   end;

   if hea and (opt and 1>0) then begin
    put_dst($FF); put_dst($FF);
   end;


   if (opt and 1>0) then begin

     if raw.use then
      bl:=hea
     else
      bl:=true;

     if bl then begin
      put_dst( byte(x) ); put_dst( byte(x shr 8) );
      put_dst( byte(y) ); put_dst( byte(y shr 8) );
     end; 
   end;

   org:=false; hea:=false;
  end;

  just_t(a);

  if not(blokuj_zapis) then put_dst(a);
  
 end;

end;


procedure save_dstW(const a: integer);
begin
 save_dst( byte(a) );         // lo
 save_dst( byte(a shr 8) );   // hi
end;


procedure save_dstS(var a: string);
var i, len: integer;
begin
 len:=length(a);

 save_dstW( len );

 for i:=1 to len do save_dst( ord(a[i]) );
end;


procedure blad(var a: string; b: integer);
(*----------------------------------------------------------------------------*)
(*  wyswietla komunikat bledu nr w 'B'                                        *)
(*  wyjatek stanowi b<0 wtedy wyswietli komunikat 'Branch...'                 *)
(*  dla komunikatu nr 14 wyswietli nazwe wybranego trybu pracy CPU 8-16bit    *)
(*----------------------------------------------------------------------------*)
var add, prv, con: string;
begin

 if b=0 then begin

  overflow := true;

  if pass<>pass_end then exit;
 end;


 add:=''; prv:=''; con:='';

 line_err := line;

 if run_macro then begin
  con := t_wyw[1].zm;  new_message(con);
  global_name:=t_wyw[wyw_idx].pl;
  inc(line_err,t_wyw[wyw_idx].nr);
//  line_err:=t_wyw[wyw_idx].nr;
 end else
  if not(rept_run) and not(FOX_ripit) and not(loop_used) then
   if line_add>0 then inc(line_err,line_add);

 if str_blad<>'' then
  while str_blad[1]='#' do str_blad:=copy(str_blad,2,length(str_blad));

// usuwamy znak konca linii jesli to jakies krzaki-dziwaki
 if pos(#0,a)>0 then SetLength(a,pos(#0,a)-1);  //a:=copy(a,1,pos(#0,a)-1);

 if (a<>'') and not(b in [18,34]) then begin con := a; new_message(con) end;

 con := con+show_full_name(global_name,full_name,false)+' ('+IntToStr(line_err+ord(line_err=0))+load_mes(81);

 if b=18 then add:=' '''+a+'''';
 if b=2 then prv:=load_mes(80)+str_blad+' ';

 if b in [5,8,9,35,41,46,61,68,73,103] then add:=add+str_blad;
 
 if b in [2,5,35] then add:=add+load_mes(78+ord(dreloc.use))+IntToStr(bank)+')';

 if b=103 then add:=add+load_mes(104+1);       // ... as public

 if b=14 then add:=load_mes( 82+ord( opt and 16>0 ) );    // if opt and 16>0 then add:='816)' else add:='02)';

 if b=17 then
   if proc then add:='P' else
    if macro then add:='M';

 if b<0 then con := con+load_mes(22)+Hex(abs(b),4)+load_mes(23) else
  if b<>34 then con := con+prv+load_mes(b+1)+add else con:=con+a+add;

 status:= status or 2;

 new_message(con);

// pewne bledy wymagaja natychmiastowego zakonczenia asemblacji
// jesli wystapi za duzo bledow (>512) to te¿ konczymy asemblacje
 if (b in [3,8,10,12,13,15,17,18,23,24,25,28,30,34,40,41,46,57,58,62,66,74,76,87,109]) or (High(messages)>512) then koniec(2);
end;


procedure justuj;
var j: integer;
begin

 if (pass=pass_end) and (t<>'') and not(FOX_ripit) then begin

  j:=length(t);

  while j<32 do begin
   t:=t+#9;
   inc(j,8);
  end;

 end;

end;


procedure AccessFile(var a: string);
(*----------------------------------------------------------------------------*)
(*  sprawdzamy mozliwosc zapisu do pliku o podanej nazwie                     *)
(*----------------------------------------------------------------------------*)
var pl: textfile;
    IORes: integer;
begin
 AssignFile(pl,a);
 {$I-}
 FileMode:=1;
 Rewrite(pl);
 {$I+}
 IORes:=IOResult;
 if IORes <> 0 then blad(a,18) else CloseFile(pl);
end;


function GetFile(a: string; var zm: string): string;
(*----------------------------------------------------------------------------*)
(*  szukamy pliku w zadeklarowanych sciezkach poszukiwan                      *)
(*----------------------------------------------------------------------------*)
var c, p: string;
    i: integer;
begin
 if a='' then blad(zm,3);

 p:=path+a;
 if TestFile(p) then a:=path+a;

 Result:=a;

 if TestFile(a) then exit;

 for i:=High(t_pth)-1 downto 0 do begin
  p:=t_pth[i];

  if p<>'' then
    if not(_pth(p[length(p)])) then p:=p+PathDelim;

  c:=p+a;
  if TestFile(c) then begin Result:=c; Break end;
 end;

end;


procedure blad_ill(var a:string; const c:char);
(*----------------------------------------------------------------------------*)
(*  wyswietla komunikat 'Illegal character ??'                                *)
(*----------------------------------------------------------------------------*)
begin
 str_blad:=c;  blad(a,8);
end;


procedure blad_und(var old,b:string; const x:byte);
(*----------------------------------------------------------------------------*)
(*  wyswietla komunikat 'Undeclared label ????'                               *)
(*  wyswietla komunikat 'Label ???? declared twice'                           *)
(*  wyswietla komunikat 'Undeclared macro ????'                               *)
(*----------------------------------------------------------------------------*)
begin
 str_blad:=b;

 if x=69 then
  warning(x)
 else
  blad(old,x);

end;


function fASC(var a: string): byte;
(*----------------------------------------------------------------------------*)
(*  obliczamy sume kontrolna dla 3 literowego ciagu znakowego 'A'..'Z'        *)
(*  obliczona suma kontrolna jest indeksem do tablicy HASH                    *)
(*  tablica ASCII zawiera dopuszczalne kody znakow, reszta ma wartosc 0       *)
(*----------------------------------------------------------------------------*)
var i: cardinal;
const
 ascii: array [0..255] of byte=(
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$01,$02,$03,$04,$05,$06,$07,
 $08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,
 $14,$15,$16,$17,$18,$19,$1A,$00,$00,$00,$00,$00,
 $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,
 $0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,
 $18,$19,$1A,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
 $00,$00,$00,$00);

begin
 i:= ascii[ord(a[1])] + (ascii[ord(a[2])] shl 5) + (ascii[ord(a[3])] shl 10);

 Result:=hash[i];
end;


function fCRC16(var a: string): byte;
(*----------------------------------------------------------------------------*)
(*  obliczamy sume kontrolna CRC 16-bit dla krotkiego ciagu znakowego <3..6>  *)
(*  obliczona 16-bitowa suma kontrolna jest indeksem do tablicy HASH          *)
(*----------------------------------------------------------------------------*)
var i, b, len: byte;
    x: integer;
begin
 len:=byte( length(a) );

 x:=$ffff;
 for i:=1 to len do begin
  b:=byte(x shr 8) xor ord(a[i]);
  x:=tCRC16[b] xor (x shl 8);
 end;

 Result:=hash[x and $ffff];
end;


function l_lab(var a: string): integer;
(*----------------------------------------------------------------------------*)
(*  szukamy etykiety i zwracamy jej indeks do tablicy 'T_LAB'                 *)
(*  jesli nie ma takiej etykiety zwracamy wartosc -1                          *)
(*----------------------------------------------------------------------------*)
var x: cardinal;
    i, len: integer;
    b: byte;
begin
 Result:=-1;

 len:=length(a);   

 x:=$ffffffff;
 for i:=1 to len do begin
  b:=byte(x) xor ord(a[i]);
  x:=tCRC32[b] xor (x shr 8);
 end;

// OK jesli znaleziona etykieta ma kod >=__id_param, lub aktualna wartosc BANK=0
// OK jesli znaleziona etykieta jest z aktualnego banku lub banku zerowego (BNK=0)

 for i:=High(t_lab)-1 downto 0 do
  if t_lab[i].len=len then
   if t_lab[i].nam=x then
    if (bank=0) or (t_lab[i].bnk>=__id_param) then begin Result:=i; Break end else
     if t_lab[i].bnk in [bank,0] then begin Result:=i; Break end;

end;


procedure obetnij_kropke(var b: string);
(*----------------------------------------------------------------------------*)
(*  usuwamy z ciagu ostatni ciag znakow po kropce, ciag konczy znak kropki    *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

  i:=length(b);
  if (b<>'') and (i>1) then begin

   dec(i);
   while (b[i]<>'.') and (i>=1) do dec(i);

   SetLength(b,i);
  end;

end;


function search(var a,x: string): integer;
(*----------------------------------------------------------------------------*)
(*  szukamy nazwy etykiety w tablicy T_LAB, jesli w nazwie wystepuje kropka   *)
(*  obcinamy nazwe i szukamy dalej                                            *)
(*----------------------------------------------------------------------------*)
var b, t: string;
begin
 b:=x+lokal_name;

 t:=b+a;
 Result:=l_lab(t);

 while (Result<0) and (pos('.',b)>0) do begin

  obetnij_kropke(b);

  t:=b+a;
  Result:=l_lab(t);
 end;

end;


function load_lab(var a:string; const test:Boolean): integer;
(*----------------------------------------------------------------------------*)
(*  szukamy etykiety i zwracamy jej indeks do tablicy 'T_LAB'                 *)
(*  jesli nie ma takiej etykiety zwracamy wartosc -1                          *)
(*                                                                            *)
(*  jesli jest uruchomione makro i nie znajdziemy etykiety to szukamy w proc  *)
(*  jesli nie znajdziemy w proc to wtedy szukamy w glownym programie          *)
(*----------------------------------------------------------------------------*)
var txt: string;
    i: integer;
begin

  if test then begin

    if run_macro then begin
     Result:=search(a,macro_nr);

     if Result>=0 then exit;
    end;


    if proc then begin
     Result:=search(a,proc_name);

     if Result>=0 then exit;
    end;

    txt:='';
    Result:=search(a,txt);
    if Result>=0 then exit;

  end;


  txt:=lokal_name+a;
  Result:=l_lab(txt);

  if Result<0 then Result:=search(a,proc_name);

   
  if Result<0 then                         // test dla .USE [.USING]
   if usi_idx>0 then
    for i:=0 to usi_idx-1 do
     if t_usi[i].lok = end_idx then begin

      txt:=t_usi[i].lab+'.'+a;

      Result:=l_lab(txt);

      if Result>=0 then exit;
     end;


end;


procedure save_mad(var a:string; const ad:cardinal; const b:byte; const t:char);
var i: integer;
begin
 i:=High(t_mad);

 t_mad[i].nam:=a;
 t_mad[i].adr:=ad;
 t_mad[i].bnk:=b;
 t_mad[i].typ:=t;

 SetLength(t_mad,i+2);
end;


procedure zapisz_etykiete(var a:string; const ad:cardinal; const ba:word; const symbol:char);
(*----------------------------------------------------------------------------*)
(*  zapisujemy nazwe etykiety, jej adres itp w pliku .LAB                     *)
(*  dodatkowo jesli jest to wymagane w pliku naglowkowym .C dla cc65          *)
(*  nie zapisujemy etykiet tymczasowych, lokalnych w makrach                  *)
(*----------------------------------------------------------------------------*)
begin

 if pass=pass_end then
  if not(sav_lab_no) and (symbol<>'?') and not(pos('::',a)>0) then begin

   if list_lab then writeln(lab,Hex(ba,2),#9,Hex(ad,4),#9,a);

   if not(proc) and (ba<256) then begin
    if list_hhh and (ba=0) then writeln(hhh,'#define ',name,'_',a,' 0x',Hex(ad,4));
    if list_mmm then save_mad(a,ad,byte(ba),label_type);
   end;

  end;

end;


function loa_str(var a:string; var id:integer): integer;
(*----------------------------------------------------------------------------*)
(*  sprawdz czy wystepuje deklaracja pola struktury w T_STR                   *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

  Result:=-1;

  for i:=High(t_str)-1 downto 0 do
   if t_str[i].id=id then
    if t_str[i].lab=a then begin Result:=i; Break end;

end;


function loa_str_no(var id:integer; const x:integer): integer;
(*----------------------------------------------------------------------------*)
(*  odczytaj indeks do pola struktury o konkretnym numerze X                  *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

  Result:=-1;

  for i:=High(t_str)-1 downto 0 do
   if t_str[i].id=id then
    if t_str[i].no=x then begin Result:=i; Break end;

end;


procedure save_str(var a:string; const ofs,siz,rpt:integer; const ad:integer; const bn:word);
(*----------------------------------------------------------------------------*)
(* zapisz informacje na temat pol struktury, jesli wczesniej nie wystapily    *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

  i:=loa_str(a, struct_id);

  if i<0 then begin
   i:=High(t_str);
   SetLength(t_str,i+2);
  end;

  t_str[i].id:=struct_id;

  t_str[i].no:=struct_cnt;

  t_str[i].adr := ad;
  t_str[i].bnk := bn;

  t_str[i].lab := a;
  t_str[i].ofs := ofs;
  t_str[i].siz := siz;

  if rpt=0 then
   t_str[i].rpt := 1
  else
   t_str[i].rpt := rpt;
  
end;


procedure s_lab(var a:string; const ad:cardinal; var ba:word; var old:string; const symbol:char);
(*----------------------------------------------------------------------------*)
(*  wlasciwa procedura realizujaca zapamietanie etykiety w tablicy 'T_LAB'    *)
(*----------------------------------------------------------------------------*)
var tmp: cardinal;
    x, len, i: integer;
    b: byte;
begin
// sprawdz czy nie ma juz takiej etykiety
// bo jesli jest to nie dopisuj nowej pozycji tylko popraw stara
 x:=l_lab(a);

 if x<0 then begin
  x:=High(t_lab);
  SetLength(t_lab,x+2);
 end else
  if symbol<>'?' then
   if (t_lab[x].bnk<>ba) and not(struct_used.use) then blad_und(old,a,2);

 len:=length(a);

 tmp:=$ffffffff;              // crc32
 for i:=1 to len do begin
  b:=byte(tmp) xor ord(a[i]);
  tmp:=tCRC32[b] xor (tmp shr 8);
 end;

 if pass>0 then
 if symbol<>'?' then
  if t_lab[x].nam=tmp then
   if t_lab[x].bnk<__id_param then begin

    if t_lab[x].pas=pass then blad_und(old,a,2); // nie mozna sprawdzac dwa razy tej samej etykiety w aktualnym przebiegu

    if not(next_pass) then                       // sprawdz czy potrzebny jest dodatkowy przebieg
     if mne_used then                            // jakis mnemonik musial zostac wczesniej wykonany
      next_pass := (t_lab[x].adr <> ad);

   end;

 t_lab[x].typ := label_type;

 t_lab[x].len := len;

 t_lab[x].nam := tmp;
 t_lab[x].adr := ad;
 t_lab[x].bnk := ba;
 t_lab[x].blk := blok;

 t_lab[x].pas := pass;

 t_lab[x].ofs := org_ofset;

 if (blok>0) or dreloc.use then t_lab[x].rel := true;

 zapisz_etykiete(a,ad,ba,symbol);
end;


procedure save_lab(var a:string; const ad:cardinal; ba:word; var old:string);
(*----------------------------------------------------------------------------*)
(*  zapamietujemy etykiete, adres, bank                                       *)
(*----------------------------------------------------------------------------*)
var tmp: string;
begin

 if a<>'' then begin        // konieczny test

   if run_macro then tmp:=macro_nr+{lokal_name+}a else
    if proc then tmp:=proc_name+lokal_name+a else
     tmp:=lokal_name+a;

  s_lab( tmp, ad, ba, old, a[1] );

 end;

end;


procedure save_hea;
begin
 t_hea[hea_i]:=adres-1;

 inc(hea_i);
 if hea_i>High(t_hea) then SetLength(t_hea,hea_i+1);
end;


procedure save_arr(const a:cardinal; var b:word);
var i: integer;
begin
 i:=High(t_arr);

 t_arr[i].adr:=a;
 t_arr[i].bnk:=b;

 t_arr[i].ofs:=org_ofset;

 SetLength(t_arr,i+2);
end;


procedure save_mac(var a:string);
var i: integer;
begin
 i:=High(t_mac);

 t_mac[i]:=a;     

 SetLength(t_mac,i+2);
end;


procedure save_lin(var a:string);
var i: integer;
begin
 i:=High(t_lin);

 t_lin[i]:=a;

 SetLength(t_lin,i+2);
end;


procedure save_end(const a: byte);
begin
 t_end[end_idx].kod := a;
 t_end[end_idx].adr := adres;

 inc(end_idx);

 if end_idx>High(t_end) then SetLength(t_end,end_idx+1);
end;


procedure dec_end(var zm:string; const a: byte);
begin
 dec(end_idx);

 if t_end[end_idx].kod <> a then
  case a of
   __endpg: blad(zm,64);  // Missing .PAGES
   __ends: blad(zm,55);   // Missing .STRUCT
   __endm: blad(zm,97);   // Missing .MACRO
   __endw: blad(zm,88);   // Missing .WHILE
   __endt: blad(zm,95);   // Missing .TEST
   __enda: blad(zm,59);   // Missing .ARRAY
   __endr: blad(zm,51);   // Missing .REPT
  end;

end;


procedure save_var(const a:string; const c:integer; const s:byte; const v:cardinal);
begin

 if proc then
  t_var[var_idx].lok := proc_lokal
 else    
  t_var[var_idx].lok := end_idx;

 if proc and (lokal_name<>'') then
  t_var[var_idx].nam := lokal_name+a
 else
  t_var[var_idx].nam := a;

 t_var[var_idx].siz := s;
 t_var[var_idx].cnt := c;
 t_var[var_idx].war := v;

 t_var[var_idx].adr := -1;

 t_var[var_idx].id  := var_id;

 inc(var_idx);

 if var_idx>High(t_var) then SetLength(t_var,var_idx+1);
end;


procedure save_smb(const a:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy etykiete symbolu SMB w tablicy T_SMB                           *)
(*----------------------------------------------------------------------------*)
begin
 t_smb[smb_idx].smb:=a;

 inc(smb_idx);

 if smb_idx>High(t_smb) then SetLength(t_smb,smb_idx+1);
end;


procedure save_pub(var a,zm:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy symbol .PUBLIC                                                 *)
(*  jesli ADD = FALSE to w przypadku powtorzenia symbolu wystapi blad         *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 for i:=pub_idx-1 downto 0 do           // symbole public nie moga sie powtarzac
  if t_pub[i].nam=a then blad_und(zm,a,2);

 t_pub[pub_idx].nam := a;

 inc(pub_idx);

 if pub_idx>High(t_pub) then SetLength(t_pub,pub_idx+1);
end;


procedure save_sym(const a:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy symbol .SYMBOL                                                 *)
(*----------------------------------------------------------------------------*)
begin
  t_sym[sym_idx] := a;

  inc(sym_idx);

  if sym_idx>High(t_sym) then SetLength(t_sym,sym_idx+1);
end;


procedure save_rel(var a:integer; const idx, b:integer; var reloc_value:relVal);
begin

if dreloc.use or dreloc.sdx then begin

  if vector then t_rel[rel_idx].adr:=a-rel_ofs else t_rel[rel_idx].adr:=a-rel_ofs+1;

  t_rel[rel_idx].blk:=b;
  if not(empty) then t_rel[rel_idx].idx:=idx else t_rel[rel_idx].idx:=-100;
  t_rel[rel_idx].blo:=blok;

  if dreloc.use then begin
   t_rel[rel_idx].idx:=siz_idx;
   t_rel[rel_idx].bnk:=bank;

   inc(siz_idx);

   rel_used:=true;               // pozwalamy na zapis rozmiaru do T_SIZ

   if siz_idx>High(t_siz) then SetLength(t_siz,siz_idx+1);
  end;

  inc(rel_idx);

  if rel_idx>High(t_rel) then SetLength(t_rel,rel_idx+1);

  reloc:=true;  reloc_value.use:=true; inc(reloc_value.cnt);
 end;

end;


procedure save_relAddress(const arg:integer; var reloc_value: relVal);
begin

  if not(branch) then
   if t_lab[arg].rel then begin
    save_rel(adres, -1, t_lab[arg].blk, reloc_value);
   end;
   
end;


procedure save_ext(a:cardinal; var b:word; var x:integer);
begin
 if dreloc.use then dec(a,rel_ofs);

 t_ext[ext_idx].adr:=a;
 t_ext[ext_idx].bnk:=b;
 t_ext[ext_idx].idx:=x;

 inc(ext_idx);

 if ext_idx>High(t_ext) then SetLength(t_ext,ext_idx+1);
end;


procedure save_extn(var a:string; const t:byte; const p:Boolean);
begin
 t_extn[extn_idx].nam:=a;
 t_extn[extn_idx].siz:=relType[t];
 t_extn[extn_idx].prc:=p;

 inc(extn_idx);

 if extn_idx>High(t_extn) then SetLength(t_extn,extn_idx+1);
end;


function wartosc(var a:string; var v:Int64; const o:char): cardinal;
(*----------------------------------------------------------------------------*)
(*  sprawdzamy zakres wartosci zmiennej 'V' na podstawie kodu w 'O'           *)
(*----------------------------------------------------------------------------*)
var x: Boolean;
    i: int64;
begin
 Result:=cardinal( v );

 i:=abs(v);                  // koniecznie ABS inaczej nie zadziala prawidlowo

 case o of
               'B' :  x := i > $FF;
           'A','V' :  x := i > $FFFF;
           'E','T' :  x := i > $FFFFFF;
   'F','G','L','H' :  x := i > $FFFFFFFF;
 else
   x:=false
 end;

 if x then blad(a,0);

end;


function _ope(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  dopuszczalne operandy                                                     *)
(*----------------------------------------------------------------------------*)
begin
 Result := (a in ['=','<','>'])
end;


function _eol(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  test konca linii                                                          *)
(*----------------------------------------------------------------------------*)
begin
 Result := (a in [#0,#9,' '])
end;


function _dec(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  dopuszczalne znaki dla liczb decymalnych                                  *)
(*----------------------------------------------------------------------------*)
begin
 Result := (a in ['0'..'9'])
end;


function _lab(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  dopuszczalne znaki dla etykiet                                            *)
(*----------------------------------------------------------------------------*)
begin
 Result := (UpCase(a) in ['A'..'Z','0'..'9','_','?','@','.'])
end;


function _bin(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  dopuszczalne znaki dla liczb binarnych                                    *)
(*----------------------------------------------------------------------------*)
begin
 Result := (a in ['0'..'1'])
end;


function _hex(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  dopuszczalne znaki dla liczb heksadecymalnych                             *)
(*----------------------------------------------------------------------------*)
begin
 Result := (UpCase(a) in ['0'..'9','A'..'F'])
end;


function _first_char(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  pierwsze dopuszczalne znaki dla linii                                     *)
(*----------------------------------------------------------------------------*)
begin
 Result := (UpCase(a) in ['A'..'Z','_','?','@','.','+','-','=','*',':'])
end;


function _lab_first(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  pierwsze dopuszczalne znaki dla etykiet                                   *)
(*----------------------------------------------------------------------------*)
begin
 Result := (UpCase(a) in ['A'..'Z','_','?','@'])
end;


function _lab_firstEx(var a: char): Boolean;
(*----------------------------------------------------------------------------*)
(*  pierwsze dopuszczalne znaki dla etykiet w wyrazeniach                     *)
(*----------------------------------------------------------------------------*)
begin
 Result := (UpCase(a) in ['A'..'Z','_','?','@',':'])
end;


function test_char(const i:integer; var a:string; const sep,sep2:Char): Boolean;
(*----------------------------------------------------------------------------*)
(*  test konca linii, linie moga konczyc znaki #0, #9, ' ', ';', '//','\'     *)
(*----------------------------------------------------------------------------*)
begin
 Result := (a[i] in [#0,#9,'\',';',sep,sep2]) or ((a[i]='/') and (a[i+1] in ['/','*']))
end;


procedure test_eol(const i:integer; var a,old:string; const b:char);
(*----------------------------------------------------------------------------*)
(*  sprawdzamy czy nie ma niepoprawnych znakow na koncu linii                 *)
(*  linia moze konczyc sie znakami #0,#9,';',' ','//' lub przecinkiem ','     *)
(*----------------------------------------------------------------------------*)
begin
 if not( a[i] in [#0,#9,'\',';',' ',b] ) and not((a[i]='/') and (a[i+1]='/') ) then blad(old,4)
end;


function get_lab(var i:integer; var a:string; const tst:Boolean): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_','?','@'             *)
(*  jesli TST = TRUE to etykieta musi zawierac jakies znaki                   *)
(*----------------------------------------------------------------------------*)
begin
 Result:='';

 if tst then omin_spacje(i,a);

 if _lab_first(a[i]) then
  while _lab(a[i]) do begin Result:=Result+UpCas_(a[i]); inc(i) end;

 if tst then
  if Result='' then blad(a,15);
end;


function get_string(var i:integer; var a,old:string; const test:Boolean): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag znakow, ograniczony znakami '' lub ""                        *)
(*  podwojny '' oznacza literalne '                                           *)
(*  podwojny "" oznacza literalne "                                           *)
(*  TEST = TRUE sprawdza czy ciag jest pusty                                  *)
(*----------------------------------------------------------------------------*)
var len: integer;
    znak, gchr: char;
begin
 Result:='';

 omin_spacje(i,a);
 if not(a[i] in ['''','"']) then exit;

 gchr:=a[i]; len:=length(a);

 while i<=len do begin
  inc(i);         // omijamy pierwszy znak ' lub "

  znak:=a[i];

  if znak=gchr then begin
   inc(i);
   if a[i]=gchr then znak:=gchr else begin
    if test then if Result='' then blad(old,3);
    exit;
   end;
  end;

  Result:=Result+znak;
 end;

 if not(komentarz) then blad(a,3);       // nie napotkal znaku konczacego ciag ' lub "
end;


function get_datUp(var i:integer; var a:string; const sep:Char; const tst:Boolean): string;
(*----------------------------------------------------------------------------*)
(* pobieramy ciag znakow (dyrektywy), zmieniamy wielkosc liter na duze        *)
(* jeli TST = TRUE to ciag musi byc niepusty                                  *)
(*----------------------------------------------------------------------------*)
begin
 Result:='';

 omin_spacje(i,a);

 if a<>'' then
  while (a[i]<>'=') and not(test_char(i,a,' ',sep)) do begin
   Result := Result + UpCase(a[i]);
   inc(i);
  end;

 if tst then
  if Result='' then blad(a,23);

end;


function get_type(var i:integer; var zm: string; const tst:Boolean): byte;
(*----------------------------------------------------------------------------*)
(*  sprawdzamy czy odczytany ciag znakow oznacza dyrektywe typu danych        *)
(*  akceptowane dyrektywy typu to .BYTE, .WORD, .LONG, .DWORD                 *)
(*----------------------------------------------------------------------------*)
begin
 omin_spacje(i,zm);

 str_blad:=get_datUp(i,zm,#0,false);
 if (str_blad='') and not(tst) then begin Result:=0; exit end;   // wyjatek dla .RELOC [.BYTE] [.WORD]

 Result := fCRC16(str_blad);

 if not(Result in [__byte..__dword]) then blad(zm,46);

 dec(Result, __byteValue);  //Result:=byte( Result-__byteValue );
end;


function get_typeExt(var i:integer; var zm:string): byte;
(*----------------------------------------------------------------------------*)
(* sprawdzamy czy odczytany ciag znakow oznacza dyrektywe typu danych dla EXT *)
(* akceptowane dyrektywy typu to .BYTE, .WORD, .LONG, .DWORD, .PROC           *)
(*----------------------------------------------------------------------------*)
var txt: string;
begin
 omin_spacje(i,zm);

 txt:=get_datUp(i,zm,'(',false);

 Result := fCRC16(txt);

 if not(Result in [__byte..__dword, __proc]) then blad_und(zm,txt,46);
end;


function ciag_ograniczony(var i:integer; var a:string; const cut:Boolean): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag ograniczony dwoma znakami 'LEWA' i 'PRAWA'                   *)
(*  znaki 'LEWA' i 'PRAWA' moga byc zagniezdzone                              *)
(*  jesli CUT = TRUE to usuwamy poczatkowy i koncowy nawias                   *)
(*----------------------------------------------------------------------------*)
var nawias, len: integer;
    znak, lewa, prawa: char;
    petla: Boolean;
begin
 Result:='';

 if not(a[i] in ['[','(','{']) then exit;

 lewa:=a[i];
 if lewa='(' then prawa:=')' else prawa:=chr(ord(lewa)+2);

 nawias:=0; petla:=true; len:=length(a);

 while petla and (i<=len) do begin

  znak := a[i];

  if znak=lewa then inc(nawias) else
   if znak=prawa then dec(nawias);

//  if not(zag) then
//   if nawias>1 then test_nawias(a,lewa,0);

//  if nawias=0 then petla:=false;
  petla := not(nawias=0);

  if znak in ['''','"'] then begin
   Result := Result + znak + get_string(i,a,a,false) + znak
  end else begin
   Result := Result + UpCas_(znak);
   inc(i)
  end;

 end;

 if petla and not(komentarz) then
  case lewa of
   '[': blad(a,6);
   '(': blad(a,7);
   '{': blad(a,20);
  end;

 if cut then
  if Result<>'' then Result:=copy(Result,2,length(Result)-2);
end;


function test_param(var i:integer; var a:string): Boolean;
(*----------------------------------------------------------------------------*)
(*  test na obecnosc parametrow makra, czyli ':0..9', '%%0..9'                *)
(*----------------------------------------------------------------------------*)
begin
 Result := ((a[i]=':') and _dec(a[i+1])) or ((a[i]='%') and (a[i+1]='%') and _dec(a[i+2]))
end;



function get_dat(var i:integer; var a:string; const Sep:Char; const spacja:Boolean): string;
(*----------------------------------------------------------------------------*)
(*  wczytaj dowolne znaki, oprocz spacji, tabulatora i 'Sep'                  *)
(*  jesli wystepuja znaki otwierajace ciag, czytaj taki ciag                  *)
(*----------------------------------------------------------------------------*)
var znak: char;
    len: integer;
begin
 Result:='';

 len:=length(a);

 while i<=len do

  if a[i]=Sep then
   exit
  else

  case UpCase(a[i]) of
   '[','(','{': Result:=Result + ciag_ograniczony(i,a,false);

   'A'..'Z': Result:=Result + get_lab(i,a, false);

   '''','"':
     begin
      znak:=a[i];
      Result:=Result + znak + get_string(i,a,a,false) + znak;
     end;

   '/': if a[i+1]='/' then exit else begin Result:=Result+'/'; inc(i) end;

   ';','\': exit;

   ' ',#9: if spacja then exit else begin Result:=Result+a[i]; inc(i) end;

  else
   begin
//    if a[i]=Sep then exit;
    Result := Result + UpCas_(a[i]);
    inc(i);
   end;
  end;

end;


function get_dat_noSPC(var i:integer; var a:string; const sep,sep2:Char; var old:string): string;
(*----------------------------------------------------------------------------*)
(*  wczytujemy ciag znakow pomijajac znaki spacji                             *)
(*----------------------------------------------------------------------------*)
var len: integer;
begin
 Result:='';

 omin_spacje(i,a);

 len:=length(a);

 while i<=len do begin

  case a[i] of
   ' ',#9:
        if sep=' ' then exit else __inc(i,a);

   '.','$','%':
        if a[i]=sep then exit else begin
         if (test_char(i+1,a,' ',#0)) and not(komentarz) then blad(old,4);
         Result:=Result+a[i]; __inc(i,a);
        end;

   '/': if a[i+1]='/' then exit else begin Result:=Result+'/'; __inc(i,a) end;

   ';','\': exit;

  else
   if a[i] in [sep,sep2] then exit else Result := Result + get_dat(i,a,sep,true);
  end;

 end;

end;


function OperExt(var i:integer; var old:string; const a,b:char; var value:Boolean): char;
(*----------------------------------------------------------------------------*)
(*  operatory zlozone zamieniamy na odpowiedni jednoliterowy kod              *)
(*----------------------------------------------------------------------------*)
var x: integer;
begin
 Result:=' ';

 x:=ord(a) shl 8+ord(b);

 case x of
  15422,8509: Result := 'A';       // '<>', '!='
       15421: Result := 'B';       // '<='
       15933: Result := 'C';       // '>='
       15420: Result := 'D';       // '<<'
       15934: Result := 'E';       // '>>'
       15677: Result := '=';       // '=='
        9766: Result := 'F';       // '&&'
       31868: Result := 'G';       // '||'
 end;

 if not(value) or (Result=' ') then begin
  str_blad:=a+b;
  blad(old,8);
 end;

 inc(i,2); value:=false;
end;


function OperNew(var i:integer; var old:string; const a:char; var value:Boolean; const b:Boolean): char;
begin
 if value<>b then blad_ill(old,a);

 Result:=a;

 inc(i); value:=false;
end;


function test_string(var i:integer; var a:string; const typ:Char): integer;
(*----------------------------------------------------------------------------*)
(*  obliczamy wartosc ktora zmodyfikuje ciag znakowy lub plikowy              *)
(*  dla '*' jest to wartosc 128, czyli invers                                 *)
(*----------------------------------------------------------------------------*)
begin
 Result:=0;          // wynik jest typem ze znakiem, koniecznie !!!

 omin_spacje(i,a);

 case a[i] of
      '*': begin
            Result := 128;
            inc(i);
           end;

  '+','-': Result := integer( ___wartosc_noSPC(a,a,i,',',typ) );
 end;

 omin_spacje(i,a);
end;


procedure subrange_bounds(var a:string; const v,y:integer);
begin
  if (v<0) or (v>y) then blad(a,62);
end;


procedure save_dtaS(war:cardinal; ile:integer);
var v: byte;
    i: integer;
begin

 i:=0;

 while i<ile do begin

  v:=byte(war);

  save_dst(v);

  war:=war shr 8;

  inc(adres);
  inc(i);
 end;

end;


procedure save_dta(const war:cardinal; var tmp:string; const op_:char; const invers:byte);
(*----------------------------------------------------------------------------*)
(*  zapisujemy bajty danych do .ARRAY w zaleznosci od ustawionego typu danych *)
(*----------------------------------------------------------------------------*)
var k, i: integer;
    v: byte;
begin

 if aray or put_used then
  if array_used.idx>$FFFF then exit else begin
                                    
   if op_ in ['C','D'] then begin
    i:=length(tmp);

    for k:=1 to i do begin
     v:=byte( ord(tmp[k])+invers );
     if op_='D' then v:=ata2int(v);

     {if not(loop_used) and not(FOX_ripit) then} just_t(v);
     if aray then t_tmp[array_used.idx]:=v else t_get[array_used.idx]:=v;

     inc(array_used.idx);
    end;

    exit;
   end;

   {if not(loop_used) and not(FOX_ripit) then} just_t(war);
   if aray then t_tmp[array_used.idx]:=cardinal(war) else t_get[array_used.idx]:=byte(war);

   inc(array_used.idx);
   
   exit;
  end;


  case op_ of
    'L','B':
         begin
          save_dst( byte(war) );            inc(adres);
         end;

    'H': begin
          save_dst( byte(war shr 8) );      inc(adres);
         end;

    'A','V':
         begin
          save_dst( byte(war) );
          save_dst( byte(war shr 8) );      inc(adres,2);
         end;

    'T','E':
         begin
          save_dst( byte(war) );
          save_dst( byte(war shr 8) );
          save_dst( byte(war shr 16) );     inc(adres,3);
         end;

    'F': begin
          save_dst( byte(war) );
          save_dst( byte(war shr 8) );
          save_dst( byte(war shr 16) );
          save_dst( byte(war shr 24) );     inc(adres,4);
         end;

    'G': begin
          save_dst( byte(war shr 24) );
          save_dst( byte(war shr 16) );
          save_dst( byte(war shr 8) );
          save_dst( byte(war) );            inc(adres,4);
         end;

    'C','D':
         begin
          i:=length(tmp);

          for k:=1 to i do begin
           v:=byte( ord(tmp[k])+invers );
           if op_='D' then v:=ata2int(v);
           save_dst(v);
          end;
                                            inc(adres,i);
         end;

   end;

end;


function oblicz_wartosc_ogr(var zm,old:string; var i:integer): Int64;
(*----------------------------------------------------------------------------*)
(*  obliczamy wartosc ograniczona nawiasami '[' lub '('                       *)
(*----------------------------------------------------------------------------*)
var txt: string;
    k: integer;
begin
 Result:=0;

 omin_spacje(i,zm);

 if zm[i] in ['[','('] then begin
  txt:=ciag_ograniczony(i,zm,true);

  k:=1;
  Result:=___wartosc_noSPC(txt,old,k,#0,'F')
 end;

// omin_spacje(i,zm);
end;


function get_labelEx(var i:integer; var a,old:string): string;
begin
 Result:='';

 if _lab_firstEx(a[i]) then begin

  Result:=Result+UpCas_(a[i]);
  inc(i);

  while _lab(a[i]) do begin Result:=Result+UpCas_(a[i]); inc(i) end;

 end;

 if not(_eol(a[i])) then blad_ill(old,a[i]);
end;


function get_labEx(var i:integer; var a,old:string): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_','?','@',':'         *)
(*  jesli wystepuja nawiasy '( )' lub '[ ]' to usuwamy je                     *)
(*----------------------------------------------------------------------------*)
var tmp: string;
    k: integer;
begin

 omin_spacje(i,a);

 if a[i] in ['(','['] then begin
  tmp := ciag_ograniczony(i,a,true);

  k:=1;
  omin_spacje(k,tmp);

  Result := get_labelEx(k,tmp, old);
 end else
  Result := get_labelEx(i,a, old);

 if Result='' then blad(old,15);

end;


function load_label_ofset(a:string; var old:string; const test:Boolean): integer;
(*----------------------------------------------------------------------------*)
(*  znajdujemy indeks do tablicy T_LAB                                        *)
(*----------------------------------------------------------------------------*)
var b: word;
begin

 if a='' then blad(old,23);

 if a[1]=':' then begin
  b     := bank;
  bank  := 0;         // wymuszamy BANK=0 aby odczytac etykiete z najnizszego poziomu

  a:=copy(a,2,length(a));
  Result:=l_lab(a);

  bank  := b;         // przywracamy poprzednia wartosc BANK
 end else
  Result:=load_lab(a,true);

 if test then
  if Result<0 then
   if pass=pass_end then blad_und(old,a,5);

end;


procedure testRange(var old:string; var i:integer; const b:byte);
begin
 if (i<0) or (i>$FFFF) then begin
  blad(old,b);
  i:=0;
 end;
end;


function read_HEX(var i:integer; var a,old: string): string;
begin
         inc(i);     // omin pierwszy znak '$'

         Result:='';
         while _hex(a[i]) do begin Result:=Result+UpCase(a[i]); inc(i) end;

         if not(test_param(i,a)) then
          if Result='' then blad_ill(old,a[i]);

         Result:='$'+Result;
end;


function oblicz_wartosc(var a:string; var old:string): Int64;
(*----------------------------------------------------------------------------*)
(*  obliczamy wartosc wyrazenia, uwzgledniajac operacje arytmetyczne          *)
(*  w 'J' jest licznik dla STOS'u                                             *)
(*  zamiast tablic dynamicznych wprowadzilem tablice statyczne i ograniczylem *)
(*  maksymalna liczbe operacji i operatorow w wyrazeniu do 512                *)
(*----------------------------------------------------------------------------*)
type znak_wart = record
                  znak: char;
                  wart: Int64;
                 end;

     _typCash  = array [0..16] of char;  // taka sama liczba elementow jak PRIOR
     _typOper  = array [0..511] of char;
     _typStos  = array [0..511] of znak_wart;


var i, j, b, x, k, v, pomoc, ofset, _hlp, len, op_idx, arg: integer;
    tmp, txt: string;
    iarg, war: Int64;
    petla, value: Boolean;
    oper, byt: char;

    reloc_value: relVal;

    stos_: _carArray;
    cash : _typCash;
    stos : _typStos;
    op   : _typOper;

const
 prior: array [0..16] of char=          // piorytet operatorow
 ('D','E','&','|','^','/','*','%','+',{'-',}'=','A','B','<','C','>','F','G');

begin

 if a='' then blad(old,23);

 Result:=0;

 // init tablicy dynamicznej OP
// SetLength(op,2);
 op[0]:='+'; oper:='+'; op_idx:=1;

 i:=1; war:=0; b:=0;
 fillchar(cash,sizeof(cash),' ');   // wypelniamy spacjami

 value:=false;

 reloc_value.use:=false;
 reloc_value.cnt:=0;

 j:=1;               // na pozycji zerowej (J=0) tablicy 'STOS' dopiszemy '+0'
                     // !!! zmienne I,J uzywane sa przez petle WHILE !!!

// SetLength(stos,3);

 len:=length(a);

 while (i<=len) and not(overflow) do begin

  case UpCase(a[i]) of

   '#': begin
         war:=___rept_ile;  //FOX_ripit:=true;
         value:=true;
         __inc(i,a);
        end;

   // odczytaj operator '<'
   '<': if a[i+1] in ['<','=','>'] then
         oper:=OperExt(i,old,'<',a[i+1],value) else
          if value then oper:=OperNew(i,old,'<',value,true) else
           oper:=OperNew(i,old,'M',value,false);

   // odczytaj operator '>'
   '>': if a[i+1] in ['=','>'] then
         oper:=OperExt(i,old,'>',a[i+1],value) else
          if value then oper:=OperNew(i,old,'>',value,true) else
           oper:=OperNew(i,old,'S',value,false);

   // odczytaj operator '='
   '=': if a[i+1]='=' then
         oper:=OperExt(i,old,'=','=',value) else
          if value then oper:=OperNew(i,old,'=',value,true) else
           oper:=OperNew(i,old,'X',value,false);

   // odczytaj operator '&'
   '&': if a[i+1]='&' then
         oper:=OperExt(i,old,'&','&',value) else
          oper:=OperNew(i,old,'&',value,true);

   // odczytaj operator '|'
   '|': if a[i+1]='|' then
         oper:=OperExt(i,old,'|','|',value) else
          oper:=OperNew(i,old,'|',value,true);

   // odczytaj operator '!'
   '!': if a[i+1]='=' then
         oper:=OperExt(i,old,'!','=',value) else
          oper:=OperNew(i,old,'!',value,false);

   // odczytaj operator '^'
   '^': if not(value) then begin
         oper:='H'; inc(i)
        end else oper:=OperNew(i,old,'^',value,true);

   // odczytaj operator '/'
   '/': oper:=OperNew(i,old,'/',value,true);

   // odczytaj operator '*'
   '*': if not(value) then begin
         b:=bank;
         war:=adres; inc(i);
         value:=true;

         label_type:='V';

         if not(branch) then begin
          save_rel(adres, -1, bank, reloc_value);
         end;

        end else oper:=OperNew(i,old,'*',value,true);

   // odczytaj operator '~'
   '~': oper:=OperNew(i,old,'~',value,false);

   // odczytaj operatory '+' '-'
   '+','-':
        oper:=OperNew(i,old,a[i],value,value);

   // odczytaj wartosc decymalna lub wyjatkowo hex 0x...
   '0'..'9':
        begin
         if value then blad(old,4);

         if (UpCase(a[i+1])='X') and (a[i]='0') then begin  // 0x...

          inc(i);
          tmp:=read_HEX(i,a,old);

         end else begin                                     // 0..9

          tmp:='';
          while _dec(a[i]) do begin tmp:=tmp+a[i]; inc(i) end;

         end;

         war:=StrToInt(tmp);

         value:=true;
        end;

   // odczytaj .R, .OR, .LO, .HI, .AND, .XOR, .NOT, .DEF
   '.':
    if a[i+1]='R' then begin                             // .R
     war:=___rept_ile;
     inc(i,2);
     value:=true;
     if not(loop_used) and not(FOX_ripit) then t:=t+' #'+Hex(cardinal(war),2);    // zapisz w pliku LST #numer

    end else begin

      str_blad:='.'+a[i+1]+a[i+2];
      _hlp:=ord(a[i+1]) shl 16+ord(a[i+2]) shl 8;

      case _hlp of
       $4F5200: begin
                 oper:=OperExt(i,old,'|','|',value);     // .OR
                 inc(i);
                end;

       $4C4F00: begin                                    // .LO (expression)
                 inc(i,3);

                 war:=byte( oblicz_wartosc_ogr(a,old,i) );

                 value:=true;
                end;

       $484900: begin                                    // .HI (expression)
                 inc(i,3);

                 war:=byte( oblicz_wartosc_ogr(a,old,i) shr 8 );

                 value:=true;
                end;

       else begin

        str_blad:=str_blad+a[i+3];
        inc( _hlp , ord(a[i+3]) );

        case _hlp of
         $474554:
             begin                                       // .GET
              inc(i,4);
              omin_spacje(i,a); arg:=0;

              if a[i] in ['[','('] then arg:=integer( oblicz_wartosc_ogr(a,old,i) );

              war:=t_get[arg];
              value:=true;
             end;

         $414E44:
             begin
              oper:=OperExt(i,old,'&','&',value);        // .AND
              inc(i,2);
             end;

         $584F52:
             begin
              oper:=OperNew(i,old,'^',value,true);       // .XOR
              inc(i,3);
             end;

         $4E4F54:
             begin
              oper:=OperNew(i,old,'!',value,false);      // .NOT
              inc(i,3);
             end;

         $4C454E:                                        // .LEN label
             begin
            // omijamy 4 znaki dyrektywy '.LEN'
            // i odczytujemy nazwe etykiety
              inc(i,4);

              txt:=get_labEx(i,a, old);
              arg:=load_label_ofset(txt, old, true);

              if arg>=0 then
               case t_lab[arg].bnk of
                 __id_proc: war:=t_prc[t_lab[arg].adr].len; // dlugosc bloku .PROC
                __id_array: war:=t_arr[t_lab[arg].adr].len; // dlugosc bloku .ARRAY
               else
                war:=t_lab[arg].lln;                        // dlugosc bloku .LOCAL
               end;

              value:=true;
             end;

         $414452:
             begin                                       // .ADR label
            // omijamy 4 znaki dyrektywy '.ADR'
            // i odczytujemy nazwe etykiety
              inc(i,4);

              txt:=get_labEx(i,a, old);
              arg:=load_label_ofset(txt, old, true);

              war:=0;

              if arg>=0 then begin

               war:= oblicz_wartosc(txt,old);

               case t_lab[arg].bnk of
                __id_proc: dec(war, t_prc[t_lab[arg].adr].ofs);
               else
                dec(war, t_lab[arg].ofs)
               end;

              end;
              
              value:=true;
             end;

         $444546:
             begin                                    // .DEF label
            // omijamy 4 znaki dyrektywy '.DEF'
            // i odczytujemy nazwe etykiety
              inc(i,4);

              txt:=get_labEx(i,a, old);
              arg:=load_label_ofset(txt, old, false);

              war := ord(arg>=0);

              value:=true;      
             end;

        else blad(old,68);

        end;

       end;

      end;

    end;

   // odczytaj etykiete i okresl jej wartosc
   // znak ':' oznacza etykiete globalna lub parametr makra
   'A'..'Z','_','?','@',':':
     begin
         petla:=false;  b:=0;  war:=0;

         if a[i]=':' then

          if _lab_first(a[i+1]) then begin
           petla:=true; inc(i)
          end else
           if _dec(a[i+1]) then begin

            if run_macro then begin
             value:=false; oper:=' ';   Break; //i:=len+1
            end else blad_ill(old,':');

           end else blad(old,4);

         if i<=len then begin

          if value then blad(old,4);

          tmp:=get_lab(i,a, false);  if petla then tmp:=':'+tmp;


          arg:=load_label_ofset(tmp, old, true);


      // jesli przetwarzamy makro to nie musza byc zdefiniowane wartosci etykiet
      // w pozostalych przypadkach wystapi blad 'Undeclared label ????'

          if arg>=0 then begin
           pomoc:=t_lab[arg].adr;

           if t_lab[arg].typ='V' then variable:=true;
          end;


   if arg>=0 then
     case t_lab[arg].bnk of


      __id_struct:  // zamiana struktur na dane DTA, na poczatku sprawdzimy czy 'DTA_USED = true'

   if not(dta_used) then begin

       b   := t_str[pomoc].bnk;
       war := t_str[pomoc].siz;

      end else
      if pass=0 then begin              // teraz nie znamy wszystkich struktur, musimy koñczyc

        if a[i]<>'[' then warning(102); // 'Constant expression expected', brakuje indeksu [idx]

      end else
      if pass>0 then begin  // w drugim przebiegu mamy pewnosc ze poznalismy wszystkie struktury

      dta_used:=false;

      struct_used.use:=true;

    // odczytujemy ofset do tablicy 'T_STR'
      ofset:=t_lab[arg].adr;

      struct_used.idx:=ofset;     // w OFSET indeks do pierwszego pola struktury

    // liczba pol struktury
      b := t_str[ofset].ofs;

      inc(ofset);  txt:='';

    // odczytujemy zadeklarowana liczbe elementow danych strukturalnych  [?]
      arg:=integer( oblicz_wartosc_ogr(a,old,i) );

      //if (arg<0) or (arg>$FFFF) then blad(old,62);  // blad 'Constant expression violates subrange bounds'
      testRange(old, arg, 62);

      struct_used.cnt:=arg;

      omin_spacje(i,a);

    // odczytujemy wartosci elementow ograniczone nawiasami ( )
      while a[i] ='(' do begin

       tmp:=ciag_ograniczony(i,a,true);

       k:=1; tmp:=get_dat_noSPC(k,tmp,#0,#0,old);
       k:=1;

       SetLength(stos_,1);

     // wczytujemy elementy ograniczone nawiasami, w 'X' jest licznik
       x:=0;
       while k<=length(tmp) do begin

        pomoc:=loa_str_no(t_str[ofset].id, x);  // zawsze musi odnalezc wlasciwe pole struktury

        v:=t_str[pomoc].siz;   byt:=tType[v];

        war:=___wartosc_noSPC(tmp,old,k,',',byt);

        _hlp:=t_str[pomoc].rpt * v;
        
        save_dtaS(cardinal(war), _hlp);

        inc(x);
//        if pass>0 then
         if x>b then blad(old,40);   // jesli liczba podanych elementow jest wieksza niz w strukturze

        pomoc:=High(stos_);
        stos_[pomoc]:=cardinal( war );

        SetLength(stos_,pomoc+2);

        omin_spacje(k,tmp);
        if tmp[k]=',' then __inc(k,tmp) else Break;
       end;

//       if pass>0 then
        if x<>b then blad(old,40);

     // zmniejszamy licznik elementow
       dec(arg); if arg<-1 then blad(old,40);

       omin_spacje(i,a);
      end;

      omin_spacje(i,a);

      value:=( High(stos_) = b );   // jesli podalismy jakies wartosci poczatkowe to VALUE=TRUE

      
      if not(value) then begin      // jesli nie podalismy wartosci to musimy wymusic ORG-a
       opt:=opt or 1;               // wymuszamy zapis naglowka DOS-a
       save_hea;  org:=true;
      end;


    // reszte elementow struktury wypelniamy ostatnimi wartosciami lub zerami
      while arg>=0 do begin

       for x:=0 to b-1 do begin

        pomoc:=loa_str_no(t_str[ofset].id, x);

        v:=t_str[pomoc].siz;   byt:=tType[v];

        _hlp:=t_str[pomoc].rpt * v;

        if value then begin
         war:=stos_[x];
         save_dtaS(cardinal(war), _hlp); // nowy adres i zapisanie wartosci poczatkowej struktury
        end else begin
         war:=0;
         inc(adres, _hlp);               // nowy adres bez zapisywania wartosci poczatkowej
        end;

       end;

       dec(arg);
      end;

      b:=bank;
      value:=false;
      oper:=' ';
   end;


            __id_proc: begin
                        b:=t_prc[pomoc].bnk;
                        war:=t_prc[pomoc].adr;

                        t_prc[pomoc].use:=true;  // procedura .PROC musi byc asemblowana

                        save_relAddress(arg, reloc_value);
                       end;

            __id_ext:  begin
                        if blocked then blad_und(old,tmp,41);

                        if not(branch) then
                         if vector then
                          save_ext(adres,bank,pomoc)
                         else
                          save_ext(adres+1,bank,pomoc);

                        ext_used.use:=true;
                        ext_used.idx:=pomoc;
                        ext_used.siz:=t_extn[pomoc].siz;
                       end;

            __id_smb:  begin
                        if blocked then blad_und(old,tmp,41);

                        if not(branch) then begin
                         save_rel(adres,pomoc,0, reloc_value);
                         t_smb[pomoc].use:=true;
                         war:=__rel;
                        end;

                       end; 

           __id_array: begin
                        b:=t_arr[pomoc].bnk;
                        war:=t_arr[pomoc].adr;

                        omin_spacje(i,a);
                        if a[i]='[' then begin
                         ofset:=integer( oblicz_wartosc_ogr(a,old,i) );
                         subrange_bounds(old,ofset,t_arr[pomoc].idx);

                         inc(war, ofset*t_arr[pomoc].siz);
                        end;

                        save_relAddress(arg, reloc_value);
                       end;

         __dta_struct: begin

                        save_relAddress(arg, reloc_value);

                        b:=t_str[pomoc].bnk;
                        war:=t_str[pomoc].adr;

                        ofset:=integer( oblicz_wartosc_ogr(a,old,i) );
                        subrange_bounds(old,ofset,t_str[pomoc].ofs);

                        arg:=t_str[t_lab[arg].adr].idx;

                        ofset:=ofset * t_str[arg].siz;   // indeks * dlugosc_struktury

                        if a[i]='.' then begin
                          inc(i);
                          txt:=get_lab(i,a, false);   str_blad:=txt;

                         // szukamy w T_STR
                          pomoc:=loa_str(txt, t_str[arg].id);

                          if pomoc>=0 then
                           inc(ofset,t_str[pomoc].ofs)
                          else
                           if pass=pass_end then blad(old,46);

                        end;

                        inc(war,ofset);
                       end;
           else
            begin

            
          // wystapi blad 'Address relocation overload'
          // jesli dokonujemy operacji na wiecej niz jednej relokowalnej etykiecie

             save_relAddress(arg, reloc_value);

          
             if dreloc.use or dreloc.sdx then
              if reloc_value.use and (reloc_value.cnt>1) then blad(old,85);


             b:=t_lab[arg].bnk;
             war:=t_lab[arg].adr;

             while pos('.',tmp)>0 do begin

              obetnij_kropke(tmp);

              k:=length(tmp);            // usun ostatni znak kropki
              SetLength(tmp,k-1);

              arg:=l_lab(tmp);

              pomoc:=t_lab[arg].adr;

              if arg>=0 then
               if t_lab[arg].bnk=__id_proc then begin
                t_prc[pomoc].use:=true;  // procedura .PROC musi byc asemblowana
                Break;
               end;
             end;

            end;

           end;

          value:=true;
         end;

      // wyjatkowo dla PASS=0 i prawdopodobnego odwolania do tablicy
      // przyjmij wartosc =0
         omin_spacje(i,a);
         if a[i]='[' then
          if pass<pass_end then exit else blad_und(old,tmp,5);

        end;

   // odczytaj wartosc hexadecymalna
   '$': begin

         if value then blad(old,4);

         tmp:=read_HEX(i,a,old);
         
         war:=StrToInt(tmp);

         value:=true;
        end;

   // odczytaj wartosc binarna lub potraktuj '%' jako operator
   // lub jako numer parametru dla makra gdy wystapily znaki '%%'
   '%': if a[i+1]='%' then begin

         if not(_dec(a[i+2])) then blad(old,47);      // %%0..9

//         b:=0; war:=0;
         value:=false; oper:=' ';  Break; //i:=len+1
        end else
         if value then oper:=OperNew(i,old,'%',value,true) else
          begin
           inc(i);     // omin pierwszy znak '%'
//           war:=get_value(i,a,'B',old);

           tmp:='';
           while _bin(a[i]) do begin tmp:=tmp+a[i]; inc(i) end;

           if not(test_param(i,a)) then
            if tmp='' then blad_ill(old,a[i]);

//           war:=BinToInt(tmp);
           war:=0;

(*----------------------------------------------------------------------------*)
(*  realizacja zamiany ciagu zero-jedynkowego na wartosc decymalna            *)
(*----------------------------------------------------------------------------*)
       if tmp<>'' then begin

           k:=Length(tmp);

          //remove leading zeros
           pomoc:=1;
           while tmp[pomoc]='0' do inc(pomoc);

          //do the conversion
           for ofset:=k downto pomoc do
            if tmp[ofset]='1' then
             war:=war+(1 shl (k-ofset));
       end;
       
           value:=true;
          end;

   // odczytaj string ograniczony apostrofami ''
   '''','"':
        begin
         if value then blad(old,4);
         
         k:=ord(a[i]);
         tmp:=get_string(i,a,old,true);
         if chr(k)='''' then war:=ord(tmp[1]) else war:=ata2int(ord(tmp[1]));

         byt:=a[i+1];

         if not(_lab_firstEx(byt) or _dec(byt) or (byt in ['$','%'])) then
          inc(war,test_string(i,a,'F'));

         value:=true;
        end;

   // odczytaj wartosc miedzy { }
   '{': begin
         if value then blad(old,4);

         klamra_used := true;

         petla:=dreloc.use;       // blokujemy relokowalnosc DRELOC.USE=FALSE
         dreloc.use:=false;

         tmp:=ciag_ograniczony(i,a,true);            // test na poprawnosc nawiasow
         k:=1; nul:=oblicz_mnemonik__(k,tmp,old);

         dreloc.use:=petla;       // przywracamy poprzednia wartosc DRELOC.USE

         klamra_used := false;

         war:=nul.h[0];

         nul.l:=0;

         value:=true;
        end;

   // odczytaj wartosc miedzy [ ] ( )
   '[','(':
        begin
         if value then blad(old,4);

         war:=oblicz_wartosc_ogr(a,old,i);

         value:=true;
        end;

   // jesli napotkasz spacje to zakoncz przetwarzanie
   // do 'value' wpisz 'false' aby nie traktowal tego jako liczby
   ' ',#9:
        begin
         value:=false; oper:=' ';  Break; //i:=len+1
        end;

  else
   blad_ill(old,a[i]);
  end;


// jesli przetwarzamy wartosc numeryczna to zapisz na stosie
// t¹ wartosc i operator
  if value then begin

   op[op_idx]:='+';

  // przetworz operatory z 'OP' cofajac sie
   for k:=op_idx downto 1 do
    case op[k] of
     '-': war := -war;
     'M': war := byte(war);
     'S': war := byte(war shr 8);
     'H': war := byte(war shr 16);
//     'I': war := byte(war shr 24);
     '!': war := ord(war=0);
     '~': war := not(war);
     'X': war := b;
    end;

   if op[0]='-' then begin war:=-war; op[0]:='+' end;

   stos[j].znak := op[0];
   stos[j].wart := war;

   cash[pos(op[0],prior)-1]:=op[0];

  // zeruj indeks do tablicy dynamicznej OP
   op_idx:=0; oper:=' ';

   inc(j);
//   if j>High(stos) then SetLength(stos,j+1);

  end else begin

   op[op_idx] := oper;

   inc(op_idx);
 //  if op_idx>High(op) then SetLength(op,op_idx+1);

  end;

 end;


 if not(overflow) then
  if oper<>' ' then blad(old,23);

// obliczenie wartosci wg piorytetu obliczen
// na koncu dodawaj tak dlugo az nie uzyskasz wyniku
 len:=0; war:=0;

 while cash[len]=' ' do inc(len);     // omijaj puste operatory
 if len>=sizeof(cash) then exit;      // nie wystapil zaden operator

 stos[0].znak:='+'; stos[0].wart:=0;
 stos[j].znak:='+'; stos[j].wart:=0;
 inc(j);

// SetLength(stos,j+1);


 while j>1 do begin
 // 'petla=true' jesli nie wystapi zaden operator
 // 'petla=false' jesli wystapi operator
  i:=0; petla:=true;

  while i<=j-2 do begin

    war  := stos[i].wart;
    oper := stos[i+1].znak;
    iarg := stos[i+1].wart;

 // obliczaj wg kolejnosci operatorow z 'prior'
 // operatory '/','*','%' maja ten sam piorytet, stanowi¹ wyj¹tek
 
     if (oper=cash[len]) or ((oper in ['/','*','%']) and (len in [5..7])) then begin
        case oper of
         '+': war := war + iarg;
         '&': war := war and iarg;
         '|': war := war or iarg;
         '^': war := war xor iarg;
         '*': war := war * iarg;
         '/': if iarg=0 then begin

               overflow:=true;

               if pass=pass_end then
                blad(old,26)
               else
                war:=0;

              end else war := war div iarg;

         '%': war := war mod iarg;
         '=': war := ord(war=iarg);
         'A': war := ord(war<>iarg);
         'B': war := ord(war<=iarg);
         '<': war := ord(war<iarg);
         'C': war := ord(war>=iarg);
         '>': war := ord(war>iarg);
         'D': war := war shl iarg;
         'E': war := war shr iarg;
         'F': war := ord(war<>0) and ord(iarg<>0);
         'G': war := ord(war<>0) or ord(iarg<>0);
        end;

 // obliczyl nowa wartosc, skasuj znak

      stos[i].wart   := war;
      stos[i+1].znak := ' ';

      inc(i); petla:=false;
     end;

  inc(i)
  end;

// przepisz elementy ktore maja niepusty znak na poczatek tablicy STOS
  k:=0;

  for i:=0 to j-1 do
   if stos[i].znak<>' ' then begin
    stos[k] := stos[i];
    inc(k)
   end;

  j:=k;

  if petla and (len<sizeof(prior)-1) then begin
   inc(len);
   while cash[len]=' ' do inc(len);
  end;

 end;


 if overflow then          // konieczny warunek dla .MACRO
  Result := 0
 else
  Result := war;

end;


function oblicz_wartosc_noSPC(var zm,old:string; var i:integer; sep,typ:Char): Int64;
(*----------------------------------------------------------------------------*)
(*  pobieramy ciag pomijajac spacje, nastepnie obliczamy jego wartosc         *)
(*----------------------------------------------------------------------------*)
var txt: string;
begin

 txt:=get_dat_noSPC(i,zm,sep,#0,old);

 Result:=oblicz_wartosc(txt,old);

 omin_spacje(i,zm);

 wartosc(old,Result,typ);

end;


function get_expres(var i:integer; var a,old:string; const tst:Boolean): Int64;
(*----------------------------------------------------------------------------*)
(*  pobierz ciag znakow ograniczony przecinkiem i oblicz jego wartosc         *)
(*  nie wczytuj nawiasow zamykajacych ')'                                     *)
(*  jesli TST = TRUE to sprawdzaj czy to koniec wyrazenia                     *)
(*----------------------------------------------------------------------------*)
var k: integer;
    tmp: string;
begin
 k:=i;
 tmp:=get_dat(k,a,')',false);

 tmp:=a;
 SetLength(tmp,k-1);  // tmp:=copy(a,1,k-1);

 Result:=___wartosc_noSPC(tmp,old,i,',','F');

 if tst then
  if a[i]<>',' then blad(old,52) else inc(i);
end;


procedure put_lst(const a:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy wiersze listingu po asemblacji do pliku .LST                   *)
(*----------------------------------------------------------------------------*)
begin

 if (pass=pass_end) and (a<>'') then begin

   if run_macro then           // nie zapisuj zawartosci makra jesli bit5 OPT skasowany
    if (opt and $20=0) and not(data_out) then exit;

   if (opt and 4>0) and not(FOX_ripit) then writeln(lst,a);
   if (opt and 8>0) and not(FOX_ripit) then writeln(a);

   if not(FOX_ripit) then t:='';

 end;

end;


procedure save_lst(var b:string; const c:char);
(*----------------------------------------------------------------------------*)
(*  formatowanie wierszy listingu przed zapisaniem ich do pliku .LST          *)
(*----------------------------------------------------------------------------*)
var i: byte;
begin

 if pass=pass_end then begin

  if not(loop_used) and not(FOX_ripit) then begin
   t:=IntToStr(line);
   while length(t)<6 do t:=' '+t;
   t:=t+' ';
  end;

  case c of
 // jesli pusta linia to usun spacje, czyli oszczedzamy bajty :)
   ';': begin
         if b<>'' then justuj else SetLength(t,length(t)-1); // delete(t,length(t),1);
         put_lst(t+b);
        end;

   'l': if not(FOX_ripit) then begin t:=t+'= '; bank_adres(nul.i) end;

   'i': bank_adres(adres);
  end;

 end;


  if c='a' then
      if pass=pass_end then begin

       if not(hea) and not(loop_used) and not(FOX_ripit) and not(struct) and (adres>=0) then bank_adres(adres);

       if nul.l>0 then begin
         data_out:=true;
         for i:=0 to byte(nul.l-1) do save_dst(nul.h[i]);
       end;

      end;

      inc(adres,nul.l);    // to zawsze musi sie wykonac niezaleznie od przebiegu
end;


procedure zapisz_lst(var a: string);
(*----------------------------------------------------------------------------*)
(*  wymuszenie zapisania wiersza listingu do pliku .LST                       *)
(*----------------------------------------------------------------------------*)
begin

 if (pass=pass_end) then begin
  justuj;  put_lst(t+a);  a:='';
 end;

end;


procedure wymus_zapis_lst(var a: string);
(*----------------------------------------------------------------------------*)
(*  dodatkowe wymuszenie zapisania wiersza listingu do pliku .LST             *)
(*----------------------------------------------------------------------------*)
begin

 if pass=pass_end then begin
  save_lst(a,' ');
  justuj;  put_lst(t+a);
 end;

end;


procedure _siz(const t:Boolean);
begin

  if t then
   t_siz[siz_idx-1].siz:=dreloc.siz
  else
   t_siz[siz_idx].siz:=dreloc.siz;

end;


procedure _sizm(const a:byte);
begin

 t_siz[siz_idx-1].msb:=a;

end;


procedure oblicz_dane(var i:integer; var a,old:string; const typ: byte);
(*----------------------------------------------------------------------------*)
(*  zwracamy wartosci liczbowe dla ciagu DTA, .BYTE, .WORD, .LONG, .DWORD     *)
(*----------------------------------------------------------------------------*)
(*  B( -> BYTE, A( -> WORD, V( -> VECTOR (WORD)                               *)
(*  L( -> BYTE, H( -> BYTE                                                    *)
(*  T( -> 24bit, E( -> 24bit                                                  *)
(*  F( -> DWORD                                                               *)
(*  G( -> DWORD (odwrocona kolejnosc)                                         *)
(*  C' -> ATASCII                                                             *)
(*  D' -> INTERNAL                                                            *)
(*  sin(centre,amp,size[,first,last])                                         *)
(*----------------------------------------------------------------------------*)
var op_, default: char;
    sin_a, sin_b, sin_c, sin_d, sin_e, x, len, k: integer;
    war: Int64;
    invers: byte;
    step, val: extended;   // or REAL for more compatybility
    value, nawias, ciag: Boolean;
    tmp: string;
begin
 omin_spacje(i,a);

 if empty then blad(old,58);

 war:=0; invers:=0;

 value:=false; nawias:=false; ciag:=false;

 if not(pisz) then branch:=false;

 reloc := false;

 data_out := true;

 tmp:=' ';

// okreslenie domyslnego typu wartosci
 op_ := 'B';                            // dla 'typ' = 1

 case typ of
  2: op_ := 'A';                        // dla 'typ' = 2
  3: op_ := 'T';                        // dla 'typ' = 3
  4: op_ := 'F';                        // dla 'typ' = 4
 end;

 default := op_;

 if not(pisz) and test_char(i,a,#0,#0) then begin // jesli brakuje danych to generuj domyslnie zera
  save_dta(cardinal(war),tmp,op_,invers);
  exit;
 end;

 if struct then blad(old,58);

 vector:=true; dta_used:=true;


 len:=length(a);

 while i<=len do begin

// SIN, RND
  if UpCase(a[i]) in ['S','R'] then begin
   x:=ord(UpCase(a[i+1])) shl 16+ord(UpCase(a[i+2])) shl 8+ord(a[i+3]);

  CASE x of
 // IN(
   $494E28: begin
    inc(i,3);

   // sprawdzamy poprawnosc nawiasow
    k:=i;
    tmp:=ciag_ograniczony(k,a,true);

    value:=true; invers:=0; tmp:='';

    inc(i);
    sin_a:=integer( get_expres(i,a,old,true) );
    sin_b:=integer( get_expres(i,a,old,true) );
    sin_c:=integer( get_expres(i,a,old,false) );

    sin_d:=0;
    sin_e:=sin_c-1;

    if a[i]=',' then begin

     inc(i);
     sin_d:=integer( get_expres(i,a,old,true) );
     sin_e:=integer( get_expres(i,a,old,false) );

     inc(i);
    end else inc(i);

    step:=360.0/sin_c;
    val:=0;

    for x:=sin_d to sin_e do begin
     war:=round(sin(val*(pi/180))*sin_b)+sin_a;

     val:=val+step;

     war:=wartosc(old,war,op_);
     save_dta(cardinal(war),tmp,op_,invers)
    end;

    omin_spacje(i,a);
   end;

 // ND(
   $4E4428: begin
    inc(i,3);

   // sprawdzamy poprawnosc nawiasow
    k:=i;
    tmp:=ciag_ograniczony(k,a,true);

    value:=true; invers:=0; tmp:='';

    inc(i);
    sin_a:=integer( get_expres(i,a,old,true) );
    sin_b:=integer( get_expres(i,a,old,true) );
    sin_c:=integer( get_expres(i,a,old,false) );
    inc(i);

    sin_d:=sin_b-sin_a;

    randomize;
    for x:=0 to sin_c-1 do begin

     war:=sin_a+random(sin_d+1);

     war:=wartosc(old,war,op_);
     save_dta(cardinal(war),tmp,op_,invers)
    end;

    omin_spacje(i,a);
   end;

  END;    //end case

  end;



  case UpCase(a[i]) of
   'A','B','E','F','G','H','L','T','V':

          begin
            k:=i;

            if a[i+1] in [' ',#9] then begin
             __inc(i,a);

             if a[i]='(' then dec(i) else i:=k;
            end;

            if a[i+1]='(' then begin
            // pobierz ciag ograniczony nawiasami ( )
             if value then blad(old,4);

             op_:=UpCase(a[k]);  inc(i);
            // sprawdzamy poprawnosc
             k:=i;
             tmp:=ciag_ograniczony(k,a,true);
             nawias:=true;

            // dane inne niz 2 bajtowe nie sa relokowalne w przypadku SPARTA DOS X
            // relokowalne sa wszystkie jesli uzylismy dyrektywy .RELOC
             if dreloc.use then begin
//              if op_='G' then branch:=true else branch:=false;
              branch := (op_='G');

              case op_ of
               'E','T': dreloc.siz:=relType[3];
               'A','V': dreloc.siz:=relType[2];
                   'F': dreloc.siz:=relType[4];
                   'L': dreloc.siz:='<';
                   'H': dreloc.siz:='>';
              else
               dreloc.siz:=relType[1];
              end;

              _siz(false);

             end else
//              if op_ in ['E','F','G','T'] then branch:=true else branch:=false;
              branch := (op_ in ['E','F','G','T']);

             inc(i);             // omin nawias otwierajacy

            end else begin

             if dreloc.use then _siz(false);

             if value then blad(old,4);
             war:=get_expres(i,a,old, false);
             value:=true;

             if pisz then end_string := end_string + '$' + hex(cardinal(war),4);
            end;

          end;


   'C','D':
          begin
            k:=i;
            
            if a[i+1] in [' ',#9] then begin
             __inc(i,a);

             if a[i] in ['''','"'] then dec(i) else i:=k;
            end;

            if a[i+1] in ['''','"'] then begin
           // pobierz ciag ograniczony apostrofami '' lub ""
             op_:=UpCase(a[k]);  inc(i);

            end else begin

             if dreloc.use then _siz(false);

             if value then blad(old,4);
             war:=get_expres(i,a,old, false);
             value:=true;

             if pisz then end_string := end_string + '$' + hex(cardinal(war),4);
            end;

          end;

   '''','"': begin
              if value then blad(old,4);

//              if aray then
              if not(op_ in ['C','D']) then
               if a[i]='"' then op_:='D' else op_:='C';

              tmp:=get_string(i,a,old,true);
              war:=0; ciag:=true;
              invers:=byte( test_string(i,a,'B') );
              value:=true;

              if pisz then end_string := end_string + tmp;
             end;


   '(': begin nawias:=true; inc(i) end;


   ')': if nawias and value then begin
         value:=false; nawias:=false; inc(i);

         omin_spacje(i,a);

         if not(test_char(i,a,#0,#0)) then       // jesli nie ma konca linii to jedynym
          if a[i]<>',' then blad_ill(old,a[i]);  // akceptowanym znakiem jest znak ',' 

        end else blad(old,4);


   ',': begin
         inc(i); invers:=0; value:=false;

         omin_spacje(i,a);
         if test_char(i,a,#0,#0) then blad(old,23);  // jesli koniec linii to blad 'Unexpected end of line'

         if not(nawias) then op_:=default;
        end;


   ' ',#9: omin_spacje(i,a); 


   '/': if a[i+1]='/' then Break else blad(old,4);   // value:=false; i:=length(a)+1


   ';','\': Break;                                   // value:=false; i:=length(a)+1

  else
       begin
         if _eol(a[i]) then Break;

         if dreloc.use then _siz(false);

         if value then blad(old,4);

         war:=get_expres(i,a,old, false);
         value:=true;

         if pisz then end_string := end_string + '$' + hex(cardinal(war),4);

       end;
  end;


  if dta_used then
   if value then begin

    if not(ciag) then
     if op_ in ['C','D'] then op_:='B';


    if reloc and dreloc.use then begin
     dec(war,rel_ofs); reloc:=false;

     _sizm(byte(war));
    end;

    if not(pisz) then begin
     war:=wartosc(old,war,op_);   //writeln(war);
     save_dta(cardinal(war),tmp,op_,invers);
    end else branch:=true;           // jesli PISZ=TRUE to nie ma relokowalnosci

    ciag:=false;
   end;

  omin_spacje(i,a);
 end;

 vector:=false; dta_used:=false;
end;


function value_code(var a: Int64; var old: string; const test:Boolean): char;
(*----------------------------------------------------------------------------*)
(*  przedstawiamy wartosc w postaci kodu literowego 'Z', 'Q', 'T' , 'D'       *)
(*  kody literowe symbolizuja typ wartosci BYTE, WORD, LONG, DWORD            *)
(*----------------------------------------------------------------------------*)
var x: cardinal;
begin
 Result:='T';

 x:=cardinal( abs(a) );

 case x of
              0..$FF: Result:='Z';
         $100..$FFFF: Result:='Q';
     $10000..$FFFFFF: if test then Result:='T' else blad(old,14);
// $1000000..$FFFFFFFF: Result:='D';
 else
  if not(test) then blad(old,0);
 end;

end;


procedure reg_size(const i:byte; const a:Boolean);
(*----------------------------------------------------------------------------*)
(*  nowe rozmiary rejestrow dla operacji sledzenia SEP, REP                   *)
(*----------------------------------------------------------------------------*)
begin

 if i in [$10,$30] then begin regX:=a; regY:=a end;
 if i in [$20,$30] then regA:=a;

end;


procedure test_reg_size(var a:string; const b:Boolean; const i:byte);
(*----------------------------------------------------------------------------*)
(*  sprawdzamy rozmiar rejestrow dla wlaczonej opcji sledzenia SEP, REP       *)
(*----------------------------------------------------------------------------*)
begin

 if b then begin
  if i>2 then blad(a,63);
 end else
  if i<3 then blad(a,63);

end;


function macro_rept_if_test: Boolean;
begin
 Result := (not(rept) and if_test)
end;


procedure test_siz(var a:string; var siz:Char; const x:Char; var pomin:Boolean);
(*----------------------------------------------------------------------------*)
(*  sprawdzamy identyfikator rozmiaru                                         *)
(*----------------------------------------------------------------------------*)
begin
 if siz in [' ',x] then siz:=x else blad(a,14);

 pomin:=true;
end;


function adr_label(const n: byte; const tst:Boolean): cardinal;
(*----------------------------------------------------------------------------*)
(*  szukamy wartosci dla etykiety o nazwie z MADS_STACK[N], jesli nie zostaly *)
(*  zdefiniowane etykiety z MADS_STACK wowczas przypisujemy im wartosci       *)
(*  z MADS_STACK_DEFAULT[N]                                                   *)
(*----------------------------------------------------------------------------*)
var i: integer;
    txt: string;

const
    mads_stack_default: array [0..2] of cardinal = ($fe, $0500, $0600);

begin
 Result:=0;

 txt:=mads_stack[n];  i:=load_lab(txt,false);

 if tst then
  if i<0 then begin
   Result:=mads_stack_default[n];  // blad_und(zm,txt,5);    // brak deklaracji dla etykiety z TXT

   s_lab(txt,Result,bank,txt,'@');
  end;

 if i>=0 then Result:=t_lab[i].adr;  // odczytujemy wartosc etykiety
end;


procedure test_skipa;
begin

   if t_bck[1]=adres then exit;

   t_bck[0] := t_bck[1];
   t_bck[1] := adres;

   if skip.use then begin

    t_skp[skip.idx] := adres;

    inc(skip.idx);

    if skip.idx>High(t_skp) then SetLength(t_skp,skip.idx+1);

    inc(skip.cnt);
    if skip.cnt>1 then begin
     skip.use := false;
     skip.xsm := false;
    end;

   end;

end;


procedure addResult(var hlp, Res: int5);
var i: integer;
begin
  for i:=0 to hlp.l-1 do Res.h[Res.l+i]:=hlp.h[i];
  inc(Res.l, hlp.l);
end;


function asm_mnemo(var txt, old:string): int5;
var i: integer;
begin
 i:=1; Result:=oblicz_mnemonik__(i,txt, old);

 inc(adres, Result.l);
end;


function moveAXY(var mnemo,zm,zm2, old: string): int5;
var tmp: string;
    hlp: int5;
begin
   mnemo[1]:='L'; mnemo[2]:='D';                  // LDA
   tmp:=mnemo + #32 + zm;
   Result:=asm_mnemo(tmp,old);

   mnemo[1]:='S'; mnemo[2]:='T';                  // STA
   tmp:=mnemo + #32 + zm2;
   hlp:=asm_mnemo(tmp,old);

   addResult(hlp, Result);

   Result.tmp:=hlp.h[0];
end;


function adrMode(var a: string): byte;
begin
 Result:=fCRC16(a);

 if Result in [$60..$7e] then
  dec(Result,$60)
 else
  Result:=0;
end;


procedure save_fake_label(var ety,old:string; tst:cardinal);
var war: integer;
begin

   war:=load_lab(ety,false);        // uaktualniamy wartosc etykiety

   if war<0 then
    s_lab(ety,tst,bank,old,ety[1])
   else
    t_lab[war].adr:=tst;

end;


procedure __next(var i:integer; var zm:string);
begin
 omin_spacje(i,zm);
 if zm[i]=',' then __inc(i,zm);
 omin_spacje(i,zm);
end;


procedure get_parameters(var j:integer; var str:string; var par:_strArray; mae:Boolean);
(*----------------------------------------------------------------------------*)
(*  jesli wystepuje znak '=' to omijamy spacje sprzed i zza znaku '='         *)
(*  zapamietamy wszystkie etykiety (parametry) w tablicy dynamicznej          *)
(*----------------------------------------------------------------------------*)
var txt: string;
    _odd: integer;
begin
    SetLength(par,1);

    if str='' then exit;

    omin_spacje(j,str);

    while not(test_char(j,str,'.',':')) do begin

      txt:=get_dat(j,str,',',true);

      _odd:=length(txt);              // wyjatek jesli odczytal ju¿ znak '=', np. 'label='

      if _odd>0 then
       if txt[_odd]='=' then begin
        SetLength(txt, _odd-1);
        dec(j);
       end;


      _odd := j;

      omin_spacje(j,str);

      if str[j]='=' then begin        // jesli nie odczytal znaku '='
       txt:=txt+'=';
       __inc(j,str);
       txt:=txt + get_dat(j,str,',',true);
      end else
       j := _odd;


      _odd:=High(par);  par[_odd]:=txt;

      SetLength(par,_odd+2);


      if str[j] in [',',' ',#9] then
       __next(j,str)
      else
       if mae and test_char(j,str,#0,#0) then Break;

    end;

end;


function TypeToByte(const a: char): byte;
begin

 case a of
  'B': Result := 1;
  'W': Result := 2;
  'L': Result := 3;
  'D': Result := 4;
 else
   Result := 0;
 end;

end;


function getByte(var pom: string; const ile: byte; const ch: Char): string;
begin

 Result:='';

      case ch of
       'W': case ile of
             2: pom[1]:='>';
             1: pom[1]:='<';
            end;

       'L': case ile of
             3: pom[1]:='^';
             2: pom[1]:='>';
             1: pom[1]:='<';
            end;

       'D': case ile of
             4: Result:='>>24';
             3: pom[1]:='^';
             2: pom[1]:='>';
             1: pom[1]:='<';
            end;
       end;
       
end;


function oblicz_mnemonik(var i:integer; var a,old:string): int5;
(*----------------------------------------------------------------------------*)
(*  funkcja zwraca wartosc typu INT5                                          *)
(*  INT5.L  -> liczba bajtow                                                  *)
(*  INT5.H  -> kod maszynowy mnemonika, ARGUMENTY                             *)
(*----------------------------------------------------------------------------*)
var j, m, idx, len: integer;
    op_, mnemo, mnemo_tmp, zm, tmp, str, pom, add: string;
    war, war_roz, help: Int64;
    code, ile, k, byt: byte;
    op, siz: char;
    test, zwieksz, incdec, mvnmvp, mSEP, mREP, pomin, opty: Boolean;
    tryb: cardinal;
    hlp: int5;
    par: _strArray;

const
 maska: array [1..23] of cardinal=(
 $01,$02,$04,$08,$10,$20,$40,$80,$100,$200,$400,$800,$1000,$2000,
 $4000,$8000,$10000,$20000,$40000,$80000,$100000,$200000,$400000);

 addycja: array [1..24] of byte=(
 0,0,4,8,8,12,16,20,20,24,28,44,0,0,8,4,8,16,20,24,24,32,32,32);

 addycja_16: array [1..207] of byte=(
 0,0,0,2,2,4,6,8,8,12,14,16,17,18,20,20,22,24,28,30,32,34,48,
 0,0,0,2,2,8,6,4,8,16,14,16,17,18,24,24,22,32,32,30,32,34,48,
 0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,220,
 0,0,0,0,0,0,0,0,0,0,16,0,0,0,0,0,0,0,0,0,32,144,48,
 0,0,0,0,0,0,0,101,0,8,0,0,0,0,16,0,0,0,24,0,0,0,0,
 0,0,0,0,0,0,0,0,0,56,0,0,0,0,16,0,0,0,58,0,0,0,0,
 0,0,0,0,0,0,0,146,0,0,0,0,114,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,140,0,0,0,148,0,0,0,0,156,0,0,0,164,0,0,0,0,
 0,0,0,0,0,204,0,0,0,212,0,0,0,0,220,0,0,0,228,0,0,0,0);

 // kod maszynowy mnemonika w pierwszej adresacji (CPU 6502)
 kod: array [0..55] of byte=(
 $A1,$9E,$9C,$81,$82,$80,$61,$21,
 $02,$E1,$14,$40,$42,$01,$C1,$BC,
 $DC,$C2,$E2,$41,$22,$62,$00,$18,
 $58,$B8,$D8,$08,$28,$48,$68,$40,
 $60,$38,$78,$F8,$C8,$E8,$88,$CA,
 $8A,$98,$9A,$A8,$AA,$BA,$EA,$10,
 $30,$D0,$90,$B0,$F0,$50,$70,$20);

 // kod maszynowy mnemonika w pierwszej adresacji (CPU 65816)
 kod_16: array [0..88] of byte=(
 $A1,$9E,$9C,$81,$82,$80,$61,$21,
 $02,$E1,$20,$4C,$42,$01,$C1,$BC,
 $DC,$3A,$1A,$41,$22,$62,$00,$18,
 $58,$B8,$D8,$08,$28,$48,$68,$40,
 $60,$38,$78,$F8,$C8,$E8,$88,$CA,
 $8A,$98,$9A,$A8,$AA,$BA,$EA,$10,
 $30,$D0,$90,$B0,$F0,$50,$70,$24,
 $64,$DE,$BE,$10,$00,$80,$FE,$54,
 $44,$62,$8B,$0B,$4B,$DA,$5A,$AB,
 $2B,$FA,$7A,$6B,$DB,$5B,$1B,$7B,
 $3B,$9B,$BB,$CB,$42,$EB,$FB,$3A,
 $1A);

 // mozliwe adresacje rozkazu (10 bitow) CPU6502
 // bity w najstarszym bajcie oznaczaja przesuniecie w tablicy 'ADDYCJA'
 ads: array [0..55] of cardinal=(
 $000006ED,$8000032C,$800004AC,$000006E5,$00000124,$000000A4,$000006ED,$000006ED,
 $000004B4,$000006ED,$00000020,$00000820,$000004B4,$000006ED,$000006ED,$8000002C,
 $8000002C,$000004A4,$000004A4,$000006ED,$000004B4,$000004B4,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000002,
 $00000002,$00000002,$00000002,$00000002,$00000002,$00000002,$00000002,$00000024);

 // mozliwe adresacje rozkazu (32 bity) CPU65816
 // bity w najstarszym bajcie oznaczaja przesuniecie w tablicy 'ADDYCJA_16'
 ads_16: array [0..88] of cardinal=(
 $000F7EE9,$800282A0,$800442A0,$000F7E69,$00008220,$00004220,$000F7EE9,$000F7EE9,
 $00044320,$000F7EE9,$40400600,$20700600,$00044320,$000F7EE9,$000F7EE9,$800002A0,
 $800002A0,$02044320,$01044320,$000F7EE9,$00044320,$00044320,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000002,
 $00000002,$00000002,$00000002,$00000002,$00000002,$00000002,$00000002,$100442A0,
 $08044220,$80000080,$80000080,$00000220,$00000220,$00000012,$80000080,$00000004,
 $00000004,$04001280,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,
 $00000000);

begin
 Result.l:=0;

 if a='' then blad(old,12);

 op_:=''; siz:=' '; op:=' ';

 war_roz:=0;                        

 mvnmvp:=true; mSEP:=false; mREP:=false; pomin:=false; ext_used.use:=false;

 zwieksz:=false; incdec:=false; reloc:=false; branch:=false;   mne_used:=false;

 omin_spacje(i,a);

 m:=i;                  // zapamietaj pozycje

// pobierz nazwe rozkazu, oblicz jego CRC16
 mnemo:='';  mnemo_tmp:='';

 if _lab_first(a[i]) then
  while _lab(a[i]) or (a[i] in [':','%']) do begin
   mnemo:=mnemo+UpCase(a[i]);
   mnemo_tmp:=mnemo_tmp+UpCas_(a[i]);
   inc(i);
  end;


 // asemblujemy procedury .PROC do ktorych wystapilo odwolanie w programie
 // przelacznik -x 'Exclude unreferenced procedures' musi byc uaktywniony
 if exclude_proc then
  if proc and (pass>0) then
   if not(t_prc[proc_nr-1].use) then exit;


 // jesli czytamy tablice ARRAY to linia zaczyna sie znakiem '(' lub '['
 // jesli innym niz znaki konca linii to blad 'Improper syntax'
 if aray then
  if a[i] in ['[','('] then begin
   Result.l:=__array_val; exit
  end else
   if not(_eol(a[i])) then blad(old,58);


 // jesli brakuje mnemonika to sprawdz czy nie jest to cyfra (blad 'Illegal instruction')
 // w innym przypadku nie przetwarzamy tego i wychodzimy
  if mnemo='' then
   if _dec(a[i]) or (a[i] in ['$','%']) then blad(old,12) else exit;


 // wyjatek znak '=' jest rownowazny 'EQU'
 // dla etykiety zaczynajacej sie od pierwszego znaku w wierszu
 if mnemo='=' then begin Result.l:=__equ; exit end;


 // jesli wystepuje znak ':' tzn ze laczymy mnemoniki w stylu XASM'a
 j:=pos(':',mnemo);
 if j>0 then begin
   Result.i:=i;
   i:=m;                      // modyfikujemy wartosc spod adresu 'i'
   Result.l:=__xasm;
   exit;
 end;


// sprawdz czy to operacja przypisania '=' , 'EQU' , '+=' , '-=' , '++' , '--'
// dla etykiety poprzedzonej minimum jedna spacja lub tabulatorem

 j:=i;

 omin_spacje(i,a);

 tmp:='';

 if UpCase(a[i])='E' then
  tmp:=get_datUp(i,a,#0,false)
 else
  while a[i] in ['=','+','-'] do begin
   tmp:=tmp+a[i];
   inc(i)
  end;

 if tmp<>'' then
  if (tmp='EQU') or (tmp='=') or (tmp='+=') or (tmp='-=') or (tmp='++') or (tmp='--') then begin
   i:=m;                      // modyfikujemy wartosc spod adresu 'i'
   Result.l:=__addEqu;
   exit;
  end;

 i:=j;


 len:=length(mnemo);


// sprawdz czy wystapilo rozszerzenie mnemonika
 if len=5 then
  if a[i-2]='.' then
                    case UpCase(a[i-1]) of
                     'A','W','Q': siz:='Q';
                         'B','Z': siz:='Z';
                         'L','T': siz:='T';
                    end;


// poszukaj mnemonika w tablicy HASH
 k:=0;

 if len=3 then
  k:=fASC(mnemo)
 else
  if siz<>' ' then begin     // jesli SIZ<>' ' tzn ze jest to 3-literowy mnemonik z rozszerzeniem
 {   tmp:=mnemo;
    SetLength(tmp,3);   }
    
    k:=fASC(mnemo);
    if k>0 then SetLength(mnemo,3); //mnemo:=tmp;
  end;


 if not(opt and 16>0) then
  if k in [57..89] then k:=0;    // symbole mnemonikow maja kody <1..89>
                                 // symbole mnemonikow 6502      <1..56>
                                 // symbole mnemonikow 65816     <57..89>

// w IDX przechowujemy aktualny adres asemblacji, tej zmiennej nie uzyjemy w innym celu

if k in [__cpbcpd..__jskip] then begin

 if adres<0 then
  if pass=pass_end then blad(old,10);

 if siz<>' ' then blad(old,33);

 if not(k in [__BckSkp, __phrplr]) then begin     // __BckSkp i __phrplr nie potrzebuja parametrow

  omin_spacje(i,a);

  SetLength(par, 1);
  while not(test_char(i,a,#0,#0)) do begin

   idx:=High(par);

   par[idx]:=get_dat(i,a,' ',true);

   if par[idx][1] in ['<','>'] then insert('#',par[idx],1);

   SetLength(par, idx+2);

   omin_spacje(i,a);
  end;

  tmp:=par[0];
 end;

 idx := adres;

 Result.l:=0;

// str_blad := old;

 case k of

// obsluga PHR, PLR
 __phrplr:
 begin

  Result.l:=5;

  if mnemo[2]='H' then begin
   Result.h[0]:=$48;
   Result.h[1]:=$8a;
   Result.h[2]:=$48;
   Result.h[3]:=$98;
   Result.h[4]:=$48;
  end else begin
   Result.h[0]:=$68;
   Result.h[1]:=$a8;
   Result.h[2]:=$68;
   Result.h[3]:=$aa;
   Result.h[4]:=$68;
  end;

 end;


// obsluga INW, INL, IND, DEW, DEL, DED
 __inwdew:
 begin

  if High(par)<1 then blad(old,23);

  Result.l:=0;

  ile:=TypeToByte(mnemo[3]);

  mnemo[3]:='C';


  if mnemo[1]='I' then begin         // INW, INL, IND

   str:='##INC#DEC'+IntToStr(ora_nr);

   j:=load_lab(str,false);        // odczytujemy wartosc etykiety

   if j>=0 then
    tryb:=t_lab[j].adr
   else
    tryb:=0;

   j:=0;

   while ile>0 do begin
     zm:=mnemo + #32 + tmp + '+' + IntToStr(j);
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     if ile>1 then begin
      zm:='BNE '+IntToStr(tryb);
      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);
     end;

     inc(j);
     dec(ile);
   end;

   save_fake_label(str,old, adres);

   inc(ora_nr);

  end else begin                     // DEW, DEL, DED

   byt:=0;

   while byt<ile-1 do begin

     zm:='LDA ' + tmp + '+' + IntToStr(byt);
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     str:='##INC#DEC'+IntToStr(ora_nr+byt);

     j:=load_lab(str,false);         // odczytujemy wartosc etykiety

     if j>=0 then
      tryb:=t_lab[j].adr
     else
      tryb:=0;

     zm:='BNE '+IntToStr(tryb);
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     inc(byt);
   end;

   inc(byt);

   while byt<>0 do begin

     if byt<>ile then begin
      str:='##INC#DEC'+IntToStr(ora_nr+byt-1);
      save_fake_label(str,old, adres);
     end;

     zm:='DEC ' + tmp + '+' + IntToStr(byt-1);
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     dec(byt);
   end;

   inc(ora_nr, ile-1);
  end;

 end;


// obsluga ADW, SBW
 __adwsbw:
 begin
    if High(par)<2 then blad(old,23);

    str:=par[1];
    pom:=par[2];

    test:=false;
    if pom='' then
     pom:=tmp                        // w POM wynik operacji
    else
     test:=true;

    if tmp[1]='#' then blad(old,14);

    mnemo[3] := 'C';                 // ADC, SBC

    if mnemo[1]='S' then
     zm:='SEC'
    else
     zm:='CLC';

    Result:=asm_mnemo(zm,old);

    zm:='LDA ' + tmp;

    hlp:=asm_mnemo(zm,old);
    addResult(hlp, Result);

    ile:=hlp.h[0];

    opty:=false;
    if ile=$B1 then opty:=true;      // wystepuje LDA(),Y


    if not(ile in [$A5,$AD,$B5,$BD]) then
     test:=true;                     // nie przejdzie krotsza wersja z SCC, SCS


    if str[1]='#' then begin
     str[1]:='+';
     branch:=true;                   // nie relokujemy, testujemy tylko wartosc
     war:=oblicz_wartosc(str,old);
     wartosc(old,war,'A');
    
     str[1]:='<';
     zm:=mnemo + #32 + str;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     zm:='STA '+pom;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     if not(test) and (war<256) then begin

      if mnemo[1]='S' then
       zm:='SCS'
      else
       zm:='SCC';

      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);

      test_skipa;

      if mnemo[1]='S' then
       zm:='DEC ' + tmp + '+1'
      else
       zm:='INC ' + tmp + '+1';

      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);
       
     end else begin

      if opty then begin
       hlp.l:=1;
       hlp.h[0]:=$c8;               // $C8 = INY
       addResult(hlp,Result);

       add:='';
      end else
       add:='+1';

      zm:='LDA ' + tmp + add;
      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);

      str[1]:='>';
      zm:=mnemo + #32 + str;
      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);

      zm:='STA ' + pom + add;
      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);
     end;

    end else begin
     zm:=mnemo + #32 + str;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     byt:=hlp.h[0];

     zm:='STA ' + pom;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     if opty then begin
      hlp.l:=1;
      hlp.h[0]:=$c8;               // $C8 = INY
      addResult(hlp,Result);

      add:='';
     end else
      add:='+1';

      
     if byt in [$71,$F1] then begin         // $71 = ADC(),Y ; $F1 = SBC(),Y

      if not(opty) then begin
       hlp.l:=1;
       hlp.h[0]:=$c8;              // $C8 = INY
       addResult(hlp,Result);

       if (ile in [$b6,$b9,$be]) then add:='';
      end;

     end else
      if not(opty and (byt=$79)) then str:=str+'+1';

     zm:='LDA ' + tmp + add;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     zm:=mnemo + #32 + str;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     zm:='STA ' + pom + add;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);
    end;

 end;


// obsluga ADB, SBB
 __adbsbb:
 begin
    if High(par)<2 then blad(old,23);

    str:=par[1];
    pom:=par[2];

    if pom='' then begin
     pom:=tmp;

     if tmp[1]='#' then
      if str[1]<>'#' then pom:=str;

    end;

    zm:='LDA ' + tmp;
    Result:=asm_mnemo(zm,old);

    if mnemo[1]='S' then
     zm:='SUB '
    else
     zm:='ADD ';

    zm:=zm + str;
    hlp:=asm_mnemo(zm,old);
    addResult(hlp, Result);

    zm:='STA ' + pom;
    hlp:=asm_mnemo(zm,old);
    addResult(hlp, Result);
 end;

 
// obsluga ADD, SUB
 __addsub:
 begin

  if High(par)<1 then blad(old,23);

  inc(adres);

  mnemo[2]:=mnemo[3];
  mnemo[3]:='C';
  Result.l:=1;

  if mnemo[1]='A' then
   Result.h[0]:=$18               // kod dla CLC
  else
   Result.h[0]:=$38;              // kod dla SEC

  zm:=mnemo + #32 + tmp;
  hlp:=asm_mnemo(zm,old);
  addResult(hlp, Result);
 end;


// obsluga MVA, MVX, MVY, MWA, MWX, MWY
 __movaxy:
 begin

  if High(par)<2 then blad(old,23);

  zm:=par[1];

  op:=tmp[1];
  Result.l:=0;

  opty:=false;

  if mnemo[2]='W' then begin          // MW?

    if op='#' then begin

     variable:=false;                 // domyslnie VARIABLE=FALSE, czyli nie jest to zmienna

     tmp[1]:='+';
     branch:=true;                    // nie relokujemy, testujemy tylko wartosc
     war:=oblicz_wartosc(tmp,old);
     wartosc(old,war,'A');

     if not(dreloc.use) and not(dreloc.sdx) then
      if not(variable) then           // jesli nie jest to zmienna to testujemy dalej
       if byte(war)=byte(war shr 8) then opty:=true;

     tmp[1]:='<';
    end;

    Result:=moveAXY(mnemo,tmp,zm,old);

    test:=false;

    if not(opty) then
    if op='#' then
     tmp[1]:='>'
    else                                     // wyj¹tek MWA (ZP),Y ADR
     if Result.h[0]<>$B1 then begin          // $B1 = LDA(ZP),Y
      if Result.tmp=$91 then begin
       if not(Result.h[0] in [$b6,$b9,$be]) then tmp:=tmp+'+1';
      end else tmp:=tmp+'+1';
     end else begin
      hlp.l:=1;
      hlp.h[0]:=$c8;                   // $C8 = INY
      addResult(hlp,Result);

      test:=true;
     end;

    if Result.tmp=$91 then begin       // $91 = STA(ZP),Y
     if Result.h[0]<>$B1 then begin
      hlp.l:=1;
      hlp.h[0]:=$c8;                   // $C8 = INY
      addResult(hlp,Result);
     end;
    end else                                                        
     if test then begin                                     // $96 = STX Z,Y
      if not(Result.tmp in [$96,$99]) then zm:=zm+'+1';     // $99 = STA Q,Y
     end else
      zm:=zm+'+1';

  end;


  if opty then begin

   tmp:=mnemo + #32 + zm;
   hlp:=asm_mnemo(tmp, old);

  end else
   hlp:=moveAXY(mnemo,tmp,zm,old);     // MV?


  addResult(hlp,Result);
 end;


// obsluga JEQ, JNE, JPL, JMI, JCC, JCS, JVC, JVS
 __jskip:
 begin

  mnemo[1]:='B';              // zamieniamy pseudo rozkaz na mnemonik
  k:=fASC(mnemo);             // wyliczamy kod dla mnemonika

  branch:=true;      // nie relokujemy
  war:=oblicz_wartosc(tmp,old);

  test:=false; war:=war-2-adres;

  if (war<0) and (abs(war)-128>0) then test:=true;
  if (war>0) and (war-127>0) then test:=true;


  if not(test) then begin

   Result.l:=2;
   Result.h[0]:=kod[k-1] {xor $20};     // kod maszynowy mnemonika w pierwszej adresacji 6502
   Result.h[1]:=byte(war);

  end else begin

   inc(adres,2);

   Result.l:=2;
   Result.h[0]:=kod[k-1] xor $20;     // kod maszynowy mnemonika w pierwszej adresacji 6502
   Result.h[1]:=3;

   zm:='JMP ' + tmp;
   hlp:=asm_mnemo(zm,old);
   addResult(hlp,Result);
  end;

 end;


// sprawdzamy czy nie sa to pseudo rozkazy skoku
// req, rne, rpl, rmi, rcc, rcs, rvc, rvs  -> b??  skok do tylu
// seq, sne, spl, smi, scc, scs, svc, svs  -> b??  skok do przodu

 __BckSkp:
   begin

    if mnemo[1]='R' then begin

     if (pass=pass_end) and skip.xsm then warning(99);  // Repeating only the last instruction

     if t_bck[0]<0 then begin
      if pass=pass_end then blad(old,110);              // No instruction to repeat
      war:=0;
     end else
      war:=t_bck[0];

    end else begin
     if skip.idx+1<=High(t_skp) then war:=t_skp[skip.idx+1] else war:=adres;

     skip.use:=true;
     skip.cnt:=0;
    end;

     war:=war-2-adres;

     if (war<0) and (abs(war)-128>0) then war:=abs(war)-128;
     if (war>0) and (war-127>0) then dec(war, 127); //war:=war-127;

     mnemo[1]:='B';              // zamieniamy pseudo rozkaz na mnemonik
     k:=fASC(mnemo);             // wyliczamy kod dla mnemonika

     code:=kod[k-1];             // kod maszynowy mnemonika w pierwszej adresacji 6502

     Result.l := 2;
     Result.h[0] := code;
     Result.h[1] := byte(war);
     inc(adres,2);
   end;

   
 __cpbcpd:
   begin

    if High(par)<2 then blad(old,23);

    pom:=par[1];

    ile:=TypeToByte(mnemo[3]);

    Result.l:=0;


    str:='##CMP#'+IntToStr(ora_nr);

    j:=load_lab(str,false);        // odczytujemy wartosc etykiety

    if j>=0 then
     tryb:=t_lab[j].adr
    else
     tryb:=0;

    if tmp[1]='#' then test:=true else test:=false;
    if pom[1]='#' then opty:=true else opty:=false;


    while ile>0 do begin

    
     if test then
      add:=getByte(tmp, ile, mnemo[3])
     else
      add:='+'+IntToStr(ile-1);

     zm:='LDA '+tmp + add;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);


     if opty then
      add:=getByte(pom, ile, mnemo[3])
     else
      add:='+'+IntToStr(ile-1);

     zm:='CMP '+pom + add;
     hlp:=asm_mnemo(zm,old);
     addResult(hlp, Result);

     if ile>1 then begin
      zm:='BNE '+IntToStr(tryb);
      hlp:=asm_mnemo(zm,old);
      addResult(hlp, Result);
     end;

     dec(ile);
    end;

    str:='##CMP#'+IntToStr(ora_nr);
    save_fake_label(str,old, adres);

    inc(ora_nr);
   end;

 end;

 adres := idx;

 mne_used := true;           // zostal odczytany jakis mnemonik
 exit;                       // !!! KONIEC !!! zostal odczytany i zdekodowany makro-rozkaz
end;



// sprawdz czy to nazwa makra
 if k=0 then begin

    idx:=load_lab(mnemo_tmp,false);     // poszukaj w etykietach

    if idx<0 then begin
     if pass=pass_end then blad_und(old,mnemo,35);
     exit;
    end;

    if t_lab[idx].bnk=__id_ext then             // symbol external
     if t_extn[t_lab[idx].adr].prc then begin

      tmp:='##'+t_extn[t_lab[idx].adr].nam;

      Result.i:=t_lab[l_lab(tmp)].adr;
      Result.l:=byte(__id_proc);

      exit;
     end;


//    if (t_lab[idx].bnk=__id_macro) then begin Result.l:=__nill; exit end;

    if t_lab[idx].bnk>=__id_macro then begin
     Result.l:=byte(t_lab[idx].bnk);
     Result.i:=t_lab[idx].adr;
    end else
     blad_und(old,mnemo,35);

    exit;
 end;

 dec(k);


// znalazl pseudo rozkaz
 if k>=__equ then
  if siz<>' ' then
   blad(old,33)
  else begin
   Result.l:=k; exit
  end;


// if macro then exit;   // jesli jest to makro to koniecznie konczymy inaczej moze nam namieszac


 if first_org and (opt and 1>0) then blad(old,10);


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
// na podstawie kodu maszynowego CODE mozna juz okreslic jaki to rozkaz       //
// nie trzeba porownywac stringow, czy zamieniac mnemonik na wartosc cyfrowa  //
// w celu pozniejszego porownania                                             //
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//

 if (opt and 16>0) then begin
  code:=kod_16[k];                // kody maszynowe 65816 sa z przedzialu <0..88>
  tryb:=ads_16[k];                // kod maszynowy mnemonika w pierwszej adresacji 65816
 end else begin
//  if k>55 then blad(a,14);        // kody maszynowe 6502 sa z przedzialu <0..55>
  code:=kod[k];                   // kod maszynowy mnemonika w pierwszej adresacji 6502
  tryb:=ads[k];
 end;


// w .STRUCT i .ARRAY nie ma mozliwosci uzywania rozkazow CPU
// podobnie w bloku EMPTY (.ds) nie moga wystepowac rozkazy CPU
 if struct or aray or empty then blad(old,58);

// jesli mnemonik nie wymaga argumentu to skoncz
 if tryb=0 then begin

  if siz<>' ' then blad(old,33);

  test_eol(i,a,a,#0);

  Result.l:=1; Result.h[0]:=code;

  mne_used := true;          // zostal odczytany jakis mnemonik

  exit;
 end;


// omin spacje i przejdz do argumentu
 omin_spacje(i,a);

// jesli wystepuja operatory #<, #> to omin pierwszy znak i pozostaw <,>
 if a[i]='#' then begin
  idx:=i;
  __inc(i,a);
  if not(a[i] in ['<','>','^']) then i:=idx;
 end;

 
 // pobierz operator argumentu do 'OP'
 // nie dotyczy to rozkazow MVN i MVP (65816)

// tst:=ord(mnemo[1]) shl 16+ord(mnemo[2]) shl 8+ord(mnemo[3]);


// if (mnemo<>'MVN') and (mnemo<>'MVP') then begin
// if (tst<>$4D564E) and (tst<>$4D5650) then begin

 if not(code in [68,84]) then begin

  mvnmvp:=false;
  if a[i] in ['#','<','>','^'] then begin
   if not(dreloc.use) then branch:=true;             // nie relokuj tego rozkazu
   op:=a[i]; inc(i)
  end else op:=' ';

  if (a[i]='@') and (_eol(a[i+1])) then begin op:='@'; inc(i) end;

  if (op='@') then
   if (siz<>' ') then blad(old,33) else test_eol(i,a,a,#0);
 end;

 omin_spacje(i,a);

 // wyjatki dla ktorych rozmiar rejestru jest staly
 if (opt and 16>0) and (op='#') then
  case code of
    98: test_siz(a,siz,'Q',pomin);                       // PEA #Q
   254: test_siz(a,siz,'Z',pomin);                       // COP #Z
   190: begin test_siz(a,siz,'Z',pomin); mREP:=true end; // REP #Z
   222: begin test_siz(a,siz,'Z',pomin); mSEP:=true end; // SEP #Z
  end;


 m:=i; zm:=get_dat(m,a,';',false);

 if white_spaces then begin
  m:=i; zm:=get_dat_noSPC(m,a,';',#0,old);
 end;

 tmp:='';


 // jesli brak argumentu przyjmij domyslnie aktualny adres '*'
 // lub operator '@' gdy ASL , ROL , LSR , ROR
  if (zm='') and (op=' ') then begin

   if code in [2,34,66,98] then
    op:='@'
   else begin
    zm:='*';
    if not(klamra_used) then
     if pass=0 then blad(old,23);            // 'Default addressing mode' -67- wycofany
   end;

  end;


// jesli jest nawias otwierajacy '(' lub '[' to sprawdz poprawnosc
// i czy nie ma miedzy nimi spacji
 if zm<>'' then begin
  j:=1;

 if (op=' ') and (zm[1] in ['[','(']) then begin

 if white_spaces then
  tmp:=get_dat_noSPC(j,zm,',',#0,a)
 else
  tmp:=get_dat(j,zm,',',true);
  

 if length(tmp)=2 then blad(old,14);      // nie bylo argumentu pomiedzy nawiasami

 // jesli po nawiasie wystapi znak inny niz ',',' ',#0 to BLAD
  if white_spaces then omin_spacje(j,zm);

  test_eol(j,zm,a,',');

 // przepisz znak nastepujacy po ',' do 'OP_'
 if zm[j]=',' then begin

  __inc(j,zm);

  if test_param(j,zm) then begin Result.l:=__nill; exit end else
  if UpCase(zm[j]) in ['X','Y','S'] then begin
   op_:=op_+UpCase(zm[j]); //zm[j]:=' ';

    if zm[j+1] in ['+','-'] then begin

     if UpCase(zm[j])='S' then blad(old,4);       // + - nie moze byc dla 'S'

     incdec:=true;

      case zm[j+1] of
       '-': //war_roz:=oblicz_wartosc('{de'+zm[j]+'}',a);
            if UpCase(zm[j])='X' then war_roz:=$CA else war_roz:=$88;   // dex, dey
       '+': //war_roz:=oblicz_wartosc('{in'+zm[j]+'}',a);
            if UpCase(zm[j])='X' then war_roz:=$E8 else war_roz:=$C8;   // inx, iny
      end;

     test_eol(j+2,zm,a,#0);
    end else test_eol(j+1,zm,a,#0);

  end else blad(old,14);
 end;

 // usun z ciagu znaki '()' lub '[]' i przepisz do 'OP_'
  op_:=op_+zm[1];
  zm:=copy(tmp,2,length(tmp)-2);
  j:=1;
 end;


 if white_spaces then
  tmp:=get_dat_noSPC(j,zm,',',#0,a)
 else
  tmp:=get_dat(j,zm,',',false);


// teraz jesli wystapi znak inny niz ',' to BLAD
 case op of
  '#','<','>','@','^': test_eol(j,zm,a,#0);
 else
  test_eol(j,zm,a,',');
 end;


// przepisz znak nastepujacy po ',' do 'OP_', jesli jest to 'XYS'
// w przeciwnym wypadku wylicz wartosc po przecinku
 if zm[j]=',' then

  if mvnmvp then begin
//   inc(j);
   __inc(j,zm);
   str:=get_dat(j,zm,' ',true);
   war_roz:=oblicz_wartosc(str,a);
   op_:=op_+value_code(war_roz,a,true);

  end else begin

  __inc(j,zm);

   if test_param(j,zm) then begin Result.l:=__nill; exit end else
   if UpCase(zm[j]) in ['X','Y','S'] then begin
    op_:=op_+UpCase(zm[j]);

    if zm[j+1] in ['+','-'] then begin
     if _eol(zm[j+2]) then begin

      if UpCase(zm[j])='S' then blad(old,4);      // + - nie moze byc dla 'S'

      incdec:=true;

       case zm[j+1] of
        '-': //war_roz:=oblicz_wartosc('{de'+zm[j]+'}',a);
             if UpCase(zm[j])='X' then war_roz:=$CA else war_roz:=$88;   // dex, dey
        '+': //war_roz:=oblicz_wartosc('{in'+zm[j]+'}',a);
             if UpCase(zm[j])='X' then war_roz:=$E8 else war_roz:=$C8;   // inx, iny
       end;

      inc(j,2);
     end else begin
      zwieksz:=true; inc(j);
      war_roz:=___wartosc_noSPC(zm,a,j,#0,'F');
     end;

    end else inc(j);

   end else blad(old,14);
  end;

//  end;
  test_eol(j,zm,a,#0);
 end;


 // jesli to rozkaz skoku to nie relokujemy (BRANCH=TRUE)
 if (mnemo[1]='B') and (mnemo[2]<>'I') then branch:=true;

 if adres<0 then
  if pass=pass_end then blad(old,10);        // adres<0 na pewno nie bylo ORG'a


// oblicz wartosc argumentu mnemonika, jesli brak argumentu to 'WAR=0'
 war:=0;
 if not((tmp='') and (op='#')) then
  if op<>'@' then war:=oblicz_wartosc(tmp,old);

 if zwieksz then inc(war, war_roz); //war:=war+war_roz;

 op_:=op_+value_code(war,a,true);

 if mvnmvp then war:=war + byte(war_roz) shl 8;

 
 if abs(war)>$FFFFFFFF then blad(old,0);
 

 // wyjatki dotycza skokow warunkowych B??
 if (mnemo[1]='B') and (mnemo[2]<>'I') then begin
  if (siz<>' ') and not(dreloc.use) then blad(old,33);

  op_:='B';

   test:=false; war:=war-2-adres; war_roz:=war;

   if (war<0) and (abs(war)-128>0) then begin war:=abs(war)-128; test:=true end;
   if (war>0) and (war-127>0) then begin {war:=war-127;} dec(war, 127); test:=true end;

   if test then
    if (mnemo[2]='R') and (mnemo[3]='A') then begin    // mnemo='BRA'
     op_:='W'; test:=false; war:=war_roz-1;
     if (war<0) and (abs(war)-32768>0) then begin war:=abs(war)-32768; test:=true end;
     if (war>0) and (war-32767>0) then begin {war:=war-32767;} dec(war, 32767); test:=true end;
    end;

   if (pass=pass_end) and test then blad(old,integer(-war));
 end;


 // na podstawie 'OP' okresl adresacje 'OP_'
 case op of
  '#','<','>','^': op_:='#';
              '@': op_:='@';
 end;


// znajdz obliczona adresacje w tablicy 'adresacja'
// oraz sprawdz czy dla tego mnemonika jest mozliwa ta adresacja
//
// jesli nie znalazl to zmien rodzaj argumentu Z->Q

 // jesli 65816 to wstaw znak '~'
 if (opt and 16>0) then op_:='~'+op_;

 len:=length(op_);
   

// jesli rozkaz relokowalny (RELOC=TRUE) wymus rozmiar 'Q'
 if reloc and not(dreloc.use) then
  if siz='T' then blad(old,12) else
   if not(op in ['<','>','^']) then siz:='Q';


// jesli wystapila etykieta external (EXT_USED.USE=TRUE) wymus rozmiar EXT_USED.SIZ
 if ext_used.use and (ext_used.siz in ['B','W','L']) then begin

  if op in ['<','>','^'] then blad(old,85);

  case ext_used.siz of
   'B': siz:='Z';
   'W': siz:='Q';
   'L': siz:='T';
  end;

 end;


// sprawdz czy wystapilo rozszerzenie mnemonika
// zmodyfikuj wielkosc operandu na podstawie 'SIZ'
 if siz<>' ' then
  case op_[len] of
   'Q': if siz<>'Z' then
         op_[len]:=siz
        else
         if pass=pass_end then blad(old,31);

   'T': if siz='T' then
         op_[len]:='T'
        else
         if pass=pass_end then blad(old,31);

   '#': if siz='T' then
         blad(old,14)
        else
         if (siz='Z') and (abs(war)>$FF) then blad(old,31);
         
   'Z': op_[len]:=siz;
  end;


 j:=adrMode(op_);

 if (j=0) or (tryb and maska[j]=0) then
  if op_[len]='Z' then begin
   op_[len]:='Q';

   j:=adrMode(op_);

   if (j=0) or (tryb and maska[j]=0) then blad(old,14);
  end else
   if pass=pass_end then blad(old,14);

  
 if opt and 16>0 then begin
  ile:=0;
  for k:=8 downto 1 do
   if ((tryb shr 24) and maska[k]>0) then ile:=byte( (9-k)*23 );

{  if tryb and $80000000>0 then ile:=23;
  if tryb and $40000000>0 then ile:=2*23;
  if tryb and $20000000>0 then ile:=3*23;
  if tryb and $10000000>0 then ile:=4*23;
  if tryb and $08000000>0 then ile:=5*23;
  if tryb and $04000000>0 then ile:=6*23;
  if tryb and $02000000>0 then ile:=7*23;
  if tryb and $01000000>0 then ile:=8*23;}

  inc(code, addycja_16[j+ile])       //code:=byte( code+addycja_16[j+ile] )

 end else
  if (tryb and $80000000>0) then
   inc(code, addycja[j+12])          //code:=code+addycja[j+12]
  else
   inc(code, addycja[j]);            //code:=code+addycja[j];


// obliczenie wartosci 'WAR' na podstawie 'OP'
// WAR moze byc dowolna wartoscia typu D-WORD

 help:=war;
 if dreloc.use and rel_used then dec(help,rel_ofs);

 case op of
  '<': war := byte( wartosc(a,help,'D') );
  '>': begin war := byte( wartosc(a,help,'D') shr 8 );  _sizm( byte(help) ) end;
  '^': begin war := byte( wartosc(a,help,'D') shr 16 ); _sizm( byte(help) ) end;
 end;

// policz z ilu bajtow sklada sie rozkaz wraz z argumentem
 ile:=1;

 if not(mvnmvp) then
  if incdec then begin
   inc(ile);
   case op_[len] of
    'Z': war := war + byte(war_roz) shl 8;
    'Q': war := war + byte(war_roz) shl 16;
    'T': war := war + byte(war_roz) shl 24;
   end;
  end;

 if op_='~ZZ' then inc(ile,2)
 else
  case op_[len] of
   '#': begin
         if siz=' ' then siz:=value_code(war,a,false);

         case siz of
          'Z': begin
                war:=wartosc(a,war,'B');
                inc(ile)
               end;

          'Q': if (opt and 16=0) then
                blad(old,0)
               else begin
                war:=wartosc(a,war,'A');
                inc(ile,2)
               end;
         end;

        end;
   'Z','B': inc(ile);
   'Q','W': inc(ile,2);
   'T': inc(ile,3);
  end;


// okreslamy rozmiar relokowalnego argumentu B,W,L,<,>  
 if dreloc.use and rel_used then begin

  case op_[len] of
       '#': if (op in ['<','>','^']) then dreloc.siz:=op;
   'Z','B': dreloc.siz:=relType[1];
   'Q','W': dreloc.siz:=relType[2];
       'T': dreloc.siz:=relType[3];
   end;

  if not(ext_used.use) then dec(war,rel_ofs);  // nie wolno modyfikowac argumentu symbolu EXTERNAL

  _siz(true);

  rel_used:=false;
 end;


 // tutaj przeprowadzamy operacje sledzenia rozmiaru rejestrow A,X,Y
 // modyfikowanych przez rozkazy REP, SEP
  if pass=pass_end then
  if macro_rept_if_test then
  if (opt and $40>0) then begin                  // wlaczona opcja sledzenia rozkazow SEP, REP

   if mSEP then reg_size( byte(war),true ) else
    if mREP then reg_size( byte(war),false );

  // sprawdzamy rozmiar rejestrow dla trybu adresowania natychmiastowego '#'
   if not(pomin) then
    if op_[len]='#' then
     case mnemo[3] of
      'A','C','D','P','R','T': test_reg_size(a,regA,ile);  // lda, adc, sbc, and, cmp, ror, bit
                          'X': test_reg_size(a,regX,ile);  // ldx
                          'Y': test_reg_size(a,regY,ile);  // ldy
     end;

  end;

 // preparujemy wynik, rozkaz CPU + argumenty

 Result.l := ile;

 Result.h[0] := code;
 Result.h[1] := byte(war);
 Result.h[2] := byte(war shr 8);
 Result.h[3] := byte(war shr 16);
 Result.h[4] := byte(war shr 24);

 mne_used := true;           // zostal odczytany jakis mnemonik

end;


function reserved(var ety: string): Boolean;
var v: byte;
begin
  v:=fASC(ety);

  Result := (v in [$80..$9f]);     // PSEUDO
  if Result then exit;

  if opt and 16>0 then
   Result := (v in [1..89])        // 65816
  else
   Result := (v in [1..56]);       // 6502

end;


procedure reserved_word(var ety,zm:string);
(*----------------------------------------------------------------------------*)
(*  testuj czy nie zostala uzyta zarezerwowana nazwa, np. nazwa pseudorozkazu *)
(*  lub czy nazwa zostala juz wczesniej uzyta                                 *)
(*----------------------------------------------------------------------------*)
begin
 if ety[1]='?' then warning(8);

 if length(ety)=3 then
  if reserved(ety) then blad_und(zm,ety,9);

 if rept then blad(zm,51);
 if proc then blad(zm,17);
 if load_lab(ety,true)>=0 then blad_und(zm,ety,2); // nazwa w uzyciu

// if ifelse<>0 then blad(zm,1);
end;


procedure zapisz_lokal;
begin
 t_loc[lokal_nr].nam := lokal_name;

 inc(lokal_nr);
 
 if lokal_nr>High(t_loc) then SetLength(t_loc,lokal_nr+1);
end;


procedure oddaj_lokal(var a: string);
begin
 if lokal_nr=0 then blad(a,28);
 dec(lokal_nr);

 lokal_name := t_loc[lokal_nr].nam;
end;


procedure oddaj_var;
var i, y: integer;
    txt, tmp: string;
begin

if var_idx>0 then begin

 tmp:='';

 for i:=0 to var_idx-1 do
  if t_var[i].lok = end_idx then begin

   txt := t_var[i].nam;

   if t_var[i].adr>=0 then begin

    nul.i:=t_var[i].adr;     if nul.i<0 then blad(global_name,87);
    save_lst(txt,'l');

    save_lab(txt,nul.i,bank,txt);

   end else begin

    nul.i:=adres;            if nul.i<0 then blad(global_name,87);
    save_lst(txt,'l');

    save_lab(txt,adres,bank,txt);

    for y:=t_var[i].cnt-1 downto 0 do
     case t_var[i].siz of
      1: save_dta(t_var[i].war , tmp , 'B' , 0);
      2: save_dta(t_var[i].war , tmp , 'A' , 0);
      3: save_dta(t_var[i].war , tmp , 'T' , 0);
      4: save_dta(t_var[i].war , tmp , 'F' , 0);
     end;

   end;

   tmp:=txt; zapisz_lst(tmp);

   t_var[i].lok:=-1;
  end;

// var_id  := 0;
// var_idx := 0;

 nul.i:=0;
 save_lst(txt,' ');       // koniecznie musi to tutaj byc

end;

end;


procedure add_blok(var a:string);
begin
 inc(blok);
 if blok>$FF then blad(a,45);
end;


procedure save_blk(const kod:integer; var a:string; const h:Boolean);
(*----------------------------------------------------------------------------*)
(*  BLK UPDATE ADDRESS                                                        *)
(*----------------------------------------------------------------------------*)
var x, y, i, j, k: integer;
    hea_fd, hea_fe, ok, tst: Boolean;
    txt: string;
begin
 txt:=a;

 for k:=blok downto 0 do begin

  hea_fd:=false; ok:=false;

// szukaj w glownym bloku

  for y:=0 to rel_idx-1 do
  if t_rel[y].idx=kod then
   if t_rel[y].blo=0 then
    if t_rel[y].blk=k then begin

     if not(hea_fd) then begin
      if h then begin
       save_lst(txt,'a');

       save_dstW( $fffd );
       save_dst( byte(K) );
       save_dstW( $0000 );

       zapisz_lst(txt);
      end;

      hea_fd:=true; ok:=true;
     end;

     save_lst(txt,'a');

     save_dst($fd);
     save_dstW( t_rel[y].adr );   // save_dst(byte(t_rel[y].adr shr 8));

     zapisz_lst(txt);

     t_rel[y].idx:=-100;      // wylacz z poszukiwan
    end;

// szukaj w blokach relokowalnych
  for x:=1 to blok do begin

  hea_fe:=false; j:=0; tst:=false;

  for y:=0 to rel_idx-1 do
  if t_rel[y].idx=kod then
   if t_rel[y].blo=x then
    if t_rel[y].blk=k then begin

     if not(tst) then begin
      save_lst(txt,'a');
      tst:=true;
     end;

     if not(hea_fe) then begin
      if not(hea_fd) and h then begin
       save_dstW( $fffd );
       save_dst( byte(K) );
       save_dstW( $0000 );

       hea_fd:=true;
      end;

      save_dst($fe);
      save_dst(byte(x));

      hea_fe:=true; ok:=true;
     end;

     j:=t_rel[y].adr-j;
     if j>=$fa then
      for i:=0 to (j div $fa)-1 do begin
       save_dst($ff);
       dec(j,$fa);
      end;

     save_dst(byte(j));
     j:=t_rel[y].adr;

     t_rel[y].idx:=-100;      // wylacz z poszukiwan
    end;

   if tst then zapisz_lst(txt);
  end;

  if ok then begin
   save_lst(txt,'a');

   save_dst($fc);

   zapisz_lst(txt);
  end;

 end;

end;


function get_pubType(var txt,zm:string; var _odd:integer): byte;
(*----------------------------------------------------------------------------*)
(* odczytujemy typ etykiety public, _ODD = indeks do etykiety w tablicy T_LAB *)
(*----------------------------------------------------------------------------*)
begin

  Result:=0;

  _odd:=load_lab(txt,false);

  if _odd<0 then blad_und(zm,txt,73);

// symbolami publicznymi nie moga byc etykiety przypisane do
// SMB, STRUCT, PARAM, EXT, MACRO

  if t_lab[_odd].bnk>=__id_param then Result := byte( t_lab[_odd].bnk );

  if Result >= byte (__id_param) then
   if not( Result in [byte(__id_proc), byte(__id_array)]) then blad_und(zm,txt,103);

end;


function get_smb(var i:integer; var zm:string): string;
(*----------------------------------------------------------------------------*)
(*  pobieramy 8 znakowy symbol SMB                                            *)
(*----------------------------------------------------------------------------*)
var txt: string;
    x: byte;
begin
 txt:=get_string(i,zm,zm,true);

 if length(txt)>8 then blad(zm,44);        // za dluga nazwa etykiety

 while length(txt)<8 do txt:=txt+' ';      // wyrownaj do 8 znakow

 for x:=1 to 8 do txt[x]:=UpCase(txt[x]);

 Result:=txt;
end;


procedure blk_update_new(var i:integer; var zm:string);
var txt, str: string;
    war, k: integer;
begin
            txt:=zm; zapisz_lst(txt); str:='';

            omin_spacje(i,zm);
            txt:=get_dat(i,zm,' ',true); if txt='' then blad(zm,23);


            if test_symbols then
             for war:=High(t_sym)-1 downto 0 do
              if txt=t_sym[war] then begin blad_und(zm,txt,2); exit end;

             
            war:=l_lab(txt); if war<0 then blad_und(zm,txt,5);
            k:=t_lab[war].blk; if k=0 then blad(zm,53);

            save_lst(str,'a');

          // dta a($fffc),b(blk_num),a(smb_off)
          // dta c'SMB_NAME'
            save_dstW( $fffc );
            save_dst(byte(k));
            save_dstW( t_lab[war].adr );  // save_dst(byte(t_lab[war].adr shr 8));

            zapisz_lst(str);
            save_lst(str,'a');

            txt:=get_smb(i,zm);
            for k:=1 to 8 do save_dst( ord(txt[k]) );

            zapisz_lst(txt);
            bez_lst:=true;
end;


procedure oddaj_sym;
var txt: string;
    i, k: integer;
begin

if sym_idx>0 then begin

 if adres<0 then blad(global_name,10);

 test_symbols := false;

 for i:=sym_idx-1 downto 0 do begin
 // preparujemy linie dla NEW SYMBOL
  txt:='BLK UPDATE NEW ' + t_sym[i] + ' ' + '''' + t_sym[i] + '''';

  save_lst(txt,'a');

  k:=16;  blk_update_new(k,txt);
 end;

end;

end;


procedure blk_empty(const idx: integer; var zm: string);
var indeks, tst: cardinal;
    _doo: integer;
    txt: string;
begin

 txt:=zm;
 save_lst(txt,'a');

                add_blok(zm);

              // a($fffe),b(blk_num),b(blk_id)
              // a(blk_off),a(blk_len)
                save_dstW( $fffe );
                save_dst(byte(blok));
                save_dst(memType or $80);

                save_dstW( adres ); //save_dst(byte(adres shr 8));
                save_dstW( idx );   //save_dst(byte(idx shr 8));

               // jesli deklaracja etykiet wystapila przed blokiem EMPTY
               // znajdz je i popraw im numer bloku
                indeks:=adres; tst:=adres+idx;

                for _doo:=0 to High(t_lab)-1 do
                 if (t_lab[_doo].adr>=indeks) and (t_lab[_doo].adr<=tst) then
                  t_lab[_doo].blk:=blok;

 zapisz_lst(txt);
end;


procedure oddaj_ds;
var zm, txt: string;
begin
 if ds_empty>0 then begin
  dec(adres, ds_empty);
  zm:='BLK EMPTY';

  if dreloc.sdx then begin        // dreloc.sdx BLOK EMPTY
   blk_empty(ds_empty, zm);  
  end else begin                  // dreloc.use BLOK EMPTY
   save_lst(zm,'a');

   save_dstW( __hea_address );
   save_dst( byte('E') );
   save_dstW( 1 );                // word(adres - rel_ofs) );
   save_dstW( ds_empty );

   txt:=zm; zapisz_lst(txt);
  end;

  ds_empty:=0;
 end;
end;


procedure blk_update_symbol(var zm:string);
var txt: string;
    _doo: integer;
    k: byte;
begin

 if smb_idx>0 then begin

             txt:=zm; zapisz_lst(txt);

             for _doo:=0 to smb_idx-1 do
              if t_smb[_doo].use then begin

              save_lst(txt,'a');

            // a($fffb),c'SMB_NAME',a(blk_len)
              save_dstW( $fffb );

              txt:=t_smb[_doo].smb;
              for k:=1 to 8 do save_dst( ord(txt[k]) );

              save_dstW( $0000 );

              zapisz_lst(txt);

              save_blk(_doo,txt,false);
             end;

             bez_lst:=true;
//             smb_idx:=0;
 end;
              
end;


procedure blk_update_address(var zm:string);
var txt: string;
    idx, i, _odd: integer;
    v: byte;
    ch: Boolean;
    tst: cardinal;
begin
            if not(dreloc.use) then

             save_blk(-1,zm,true)      // dla bloku Sparta DOS X

            else begin

             txt:=zm; zapisz_lst(txt);

            // naglowek $FFEF, typ, liczba adresow, adresy

{
  if rel_idx>0 then begin
   Writeln(rel_idx);
   for i:=0 to rel_idx-1 do
    Writeln(hex(t_rel[i].adr,4),',',t_rel[i].bnk,',',t_siz[t_rel[i].idx].siz,',',t_rel[i].idx,',',hex(t_siz[t_rel[i].idx].msb,2));
  end;  }

  
             for i:=1 to sizeof(relType) do begin       // dostepne typy B,W,L,D,<,>,^

              ch:=false;
              for idx:=0 to rel_idx-1 do
               if t_siz[t_rel[idx].idx].siz=relType[i] then begin ch:=true; Break end;

              if ch then begin

              save_lst(txt,'a');

            // A(HEADER = $FFEF)
              save_dstW( __hea_address );

            // najpierw zapiszemy do bufora aby dowiedziec sie ile ich jest
            // maksymalnie mozemy zapisac $FFFF adresow
              _odd:=0;
//              old_case:=false;                           // jesli bank=0 to FALSE
              for idx:=0 to rel_idx-1 do
               if t_siz[t_rel[idx].idx].siz=relType[i] then begin

//                if t_rel[idx].bnk>0 then old_case:=true; // jesli bank>0 to TRUE

                tst:= (t_rel[idx].adr and $FFFF) or (t_siz[t_rel[idx].idx].msb shl 16);
                t_tmp[_odd] := tst;

                inc(_odd);
                testRange(zm, _odd, 13);    // koniecznie blad 13 aby natychmiast zatrzymac
               end;

              v:=ord(relType[i]);  //if old_case then v:=v or $80;

              save_dst(v);                 // TYPE //+ MODE

              zapisz_lst(txt);
              save_lst(txt,'a');

             // zapisujemy informacje o liczbie adresow  DATA_LENGTH
              save_dstW( _odd );

            // teraz zapisujemy informacje o adresach

              for idx:=0 to _odd-1 do begin
              // bank etykiety external jesli MODE=1
//               if old_case then save_dst( byte(t_tmp[idx] shr 16) );

              // adres do relokacji
               save_dstW( t_tmp[idx] );


               case relType[i] of
                '>': save_dst( byte(t_tmp[idx] shr 16) );
                '^': blad(zm,27);
               end;

              end;

              zapisz_lst(txt);

              end; //if ch then begin

             end;

            end;

            bez_lst:=true;
            first_org:=true;
end;


procedure blk_update_external(var zm:string);
var txt: string;
    idx, _doo, _odd: integer;
    v: byte;
    ch: Boolean;
    tst: cardinal;
begin

 if dreloc.sdx then exit;

 if not(dreloc.use) then blad(zm,53);


 if extn_idx>0 then begin

             txt:=zm; zapisz_lst(txt);
             save_lst(txt,'a');

{
   Writeln(ext_idx);
   for i:=0 to ext_idx-1 do
    Writeln(hex(t_ext[i].adr,4),',',t_extn[t_ext[i].idx].nam);
}

             for _doo:=0 to extn_idx-1 do begin

              ch:=false;
              for idx:=0 to ext_idx-1 do
               if t_ext[idx].idx=_doo then begin ch:=true; Break end;

              if ch then begin     // czy wystapily w programie odwolania do etykiet external

              save_lst(txt,'a');

            // A(HEADER = $FFEE),b(TYPE)
              save_dstW( __hea_external );

            // najpierw zapiszemy do bufora aby dowiedziec sie ile ich jest
            // maksymalnie mozemy zapisac $FFFF adresow i ich numerow bankow
              _odd:=0;
//              old_case:=false;                          // jesli bank=0 to FALSE
              for idx:=0 to ext_idx-1 do
               if t_ext[idx].idx=_doo then begin

//                if t_ext[idx].bnk>0 then old_case:=true; // jesli bank>0 to TRUE

                tst:= (t_ext[idx].adr and $FFFF) or (t_ext[idx].bnk shl 16);
                t_tmp[_odd] := tst;

                inc(_odd);
                testRange(zm, _odd, 13);    // koniecznie blad 13 aby natychmiast zatrzymac
               end;

              v:=ord(t_extn[_doo].siz);  //if old_case then v:=v or $80;

              save_dst(v);                    // ext_label TYPE //+ MODE

              zapisz_lst(txt);
              save_lst(txt,'a');

             // zapisujemy informacje o liczbie adresow
              save_dstW( _odd );

           // A(EXT_LABEL_LENGTH) , C'EXT_LABEL'
              txt:=t_extn[_doo].nam;

              save_dstS(txt);                           // ext_label length, string


            // teraz zapisujemy informacje o adresach

              for idx:=0 to _odd-1 do begin
              // bank etykiety external
//               if old_case then save_dst( byte(t_tmp[idx] shr 16) );

              // adres etykiety external
               save_dstW( t_tmp[idx] );
              end;

              zapisz_lst(txt);

              end; //if ch then begin

             end;

//             extn_idx:=0;
             bez_lst:=true;
 end;
end;


procedure blk_update_public(var zm:string);
var txt, ety, str, tmp: string;
    x, idx, j, k, indeks, _odd, _doo, i, len, old_rel_idx, old_siz_idx: integer;
    v, sv: byte;
    ch, tp: char;
    test: Boolean;
    war: Int64;
    old_sizm0, old_sizm1: rSizTab;
begin

 if dreloc.sdx then exit;

 if pub_idx>0 then begin

             txt:=zm; zapisz_lst(txt);
             save_lst(txt,'a');

             _doo:=-1;

           // test obecnosci etykiet publicznych oraz test parametrow procedur __pVar

             for idx:=pub_idx-1 downto 0 do begin
              txt:=t_pub[idx].nam;

              v := get_pubType(txt,zm, _odd);

           // dodajemy do upublicznienia parametry procedury __pVar
           // pod warunkiem ze ich wczesniej jeszcze nie upublicznialismy
              if v = byte( __id_proc ) then
               if t_prc[t_lab[_odd].adr].typ = __pVar then begin

                k:=t_prc[t_lab[_odd].adr].par;        // liczba parametrow
                indeks:=t_prc[t_lab[_odd].adr].str;

                if k>0 then
                 for j:=0 to k-1 do begin
                  ety:=t_mac[j+indeks];

                // omijamy pierwszy znak okreslajacy typ parametru
                // i czytamy az nie napotkamy znakow nie nalezacych do nazwy etykiety

                  str:='';
                  i:=2;
                  len:=length(ety);

                  while i<=len do begin
                   if _lab(ety[i]) then str:=str+ety[i] else Break;
                   inc(i);
                  end;

//                  str:=copy(ety,2,length(ety));    // poprawiamy nazwe parametru

                  _doo:=l_lab(str);

                  test:=false;
                  for x:=pub_idx-1 downto 0 do
                   if t_pub[x].nam=str then begin test:=true; Break end;

                  if (_doo>=0) and not(test) then  // dopisujemy do T_PUB jesli nie zostala wczesniej upubliczniona
                   if (t_lab[_doo].bnk<>__id_ext) {and not(test)} then save_pub(str,zm);

                  end;

                  if _doo<0 then blad_und(zm,str,5);

                 end;

               end;


          // okreslamy typ etykiety PUBLIC, czy jest relokowalna

             branch:=false;       // umo¿liwiamy relokowalnosc

             old_rel_idx      := rel_idx;
             old_siz_idx      := siz_idx;
             old_sizm0        := t_siz[siz_idx];
             old_sizm1        := t_siz[siz_idx-1];

             for _odd:=pub_idx-1 downto 0 do begin
              txt:=t_pub[_odd].nam;

              reloc:=false;

              oblicz_wartosc(txt,zm);
              t_pub[_odd].typ := reloc;
             end;

             branch:=true;        // blokujemy relokowalnosc

             rel_idx          := old_rel_idx;
             siz_idx          := old_siz_idx;
             t_siz[siz_idx]   := old_sizm0;
             t_siz[siz_idx-1] := old_sizm1;
                 
{
   Writeln(pub_idx);
   for x:=0 to pub_idx-1 do Writeln(t_pub[x].nam,',',t_pub[x].typ);
}


          // A(HEADER = $FFED) , a(LENGTH)
             save_dstW( __hea_public );
             save_dstW( pub_idx );

             for idx:=0 to pub_idx-1 do begin

              txt:=t_pub[idx].nam;

              ety:=txt;
              save_lst(ety,'a');

              v := get_pubType(txt,zm, _odd);  // V to typ, _ODD to indeks do T_LAB

              if v = byte( __id_proc ) then
               ch := 'P'                     // procedure     .char "P"
              else
               if t_pub[idx].typ then
                ch := 'V'                    // variable      .char "V"
               else
                ch := 'C';                   // constant      .char "C"

              tp:='W';

              if ch='C' then begin           // type B-YTE, W-ORD, L-ONG, D-WORD
               war:=t_lab[_odd].adr;

               case abs(war) of
                         0..$FF: tp:='B';
                    $100..$FFFF: tp:='W';
                $10000..$FFFFFF: tp:='L';
               else
                tp:='D'
               end;

               save_dst(ord(tp));     // type

              end else
               save_dst( byte('W') ); // type W-ORD dla V-ARIABLE i P-ROCEDURE


              save_dst(ord(ch));             // label_type V-ARIABLE, C-ONSTANT, P-ROCEDURE

              save_dstS(txt);                // label_name     [length + atascii]

              if v = byte( __id_proc ) then
               k:=t_prc[t_lab[_odd].adr].adr    // PROC address
              else
               k:=t_lab[_odd].adr;              // variable address

              if ch<>'C' then dec(k,rel_ofs);   // watosci CONSTANT nie modyfikujemy


              for sv:=1 to TypeToByte(tp) do begin
                                                // wartosc zmiennej, stalej lub procedury
               save_dst( byte(k) );             // o rozmiarze TP (B-YTE, W-ORD, L-ONG, D-WORD)
               k := k shr 8;
              end;


              if v = byte( __id_proc ) then begin
               k:=t_prc[t_lab[_odd].adr].reg;
               save_dst( byte(k) );             // kolejnosc rejestrow

               ch:=t_prc[t_lab[_odd].adr].typ;
               save_dst( ord(ch) );             // typ procedury ' '__pDef, 'R'__pReg, 'V'__pVar


               k:=t_prc[t_lab[_odd].adr].par;   // liczba parametrow

               indeks:=t_prc[t_lab[_odd].adr].str;


               if (k>0) and (ch=__pVar) then    // jesli __pVar to wliczamy tez dlugosc
                for j:=0 to k-1 do begin        // nazw pametrow
                 tmp:=t_mac[j+indeks];
                 inc(k,length(tmp)+2-1);
                end;

               save_dstW( k );                  // liczba danych na temat parametrow


               k:=t_prc[t_lab[_odd].adr].par;   // liczba parametrow jeszcze raz


               if k>0 then                      // jesli sa parametry to je zapiszemy
                for j:=0 to k-1 do begin
                 tmp:=t_mac[j+indeks];
                 save_dst(ord(tmp[1]));

                 if ch=__pVar then begin        // dodatkowo dlugosc i nazwe etykiety jesli to __pVar
                  txt:=copy(tmp,2,length(tmp)); // omijamy pierwszy znak typu

                  save_dstS( txt );
                 end;

                end;

              end;

              zapisz_lst(ety);
//              save_lst(txt,'a');
             end;

             bez_lst:=true;
//             pub_idx:=0;
 end;             
end;


procedure operator_zlozony(var i:integer; var zm,ety:string);
var txt: string;
begin

 if ety[1]<>'?' then blad(zm,58); // te operacje dotycza etykiet tymczasowych

 wymus_zapis_lst(zm);

 txt:=ety+zm[i];

 if zm[i+1]='=' then begin
   insert(txt,zm,i+2);      // modyfikujemy linie  ?tmp+=3 -> ?tmp=?tmp+3
   delete(zm,i,1)
 end else begin
   zm:=ety+'='+txt+'1';     // modyfikujemy linie  ?tmp++ -> ?tmp=?tmp+1
   i:=length(ety)+1         // modyfikujemy linie  ?tmp-- -> ?tmp=?tmp-1
 end;

end;


procedure get_data_array(var i:integer; var zm:string; const max:integer; const typ:byte);
var ety, str: string;
    k, j: integer;
    _odd: integer;
begin

 save_lst(zm,' ');

 ety:=get_dat_noSPC(i,zm,'=',#0,zm);
 if ety='' then ety:='[0]';

 if zm[i]<>'=' then blad(zm,58) else __inc(i,zm);
 str:=get_dat_noSPC(i,zm,'\',#0,zm);

 k:=1;

 while true do begin
  _odd:=integer( oblicz_wartosc_ogr(ety,zm,k) ); //  ___wartosc_noSPC(txt,zm,k,#0,'F');

  subrange_bounds(zm,_odd,max);

  array_used.idx:=_odd;
  array_used.typ:=tType[ typ ];

  if not(loop_used) and not(FOX_ripit) then t:=t+' ['+hex(cardinal(_odd),4)+']';
  
  j:=1; oblicz_dane(j,str,zm,typ);

  omin_spacje(k,ety);
  if ety[k]<>':' then Break else __inc(k,ety);

 end;

 if k<=length(ety) then blad_ill(zm,ety[k]);

end;


procedure add_proc_nr;
(*----------------------------------------------------------------------------*)
(*  zwiekszamy licznik PROC_NR                                                *)
(*----------------------------------------------------------------------------*)
begin
 inc(proc_nr);
 if proc_nr>High(t_prc) then SetLength(t_prc,proc_nr+1);
end;


procedure upd_procedure(var ety,zm:string; const a:integer);
(*----------------------------------------------------------------------------*)
(*  uaktualniamy wartosc BANK, ADRES i parametry procedury typu ' '           *)
(*----------------------------------------------------------------------------*)
var str, txt, b, tmp, add: string;
    _doo, _odd, idx, i, len: integer;
    tst: cardinal;
    old_bool: Boolean;
begin

   t_prc[proc_nr].bnk:=bank;
   t_prc[proc_nr].adr:=a;

   t_prc[proc_nr].ofs:=org_ofset;

   str:=lokal_name+ety;
   zapisz_etykiete(str,a,bank,ety[1]);

   old_bool   := dreloc.use;   // aby parametry procedury nie byly relokowalne
   dreloc.use := false;

   _doo:=t_prc[proc_nr].par;    // liczba zadeklarowanych parametrow w aktualnej procedurze

   if _doo>0 then
    case t_prc[proc_nr].typ of

   __pDef: begin

          // jesli procedura miala zadeklarowane parametry to
          // odczytamy adres dla parametrow zawarty w @PROC_VARS_ADR
          // i zaktualizujemy adresy parametrow procedury

            tst:=adr_label(2,true);   // @proc_vars_adr

            proc:=true;                  // PROC=TRUE i PROC_NAME
            proc_name:=ety+'.';          // umozliwia uaktualnienie adresow etykiet

          // wymus wykonanie makr @PULL 'I'

//             wymus_zapis_lst(zm);

             zm:=' @PULL ''I'','+IntToStr(t_prc[proc_nr].ile);

             idx:=t_prc[proc_nr].str;

             for _odd:=0 to _doo-1 do begin   // !!! koniecznie taka kolejnosc petli FOR !!!
              txt:=t_mac[idx+_odd];
              str:=copy(txt,2,length(txt));

          // uaktualnimy adresy etykiet parametrow procedury
              save_lab(str , tst , __id_param , zm);

              inc( tst , TypeToByte(txt[1]) );
             end;

           end;

   __pVar: begin

             idx:=t_prc[proc_nr].str;

             for _odd:=_doo-1 downto 0 do begin
              txt:=t_mac[idx+_odd];


            // wczytamy nazwe parametru, usuwamy pierwszy znak okreslajacy typ
            // oraz znaki ktore nie naleza do nazwy etykiety

              str:='';
              add:='';
              i:=2;
              len:=length(txt);

              while i<=len do begin
               if _lab(txt[i]) then str:=str+txt[i] else Break;
               inc(i);
              end;

              while i<=len do begin
               add:=add+txt[i];
               inc(i);
              end;
 
              b:=lokal_name+ety+'.';

              tmp:=b+str;
              i:=l_lab(tmp);

            // szukamy najblizszej sciezki dla parametru 

              while (i<0) and (pos('.',b)>0) do begin
               obetnij_kropke(b);

               tmp:=b+str;
               i:=l_lab(tmp);
              end;

              t_mac[idx+_odd] := txt[1]+tmp+add;
             end;

           end;
           
    end;


 dreloc.use := old_bool;

 save_lst(zm,' ');

end;


function ByteToReg(var a: byte): char;
begin

 case (a and $c0) of
  $40: Result := 'X';
  $80: Result := 'Y';
 else
  Result := 'A';
 end;

 a:=byte( a shl 2 );
end;


function RegToByte(const a: char): byte;
begin

 case a of
  'X': Result := $55;
  'Y': Result := $aa;
 else
  Result := $00;
 end;

end;


procedure get_procedure(var ety,nam,zm: string; var i:integer);
(*----------------------------------------------------------------------------*)
(*  odczytujemy i zapamietujemy typy i nazwy parametrow w deklaracji .PROC    *)
(*  w zaleznosci od sposobu przekazywania parametrow zwiekszana jest liczba   *)
(*  przebiegow asemblacji PASS_END                                            *)
(*----------------------------------------------------------------------------*)
type _typBool = array [0..2] of Boolean;

var len, k, l, nr_param, j: integer;
    txt, str: string;
    ch, ptype: char;
    v: byte;
    old_bool: Boolean;
    
    treg: _typBool;
    all : _typStrREG;

begin
           reserved_word(ety,zm);               // sprawdz czy nazwa .PROC jest dozwolona

           save_lab(ety,proc_nr,__id_proc,zm);  // aktualny indeks do T_PRC = PROC_NR

           old_bool   := dreloc.use;            // koniecznie aby parametry procedury
           dreloc.use := false;                 // nie byly relokowalne

           t_prc[proc_nr].nam := nam;           // wlasciwa nazwa procedury
           t_prc[proc_nr].bnk := bank;          // zapisanie banku procedury
           t_prc[proc_nr].adr := adres;         // zapisanie adresu procedury

           t_prc[proc_nr].typ := __pDef;        // domyslny typ procedury 'D'

           t_prc[proc_nr].str := High(t_mac);   // indeks do T_MAC, beda tam parametry procedury


           omin_spacje(i,zm);

           k:=0;  nr_param:=0;


           str:=zm[i];
           if not(test_char(i,zm,'(',#0)) then blad_und(zm,str,8);

          // odczytujemy deklaracje parametrow ograniczonych nawiasami ( )
           if zm[i] = '(' then begin

            all:='';                 // tutaj zapiszemy kombinacje rejestrow CPU
            fillchar(treg,sizeof(treg),false);

            proc:=true;
            proc_name:=ety+'.';

          // sprawdzamy poprawnosc nawiasow, usuwamy poczatkowy i koncowy nawias

            txt:=ciag_ograniczony(i,zm,true);

            omin_spacje(i,zm);

            ptype := __pDef;          // domyslny typ procedury __pDef

         // sprawdzamy czy jest okreslony typ procedury .REG
            if zm[i]='.' then begin
             str_blad:=get_datUp(i,zm,#0,false);

             v := fCRC16(str_blad);

             if not(v in [__reg, __var]) then blad(zm,68);

             ptype := str_blad[2];
             t_prc[proc_nr].typ := ptype;
            end;

            if ptype=__pVar then
             if pass_end<3 then pass_end:=3;     // jesli sa parametry .VAR to musza byc conajmniej 3 przebiegi

          // sprawdzamy obecnosc deklaracji dla programowego stosu MADS'a
                             
            if ptype=__pDef then begin
             adr_label(0,true);   // @stack_pointer, test obecnosci deklaracji etykiety
             adr_label(1,true);   // @stack_address, test obecnosci deklaracji etykiety
             adr_label(2,true);   // @proc_vars_adr, test obecnosci deklaracji etykiety
            end;


            j:=1;
            ch:=' ';                  // jesli ch=' ' to odczytuj typ parametru

            len:=length(txt);

            while j<=len do begin

             if ch=' ' then begin
              v:=get_type(j,txt,true);
              ch:=relType[v];         // typ parametru 'B', 'W', 'L', 'D' z relType
             end;


           // odczytujemy nazwe parametru, parametry mo¿emy rozdzielac znakiem przecinka
           // spacja sluzy do okreslenia nowego typu parametru

//             str:=get_lab(j,txt, true);

             omin_spacje(j,txt);
             str:=get_dat(j,txt,',',true);
             if str='' then blad(zm,15);


           // jesli .REG to nazwy parametrow sa 1-literowe A,X,Y lub 2-literowe AX, AY itp.
           // nazwy parametrow moga powtorzyc sie tylko raz
           // dla .REG dopuszczalne sa tylko parametry typu .BYTE, .WORD, .LONG
             if ptype=__pReg then begin

              l:=length(str);

              case ch of
               'B': if l<>1 then blad_und(zm,str,41);
               'W': if l<>2 then blad_und(zm,str,41);
               'L': if l<>3 then blad_und(zm,str,41);
              else
               blad_und(zm,str,41)
              end;
              

              for l:=1 to length(str) do
               case str[l] of
                'A': if treg[0] then blad(zm,11) else treg[0] := true;
                'X': if treg[1] then blad(zm,11) else treg[1] := true;
                'Y': if treg[2] then blad(zm,11) else treg[2] := true;
               else
                begin str_blad:=str[l]; blad(zm,61) end
               end;

             end;

             omin_spacje(j,txt);

           // wstepnie zapamietujemy etykiety parametrow jako wartosc NR_PARAM dla __pDef

             case ptype of
              __pDef: save_lab(str , nr_param , __id_param , zm);
              __pReg: all:=all+str;
//              __pVar: str:=proc_name+lokal_name+str;   // potem poszukamy "sciezki" do nazwy parametru
             end;

             str:=ch+str;  save_mac(str);

             inc(k);              // zwiekszamy licznik odczytanych parametrow procedury

             inc( nr_param , TypeToByte(ch) );   // zwiekszamy NR_PARAM o dlugosc danych

             if txt[j]<>',' then ch:=' ' else inc(j);

            end;    // while

           end;     // if zm[i] = '('


           if t_prc[proc_nr].typ = __pReg then begin
          // maksymalnie 3 bajty mozna przekazac za pomoca rejestrow
            if nr_param>3 then blad(zm,11);

          // zapisujemy kolejnosc rejestrow
            t_prc[proc_nr].reg := (RegToByte(all[1]) and $c0) or (RegToByte(all[2]) and $30) or (RegToByte(all[3]) and $0c);
           end;

           t_prc[proc_nr].par := k;
           t_prc[proc_nr].ile := nr_param;

           dreloc.use := old_bool;
end;


procedure test_wyjscia(var zm:string; const wyjscie:Boolean);
(*----------------------------------------------------------------------------*)
(*  testowanie zakonczenia asemblacji pliku                                   *)
(*----------------------------------------------------------------------------*)
begin
 if not(wyjscie) then begin

  if not(run_macro) and not(icl_used) then
   if ifelse<>0 then blad(zm,1) else
    if proc or macro then blad(zm,17) else  // !!! koniecznie !!! ... or macro
     if struct then blad(zm,56) else
      if aray then blad(zm,60) else
       if rept then blad(zm,43) else
        if lokal_nr>0 then blad(zm,29) else
         if pag_idx>0 then blad(zm,65) else
          if whi_idx>0 then blad(zm,89) else
           if test_idx>0 then blad(zm,96);
           
//  if run_macro then blad(zm,17);

 end;
end;


function fgetB(var i:integer): byte;
begin
 Result := t_lnk[i];
 inc(i);
end;

function fgetW(var i:integer): integer;
begin
 Result := t_lnk[i] + t_lnk[i+1] shl 8;
 inc(i,2);
end;

function fgetL(var i:integer): cardinal;
begin
 Result := t_lnk[i] + t_lnk[i+1] shl 8 + t_lnk[i+2] shl 16;
 inc(i,3);
end;    

function fgetD(var i:integer): cardinal;
begin
 Result := t_lnk[i] + t_lnk[i+1] shl 8 + t_lnk[i+2] shl 16 + t_lnk[i+3] shl 24;
 inc(i,4);
end;

function fgetS(var i:integer): string;
var x, y: integer;
begin
 Result:='';

 x:=fgetW(i);

 for y:=x-1 downto 0 do Result:=Result+chr( fgetB(i) );
end;


procedure flush_link(var zm: string);
var j, k: integer;
begin
 k:=dlink.len;

 save_lst(zm,'a');

 if k>0 then
  for j:=0 to k-1 do save_dst(t_ins[j]);

 inc(adres,k);

 if dlink.emp>0 then begin
  save_hea;  org:=true;
  inc(adres,dlink.emp);
  dlink.emp:=0;
 end;
 
end;


procedure get_address(var i:integer; var zm:string);
// nowy adres asemblacji dla .PROC lub .LOCAL
var txt: string;
begin
      t_end[end_idx].old:=adres;

      // sprawdzamy czy jest nowy adres asemblacji dla .PROC lub .LOCAL

      omin_spacje(i,zm);

      if zm[i]=',' then begin
        __inc(i,zm);
        txt:=get_dat(i,zm,'(',true);

        blokuj_zapis:=true;  // wymuszamy zapis ORG-a jesli wystapil wczesniej
        save_dst(0);
        blokuj_zapis:=false;

        org_ofset := adres;

        adres := integer( oblicz_wartosc(txt,zm) );

        org_ofset := adres - org_ofset;

        omin_spacje(i,zm);
      end;
end;


procedure get_address_update;
begin

 dec(adres, t_end[end_idx-1].adr);
 inc(adres, t_end[end_idx-1].old);

 dec(end_idx);
end;


procedure save_extLabel(k:integer; var ety,zm:string; v:byte);
var txt: string;
begin

  omin_spacje(k,zm);

      if v=__proc then begin                  // etykieta external deklaruje procedure

       if pass=0 then begin
        txt:='##'+ety;                        // zapisujemy etykiete ze znakami ##
        get_procedure(txt,ety,zm,k);          // odczytujemy parametry

        proc:=false;                          // koniecznie wylaczamy PROC
        proc_name:='';                        // i koniecznie PROC_NAME := ''
       end;

       add_proc_nr;                           // zwiekszamy numer koniecznie

       save_lab(ety,extn_idx,__id_ext,zm);
       save_extn(ety,2,true);                 // typu .WORD
      end else begin

       //v:=byte( v-__byteValue );              // normalna etykieta external
       dec(v, __byteValue);

       save_lab(ety, extn_idx, __id_ext, zm);
       save_extn(ety, v, false);     
      end;

end;


procedure get_maeData(var zm:string; var i:integer; const typ:char);
var par: _strArray;
    _odd, _doo, idx, j, tmp: integer;
    txt, hlp: string;
    v, war: byte;
begin

   save_lst(zm,'a');

   get_parameters(i,zm,par,true);

   _doo:=High(par);

   if _doo>0 then begin

    _odd:=0;
    war:=0;

    if (typ in ['B','S']) and (_doo>1) then begin

     txt:=par[0];     // mozliwa wartosc, ktora bedziemy dodawac do reszty ciagu
                      // pod warunkiem ze ciag liczy wiecej niz 1 element
     
     if txt[1] in ['+','-'] then begin
      j:=1; war:=byte( ___wartosc_noSPC(txt,zm,j,#0,'B') );
      inc(_odd);
     end;

    end;


    for idx:=_odd to _doo-1 do begin               // wlasciwe dekodowanie ciagu
     txt:=par[idx];

     if txt[1] in ['''','"'] then begin

      j:=1; hlp:=get_string(j,txt,zm,true);

      omin_spacje(j,txt);

      if length(txt)>=j then
       if not(txt[j] in ['*','+','-']) then blad_ill(zm,txt[j]);

      v:=war;
       
      inc(v, test_string(j,txt,'F'));

      if typ='S' then
       save_dta(0,hlp,'D', v)
      else
       save_dta(0,hlp,'C', v);

     end else

      case typ of
       'B', 'H', 'S':
            begin
             if typ='H' then txt:='$'+txt;

             j:=1;  v := byte( ___wartosc_noSPC(txt,zm,j,#0,'B') );

             if typ='S' then v:=ata2int(v);

             inc(v, war); //v:=v + war;

             save_dst(v);
             inc(adres);
            end;

       'W': begin
             j:=1;  tmp := integer( ___wartosc_noSPC(txt,zm,j,#0,'A') );
             save_dstW( tmp );
             inc(adres,2);
            end;

      end;

    end;

   end;

end;


function asm_test(var lar,rar,old, jump:string; const typ,op:byte): int5;
(*----------------------------------------------------------------------------*)
(* generujemy kod testujacy warunek dla .WHILE, .TEST                         *)
(* dopuszczalne sa dwa typy danych .BYTE i .WORD, specjalnym wyj¹tkiem jest   *)
(* porównanie z wartoscia absolutna #0, wtedy generujemy inny-krótszy kod     *)
(*----------------------------------------------------------------------------*)
var hlp: int5;
    txt, ety: string;
    tst: cardinal;
    adr, idx: integer;
    nulTest: Boolean;
    reloc_value: relVal;
begin

 adr := adres;

 str_blad:=old;

 Result.l:=0;    reloc_value.use:=false; reloc_value.cnt:=0;


 if lar[1]='#' then blad(old,58);       // argument nierealny :)


(*----------------------------------------------------------------------------*)
(*  0 <>      4 =           xor 4                                             *)
(*  1 >=      5 <                                                             *)
(*  2 <=      6 >                                                             *)
(*----------------------------------------------------------------------------*)

 case typ of
  1: begin                                       // .BYTE
      if lar<>'@' then begin

       txt:='LDA '+lar;
       hlp:=asm_mnemo(txt,old);
       addResult(hlp,Result);

      end;

      if op in [2,6] then begin
       hlp.l:=1; hlp.h[0]:=$18;    // CLC
       inc(adres);
       addResult(hlp,Result);

       txt:='SBC '+rar;
       hlp:=asm_mnemo(txt,old);
       addResult(hlp,Result);

       if op=6 then
        txt:='JCS '    // >
       else
        txt:='JCC ';   // <=

      end else begin
       txt:='CMP '+rar;
       hlp:=asm_mnemo(txt,old);

       if hlp.h[0]=$c9 then          // CMP #
        if hlp.h[1]=0 then begin     // optymalizacja dla porównañ z 0
         dec(adres, hlp.l);          // cofamy adres
         hlp.l:=0;
        end;

       addResult(hlp,Result);


       case op of
        0: txt:='JNE ';     // <>
        1: txt:='JCS ';     // >=
        4: txt:='JEQ ';     // =
        5: txt:='JCC ';     // <
       end;

      end;

//      txt:=txt+IntToStr(ad);
//      i:=1; hlp:=oblicz_mnemonik(i,txt,old);
//      addResult(hlp,Result);

     end;

  2: begin                                       // .WORD

      nulTest := false;

      if rar[1]='#' then begin      // jesli bedzie #0 to generujemy krótszy kod
       branch:=true;    // nie relokujemy, testujemy tylko wartosc
       rar[1]:='+';
       idx:=integer( oblicz_wartosc(rar,old) );

       nulTest := (idx = 0);
       rar[1]:='#';
      end;

      txt:='LDA '+lar;
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);


  if nulTest and (op in [0,4]) then begin     // wyj¹tek dla operacji <>#0 , =#0

      txt:='ORA '+lar+'+1';
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);

  end else begin

      hlp.l:=1;

      if op in [2,6] then
       hlp.h[0]:=$18       // CLC
      else
       hlp.h[0]:=$38;      // SEC

      inc(adres);
      addResult(hlp,Result);

      if rar[1]='#' then rar[1]:='<';
      txt:='SBC '+rar;
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);

   ety:='##O'+IntToStr(ora_nr);     // dla #ORA


   idx:=load_lab(ety,false);        // odczytujemy wartosc etykiety

   if idx>=0 then
    tst:=t_lab[idx].adr
   else
    tst:=0;

   save_relAddress(idx, reloc_value);


      txt:='STA '+IntToStr(tst);
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);

{      if lar[1]='<' then
       lar[1]:='>'
      else
       lar:=lar+'+1';      }

      txt:='LDA '+lar+'+1';
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);

      if rar[1]='<' then
       rar[1]:='>'
      else
       rar:=rar+'+1';

      txt:='SBC '+rar;
      hlp:=asm_mnemo(txt,old);
      addResult(hlp,Result);

   tst:=adres + 1;     // wartosc adresu do modyfikacji


   save_fake_label(ety,old,tst);

   inc(ora_nr);


      hlp.l:=2; hlp.h[0]:=$09; hlp.h[1]:=$00;    // ORA #$00
      inc(adres,2);
      addResult(hlp,Result);


  end;
  

      case op of
       0: txt:='JNE ';       // <>
       1: txt:='JCS ';       // >=
       2: txt:='JCC ';       // <=
       4: txt:='JEQ ';       // =
       5: txt:='JCC ';       // <
       6: txt:='JCS ';       // >
      end;

     end;

 end;

 txt:=txt+ jump;
 hlp:=asm_mnemo(txt,old);
 addResult(hlp,Result);

 adres := adr;  // przywracamy poczatkowa wartosc ADRES
end;


procedure create_long_test(const _v, _r:byte; var long_test, _lft, _rgt:string);
var txt, tmp: string;
begin

   case _v xor 4 of
    0: txt:='<>';
    1: txt:='>=';
    2: txt:='<=';
    4: txt:='=';
    5: txt:='<';
    6: txt:='>';
   end;

   if long_test<>'' then long_test:=long_test+'\';

   long_test:=long_test+'.TEST ';

   if _r=1 then
    tmp:='.BYTE '
   else
    tmp:='.WORD ';

   long_test:=long_test+tmp+_lft+txt+_rgt+'\ LDA:SNE#1\.ENDT\ LDA#0';

   long_test:=long_test+'\ IFT ?I>0&&.GET[?I-1]=41\ AND EX+?J-2+1\ STA EX+?J-2+1\ ?I--\ ELS\ STA EX+?J+1\ ?J+=2\ EIF\';

end;


procedure wyrazenie_warunkowe(var i:integer; var long_test, zm,left,right:string; var v,r:byte);
(*----------------------------------------------------------------------------*)
(* generowanie kodu dla warunku .WHILE, .TEST (mo¿liwe dwa typy .BYTE, .WORD) *)
(*----------------------------------------------------------------------------*)
var str, txt, _lft, _rgt, oper: string;
    k, j : integer;
    _v, _r: byte;
begin

   r:=get_type(i,zm,true);

   if r>2 then blad(zm,46);           // tylko .BYTE i .WORD s¹ akceptowane

   omin_spacje(i,zm);

   //str:=get_dat_noSPC(i,zm,#0,#0,zm);
   str:=get_dat(i,zm,#0, false);

   k:=1;

   right:='';
   left:='';        // czytamy do LEFT dopóki nie napotkamy operatorów '=', '<', '>'

   if str<>'' then
    while not(_ope(str[k])) and not(test_char(k,str,#0,#0)) do begin

       if str[k] in ['[','(','{'] then
         left:=left + ciag_ograniczony(k,str,false)
       else begin
        if str[k]<>' ' then left:=left + str[k];
        inc(k);
       end;

   end;


   omin_spacje(k,str);


   v:=$ff;

   if left<>'' then begin

(*----------------------------------------------------------------------------*)
(*  0 <>      4 =           xor 4                                             *)
(*  1 >=      5 <                                                             *)
(*  2 <=      6 >                                                             *)
(*----------------------------------------------------------------------------*)

   case str[k] of                   // szukamy znanej kombinacji operatorów

     #0: v:=$80;                    // koniec ci¹gu

     '=': v:=4;                     // =

     '<': case str[k+1] of
            '>': v:=0;              // <>
            '=': v:=2;              // <=
          else
            v:=5;                   // <
          end;

     '>': if str[k+1]='=' then
            v:=1                    // >=
           else
            v:=6;                   // >

   end;



     if v<$80 then begin

       if v<4 then inc(k,2) else inc(k);

       v:=v xor 4;

       omin_spacje(k,str);

       right:=get_dat(k,str,#0,true);      //get_dat_noSPC(k,str,#0,#0,zm);

     end else
        if v=$80 then begin      // dla pustego ciagu domyslna operacja '<>0'
           v:=4;
           right:='#0';
        end;

   end;


 // V = $FF oznacza brak operatora

   if (left='') or (right='') or (v=$ff) then begin
      blad(zm,58); koniec(2);
   end;


 // jesli wystêpuj¹ operatory .OR, .AND to generujemy specjalny kod

  omin_spacje(k,str);

  if not(test_char(k,str,#0,#0)) then begin

   if long_test='' then long_test:=long_test+'.LOCAL\ ?I=0\ ?J=0';

   oper:=get_dat(k,str,#0,true);

   omin_spacje(k,str);
   txt:=get_dat(k,str,#0,false);

   j:=1; wyrazenie_warunkowe(j, long_test, txt,_lft,_rgt, _v, _r);

   create_long_test(_v, _r, long_test, _lft, _rgt);

   
   if oper='.OR' then
    txt:='9'
   else
    if oper='.AND' then
     txt:='41'
    else
     blad(zm,58);

     
   long_test:=long_test+'.PUT[?I]='+txt+'\ ?I++';

  end;


end;


function BCD(const l,r:char): byte;
begin
 Result:=byte( (ord(l)-ord('0')) shl 4 + (ord(r)-ord('0')) );
end;


procedure save_fl(var a,old:string);
(*----------------------------------------------------------------------------*)
(*  zapisujemy liczbe real w formacie FP Atari                                *)
(*----------------------------------------------------------------------------*)
var i, c, e: integer;
    fl, tmp: string;
    x: real;
    v: byte;
begin

 val(a, x,i);
 if i>0 then blad_ill(old,a[i]);

 str(x, fl);

 tmp:=copy(fl,pos('E',fl)+1,length(fl));  // odczytujemy wartosc E
 e:=integer( StrToInt(tmp) );

 c:=pos('.',fl);       // pozycja znaku '.'

 if e and 1<>0 then    // jesli E jest nieparzyste to modyfikujemy
  while c<>4 do begin

   if c<4 then begin
    fl[c]:=fl[c+1];    // przesuwamy w prawo
    fl[c+1]:='.';
    dec(e);
    inc(c);
   end else begin
    fl[c]:=fl[c-1];    // przesuwamy w lewo
    fl[c-1]:='.';
    inc(e);
    dec(c);
   end;

  end;

 e:=e div 2;

 if (c>4) or (abs(e)>64) then blad(old,0);   // przekroczony zakres FP Atari

 v:=byte(64+e);
 if fl[1]='-' then v:=v or $80;

 save_dst(v);

 if c=4 then               // dwie cyfry
  v:=BCD(fl[2],fl[3])
 else                      // jedna cyfra
  v:=BCD('0',fl[2]);

 save_dst(v);

 i:=c+1;

 v:=BCD(fl[i], fl[i+1]); inc(i,2);  save_dst(v);
 v:=BCD(fl[i], fl[i+1]); inc(i,2);  save_dst(v);
 v:=BCD(fl[i], fl[i+1]); inc(i,2);  save_dst(v);
 v:=BCD(fl[i], fl[i+1]);            save_dst(v);

 inc(adres,6);             // zapisalismy 6 bajtow

end;


function getMemType(var i: integer; var zm: string): byte;
begin

 omin_spacje(i,zm);

 Result := 0;
               case UpCase(zm[i]) of
                'M': Result:=0;         // M[ain]
                'E': Result:=2;         // E[xtended]
               else
                blad(zm,23);
               end;

 memType := Result;
end;



function dyrektywa(var zm:string; const kod:byte): byte;
var i: integer;
    z: string;
begin
 Result:=0;

 if zm<>'' then begin

  i:=1;
  omin_spacje(i,zm);

  z:=get_lab(i,zm,false);

  omin_spacje(i,zm);

  if zm[i] = '.' then begin
    z:=get_datUp(i,zm,'[',false);    // uwaga na .GET [..] oraz .PUT [..]
    Result:=fCRC16(z);

    if (Result=__dend) and (end_idx>0) then begin
     if t_end[end_idx-1].kod = kod then Result:=kod;
    end;
    
  end;

 end;

end;


procedure dirMACRO(var zm:string);
(*----------------------------------------------------------------------------*)
(*  odczyt makra zdefiniowanego przez dyrektywy .MACRO, .ENDM [.MEND]         *)
(*  !!! wyjatkowo dyrektywa .END nie mo¿e koñczyc definicji makra !!!         *)
(*----------------------------------------------------------------------------*)
var v: byte;
begin
   save_lst(zm,' ');          // .MACRO

   v:=dyrektywa(zm, __endm);

   if (v=__macro) and macro then blad(zm,17);

   if v in [__endm{, __dend}] then begin
    macro := false;
    if if_test then save_mac(zm);
   end else begin
    if if_test then save_mac(zm);
   end;

   zapisz_lst(zm);
end;


procedure dirENDR(var zm,a,old_str:string; var rept_nr,rept_ile,nr:integer);
(*----------------------------------------------------------------------------*)
(*  .ENDR  -  wykonanie petli .REPT                                           *)
(*----------------------------------------------------------------------------*)
var txt: string;
    idx: integer;
begin

      if if_test then
       if not(rept) then blad(zm,51) else begin

         txt:=zm; wymus_zapis_lst(txt);

         rept     := false;
         rept_run := true;

         idx      := High(t_mac);

         if not(run_macro) then begin
          txt := 'REPT';
          put_lst(show_full_name(txt,false,true));
         end;

         analizuj_mem__(rept_nr,idx, zm,a,old_str, rept_ile, true);

         rept_run  := false;

         if not(run_macro) and not(rept) then put_lst(show_full_name(a,full_name,true));

         line     := nr;
         line_add := 0;

         SetLength(t_mac,rept_nr+1);

         dec_end(zm,__endr);

       end;

end;


procedure dirREPT(var zm,a,old_str: string; var rept_nr,rept_ile,nr:integer);
(*----------------------------------------------------------------------------*)
(*  analiza linii gdy wystapilo .REPT                                         *)
(*----------------------------------------------------------------------------*)
var v: byte;
begin
   save_lst(zm,' ');

   v:=dyrektywa(zm, __endr);

   if (v=__rept) and rept then blad(zm,43);

   if v=__endr then begin
    dirENDR(zm,a,old_str,rept_nr,rept_ile,nr);
   end else begin
    if if_test then save_mac(zm);
    zapisz_lst(zm);
   end;
end;


procedure get_vars(var i:integer; var zm:string; var par:_strArray);
var idx, _doo, _odd: integer;
    txt, str: string;
    v: byte;
    tst: cardinal;
begin
     get_parameters(i,zm,par,false);

     idx:=1;

     if zm[i]=':' then begin
      inc(i);
      txt:=get_dat(i,zm,',',true);
      idx:=integer( oblicz_wartosc(txt,zm) );
      testRange(zm, idx, 0);
     end;

     v:=get_type(i,zm,true);

     _doo:=High(par);

     for _odd:=0 to _doo-1 do begin
      txt:=par[_odd];

      if not(_lab_first(txt[1])) then blad_ill(zm,txt[1]);

      _doo:=pos('=',txt);
      if _doo>0 then begin
       str:=copy(txt,_doo+1,length(txt));
       txt:=copy(txt,1,_doo-1);
       tst:=cardinal( oblicz_wartosc(str,zm) );
      end else tst:=0;

      if txt='' then
        blad(zm,15)
      else
        save_var(txt , idx , v, tst);

     end;

end;


procedure opt_h_minus;
begin
 opt:=opt and $fffffffe;
end;


procedure analizuj_linie (var zm,a,old_str:string; var rept_nr,rept_ile,nr:integer; var end_file,wyjscie:Boolean);
var g: file;
    txtFile: textfile;
    v, r: byte;
    ch, rodzaj, typ: char;
    i, k, j, m, _odd, _doo, idx, idx_get, rpt, old_ifelse, old_rept, indeks: integer;
    old_run_macro, old_else_used, old_elseif_used: Boolean;
    old_loopused, old_icl_used, old_case: Boolean;
    ety, txt, str, tmp, old_macro_nr, long_test: string;
    war: Int64;
    tst, opt_tmp, vtmp: cardinal;

    reloc_value: relVal;

    mne: int5;
    par: _strArray;

    label jump;

const
    mads_param: array [1..4] of string [7] =
    ('.BYTE ', '.WORD ', '.LONG ', '.DWORD ');

begin
//  len:=length(zm);

  label_type:='V';

  overflow:=false;

  mne.l:=0; rpt:=0;

  i:=1;

  data_out:=false;

  reloc_value.use:=false; reloc_value.cnt:=0; rel_used:=false;

  m:=i;                     // zapamietujemy poczatkowa wartosc 'i'

  if zm='' then begin

   mne_used := false;       // nie zostal odczytany mnemonik (!!! koniecznie w tym miejscu !!!)

   save_lst(zm,';');
   put_lst(t);
   exit;
  end;


(*----------------------------------------------------------------------------*)
(*  odczytujemy etykiete z lewej strony, od pierwszego znaku w lnii           *)
(*  jesli jest zakonczona dwukropkiem to pomijamy dwukropek                   *)
(*----------------------------------------------------------------------------*)
  ety:=get_lab(i,zm, false);
  if (zm[i]=':') and (_eol(zm[i+1])) then inc(i);

  omin_spacje(i,zm);

(*----------------------------------------------------------------------------*)
(*  a moze jest jakas etykieta poprzedzona bialymi spacjami i zakonczona  ':' *)
(*----------------------------------------------------------------------------*)
  if ety='' then begin
   k:=i;
   txt:=get_lab(i,zm, false);

   if txt<>'' then
    if ((zm[i]=':') and (_eol(zm[i+1]))) or struct then begin
     ety:=txt;
     __inc(i,zm);
    end else i:=k;

  end;


(*----------------------------------------------------------------------------*)
(* etykiety moga byc rozkazami CPU lub pseudo rozkazami jesli labFirstCol=true*)
(* etykiet w stylu MAE to nie dotyczy, one sa rozpoznawane klasycznie         *)
(* nie dotyczy to takze etykiet deklarowanych w .STRUCT                       *)
(*----------------------------------------------------------------------------*)
  if (length(ety)=3) and not(struct) and (opt and 256=0) and labFirstCol then 
  if reserved(ety) then begin
     i:=m;
     ety:='';
   end;


(*----------------------------------------------------------------------------*)
(*  pierwszymi znakami moga byc tylko znaki poczatkujace nazwe etykiety,      *)
(*  znaki konca linii oraz '.', ':', '*', '+', '-', '='                       *)
(*----------------------------------------------------------------------------*)
  if not(aray) then
   if not(_first_char(zm[i])) and not(test_char(i,zm,#0,#0)) then blad(zm,12);


(*----------------------------------------------------------------------------*)
(*  sprawdzamy czy wystapila deklaracja lokalna etykiety                      *)
(*  znak '=' moze zastepowac EQU, nie musi byc poprzedzony "bialymi spacjami" *)
(*  znaki '+=' , '-=' zastepuja dodawanie i odejmowanie wartosci od etykiety  *)
(*  znaki '--' , '++' zastepuja zmniejszanie i zwiekszanie wartosci etykiety  *)
(*----------------------------------------------------------------------------*)
  if zm[i] in ['+','-'] then
   if zm[i+1] in ['+','-','='] then operator_zlozony(i,zm,ety) else blad(zm,4);


  if (zm[i]='=') and not(aray) then begin
   mne.l:=__equ; __inc(i,zm);                // wymuszamy wykonanie EQU
                    
   goto jump;
  end;


  if ifelse>0 then save_lst(zm,' ');

(*----------------------------------------------------------------------------*)
(*  znak okreslajacy liczbe powtorzen linii ':'                               *)
(*----------------------------------------------------------------------------*)
   if (zm[i]=':') then begin
    save_lst(zm,'a');

    inc(i);
    loop_used:=true;

    txt:=get_dat(i,zm,',',true);
    _doo:=integer( oblicz_wartosc(txt,zm) );
    testRange(zm, _doo, 0);


    old_rept := ___rept_ile;

    ___rept_ile:=0;

  // test obecnosci czegokolwiek
    k:=i;  txt:=get_datUp(i,zm,#0,true);  i:=k;

    if struct then begin

     rpt:=_doo;
     omin_spacje(i,zm);    

    end else begin

      if FOX_ripit then blad(zm,109);

      FOX_ripit := true;        // zwracamy wartosc licznika petli dla '#'

      save_lab(ety,adres,bank,zm);

      idx:=High(t_mac);

      txt:=get_dat(i,zm,'\',false);
      save_mac(txt);

      line_add:=line-1;

      _odd := idx+1;
      analizuj_mem__(idx,_odd, zm,a,old_str, _doo, false);

      loop_used     := false;

      line_add:=0;

      SetLength(t_mac,idx+1);

      mne.l:=__nill;
      ety:='';
    end;

    ___rept_ile := old_rept;

    FOX_ripit := false;
   end;


(*----------------------------------------------------------------------------*)
(*  sprawdzamy czy to dyrektywa, dyrektywy typu moga byc petlone, czyli:      *)
(*  .BYTE, .WORD, .LONG, .DWORD, .GET, .PUT, .HE, .BY, .WO, .SB, .FL          *)
(*  innych dyrektyw nie mozemy powtarzac                                      *)
(*----------------------------------------------------------------------------*)
   if zm[i]='.' then begin

    str_blad:='';
    while _lab(zm[i]) do begin str_blad:=str_blad+UpCase(zm[i]); inc(i) end;

//    str_blad:=get_datUp(i,zm,'[',false);    // uwaga na .GET [..] oraz .PUT [..]
    mne.l:=fCRC16(str_blad);

    if not(mne.l in [__macro..__over]) then
     blad(zm,68)
    else
     if loop_used then
      if not(mne.l in [__byte..__dword, __sav, __get, __put, __he, __by, __wo, __sb, __fl]) then blad(zm,36);

   end;


(*----------------------------------------------------------------------------*)
(*  zamiana IFT ELS EIF ELI na ich odpowiedniki .IF .ELSE .ENDIF .ELSEIF      *)
(*  zostala zrealizowane przez modyfikacje tablicy HASH                       *)
(*  podobnie dyrektywy .DB i .DW wskazuja na .BYTE i .WORD                    *)
(*  !!! koniecznie w tym miejscu a nie innym !!!                              *)
(*----------------------------------------------------------------------------*)
  if UpCase(zm[i]) in ['E','I'] then begin

     j:=i;
     txt:=get_datUp(i,zm,#0,false);
     v:=fASC(txt);

     if not(v in [__if,__else,__endif,__elseif]) then i:=j else mne.l:=v;
  end;


(*----------------------------------------------------------------------------*)
(*  zamiana dyrektywy .OR na pseudo rozkaz ORG                                *)
(*  przy okazji sprawdzamy czy wyst¹pila dyrektywa .NOWARN i obslugujemy ja   *)
(*----------------------------------------------------------------------------*)
  case mne.l of
       __or: mne.l:=__org;
   __nowarn: begin mne.l:=0; noWarning:=true end;
  end;


(*----------------------------------------------------------------------------*)
(*  test dla kompatybilnosci etykiet ?label z MAE                             *)
(*----------------------------------------------------------------------------*)
  if (opt and 256>0) and (ety<>'') then
   if mne.l in [0..$7f, __by, __wo, __he, __sb, __ds, __fl, __byte..__dword] then begin

    if ety[1]<>'?' then begin
     lokal_name:='';
     save_lab(ety,adres,bank,zm);
     lokal_name:=ety+'.';
     ety:='';
    end;

   end else begin
    lokal_name:='';

   end;


  if not(skip.hlt) then test_skipa;

(*----------------------------------------------------------------------------*)
(*  odczytaj mnemonik                                                         *)
(*----------------------------------------------------------------------------*)
  if (mne.l=0) and if_test then
   if i<length(zm) then mne:=oblicz_mnemonik(i,zm,zm);


(*----------------------------------------------------------------------------*)
(*  dodatkowy test dla etykiet w bloku .STRUCT                                *)
(*----------------------------------------------------------------------------*)
  if struct then
   if (ety<>'') and (mne.l=0) then begin

    idx:=l_lab(ety);

    if idx<0 then begin
     if pass=pass_end then blad(zm,58)
    end else
     if t_lab[idx].bnk=__id_struct then begin
       mne.l := __struct_run_noLabel;
       mne.i := t_lab[idx].adr;
     end else
      if pass=pass_end then blad(zm,58);

   end;


(*----------------------------------------------------------------------------*)
(*  .END                                                                      *)
(*  zastepuje inne dyrektywy .END?                                            *)
(*----------------------------------------------------------------------------*)
 if mne.l=__dend then
  if end_idx=0 then blad(zm,72) else mne.l:=t_end[end_idx-1].kod;


(*----------------------------------------------------------------------------*)
(*  specjalna forma definicji wartosci etykiety tymczasowej za pomoca znakow  *)
(*  '=' , '+=' , '-=' , '++' , '--'                                           *)
(*----------------------------------------------------------------------------*)
 if mne.l=__addEqu then begin
  ety:=get_lab(i,zm, true);

  omin_spacje(i,zm);

  if UpCase(zm[i])='E' then
   inc(i,2)
  else if zm[i] in ['+','-'] then operator_zlozony(i,zm,ety);

  __inc(i,zm);
 end;


(*----------------------------------------------------------------------------*)
(*  laczenie mnemonikow za pomoca znaku ':', w stylu XASM'a                   *)
(*----------------------------------------------------------------------------*)
  if mne.l=__xasm then begin

   save_lab(ety,adres,bank,zm);

   if (pass=pass_end) and skip.use then warning(98);    // Skipping only the first instruction

   save_lst(zm,'a');

   loop_used := true;

   old_case  := case_used;            // nie mozemy zamieniac na duze litery
   case_used := true;                 // zachowujemy ich oryginalna wielkosc (CASE_USED=TRUE)

   skip.hlt  := true;    


   k:=mne.i;
   ety:=get_dat(k,zm,'\',false);      // odczytujemy argumenty

   case_used := old_case;             // przywracamy stara wartosc CASE_USED

   line_add:=line-1;                  // numer linii aktualnie przetwarzanej
                                      // przyda sie jesli wystapi blad

   idx:=High(t_mac);                  // indeks do wolnego wpisu w T_MAC

   while true do begin                // petla bez konca ;)

    old_case  := case_used;           // tutaj takze musimy zachowac wielkosc liter
    case_used := true;                // dlatego wymuszamy CASE_USED=TRUE

    txt:=get_dat(i,zm,':',true);      // odczytujemy mnemonik rozdzielony znakiem ':'

    case_used := old_case;            // przywracamy stara wartosc CASE_USED

      str:=' '+txt+ety;               // preparujemy nowa linie do analizy
      t_mac[idx]:=str;                // zapisujemy ja w T_MAC[IDX]

      test_skipa;

      _odd := idx+1;
      analizuj_mem__(idx,_odd, zm,a,old_str, 1, false);

    if zm[i]=':' then inc(i) else Break;   // tutaj konczymy petle jesli brak ':'
   end;

   wymus_zapis_lst(zm);

   line_add:=0;              // koniecznie zerujemy LINE_ADD

   bez_lst   := true;

   loop_used := false;

   skip.hlt  := false;

   skip.xsm  := true;        // wystapilo laczenie mnemonikow przez ':'

   mne.l:=__nill;
   ety:='';
  end else
   if not(mne.l in [0,__nill]) then skip.xsm:=false;    // nie wystapilo laczenie mnemonikow przez ':'  (default)

jump:

(*----------------------------------------------------------------------------*)
(*  jesli mamy uruchomione makro to zapisz jego zawartosc do pliku LST        *)
(*  puste linie nie sa zapisywane, !!! w tej postaci dziala najlepiej !!!     *)
(*----------------------------------------------------------------------------*)
  if run_macro and if_test then
   if ety<>'' then data_out:=true;


(*----------------------------------------------------------------------------*)
(*  BLK (kody __blkSpa, __blkRel, __blkEmp)                                   *)
(*----------------------------------------------------------------------------*)
 if mne.l=__blk then
 if ety<>'' then blad(zm,38) else
 if loop_used then blad(zm,36) else begin

  empty:=false;

  txt:=get_datUp(i,zm,#0,true);

  case UpCase(txt[1]) of
  //BLK D[os] a
  'D': mne.l := __org;

  //BLK S[parta] a
  'S': mne.l := __blkSpa;

  //BLK R[eloc] M[ain]|E[xtended]
  'R': mne.l := __blkRel;

  //BLK E[mpty] a M[ain]|E[xtended]
  'E': begin mne.l := __blkEmp; empty:=true end;

  //BLK N[one] a
  'N': begin mne.l := __org;  opt_h_minus end;

  //BLK U[pdate] A[ddress]
  //BLK U[pdate] E[xternal]
  //BLK U[pdate] S[ymbols]
  //BLK U[pdate] N[ew] address text
  'U':
    if pass=pass_end then begin

     oddaj_var;

     oddaj_ds;

     txt:=get_datUp(i,zm,#0,true);

     save_lst(zm,'a');

     _doo:=0;    // liczba adresow do relokacji
     _odd:=0;    // liczba symboli do relokacji

     for idx:=0 to rel_idx-1 do
      if t_rel[idx].idx>=0 then inc(_odd) else
       if t_rel[idx].idx=-1 then inc(_doo);

     case UpCase(txt[1]) of

      'A': begin                       // A[ddress]
            if not(blkupd.adr) then
             if (_doo>0) or dreloc.use then blk_update_address(zm);
            blkupd.adr:=true;
           end;

      'E': begin                       // E[xternal]
            if not(blkupd.ext) then blk_update_external(zm);
            blkupd.ext:=true;
           end;

      'P': begin                       // P[ublic]
            if not(blkupd.pub) then blk_update_public(zm);
            blkupd.pub:=true;
           end;

      'S': begin                       // S[ymbol]
            if not(blkupd.sym) then
             if _odd>0 then blk_update_symbol(zm);
            blkupd.sym:=true;
           end;

      'N': begin                       // N[ew]
            test_symbols := true;
            blk_update_new(i,zm);
           end;

     else
      blad(zm,23);
     end;

    end;

  else
   blad(zm,0);
  end;

 end;


(*----------------------------------------------------------------------------*)
(*  .DS expression                                                            *)
(*  rezerwujemy "expression" bajtow bez ich inicjalizowania                   *)
(*----------------------------------------------------------------------------*)
 if mne.l=__ds then
 if macro_rept_if_test then begin

 // po zmianie adresu asemblacji bloku .PROC, .LOCAL nie ma mo¿liwosci u¿ywania dyrektywy .DS

   if (org_ofset>0) then blad(zm,71);

//-   save_lst(zm,'a');
   nul.i:=integer( adres );
   save_lst(zm,'l');

   branch:=true;
   save_lab(ety,adres,bank,zm);

   _doo:=integer( oblicz_wartosc_noSPC(zm,zm,i,#0,'A') );

   if dreloc.sdx or dreloc.use then begin
    empty:=true;
    inc(ds_empty, _doo);
   end else
    if raw.use then begin

     if not(hea) then
      for k:=0 to _doo-1 do put_dst($ff);

    end else begin
     save_hea;  org:=true;
    end;

   inc(adres, _doo);

   ety:='';
  end;


(*----------------------------------------------------------------------------*)
(*  NMB [adres]                                                               *)
(*  RMB [adres]                                                               *)
(*  LMB #expression [,adres]                                                  *)
(*----------------------------------------------------------------------------*)
 if macro_rept_if_test then begin

  ch:=' ';              // CH bedzie zawieral znak dyrektywy 'N'MB, 'R'MB, 'L'MB

  case mne.l of

   __nmb: begin
           inc(bank);   // zwiekszamy licznik bankow MADS'a

           ch:='N';
          end;

   __rmb: begin
           bank:=0;     // zerujemy licznik bankow MADS'a

           ch:='R';
          end;

   __lmb: begin         // ustawiamy licznik bankow MADS'a
           omin_spacje(i,zm);
//           if zm[i] in ['<','>'] then else                  // znaki '<', '>' sa akceptowane
           if zm[i]<>'#' then blad(zm,14) else __inc(i,zm); // pozostale znaki inne niz '#' to blad

           txt:=get_dat_noSPC(i,zm,' ',#0,zm);
           k:=1; j:=integer( ___wartosc_noSPC(txt,zm,k,',','B') );  // wartosc licznika bankow = 0..255

           bank:=word( j );

           ch:='L';
          end;

  end;

(*----------------------------------------------------------------------------*)
(*  wymuszamy wykonanie makra @BANK_ADD (gdy OPT B+) dla LMB, NMB, RMB        *)
(*----------------------------------------------------------------------------*)
 if ch<>' ' then begin

  if dreloc.use or dreloc.sdx then blad(zm,71);
  if first_org then blad(zm,10);

  save_lst(zm,'i');

  if opt and $80>0 then begin

   omin_spacje(i,zm);
   if zm[i]=',' then __inc(i,zm);

   str:=get_dat_noSPC(i,zm,' ',#0,zm);
   if str<>'' then str:=','+str;

   wymus_zapis_lst(zm);

   txt:='@BANK_ADD '''+ch+''''+str;
   i:=1; mne:=oblicz_mnemonik(i,txt,zm);
   zm:=txt;
  end;

 end;

 end;


(*----------------------------------------------------------------------------*)
(*  wykonaj .PROC gdy PASS>0                                                  *)
(*  wymus wykonanie makra @CALL jesli procedura miala parametry               *)
(*  jesli procedura zostaje wywolana z poziomu innej procedury zapamietaj     *)
(*  parametry procedury na stosie nie modyfikujac wskaznika stosu,            *)
(*  a po powrocie przywroc je takze nie modyfikujac wskaznika stosu           *)
(*----------------------------------------------------------------------------*)
  if mne.l=__proc_run then
   if macro_rept_if_test then begin

     save_lab(ety,adres,bank,zm);

     indeks:=mne.i;

     idx:=t_prc[indeks].par;          // liczba parametrow

    if idx>0 then begin
    
     wymus_zapis_lst(zm);

     ety:='';
     str:='';


   // jesli nastepuje wywolanie procedury typu T_PRC[].TYP=__pDef, ktora posiada parametry (IDX>0)
   // z ciala aktualnie przetwarzanej procedury PROC_NR-1
   // to odlozymy na stos parametry procedury aktualnej, a po powrocie przywrocimy je

     if proc and (t_prc[indeks].typ=__pDef) then begin
      _doo:=t_prc[proc_nr-1].ile;                     // liczba bajtow przypadajaca na parametry

      if _doo>0 then begin
       //str:=copy(proc_name,1,length(proc_name)-1);  // obcinamy ostatnia kropke w nazwie aktualnej procedury
       str:=proc_name;
       SetLength(str,length(proc_name)-1);

       ety:=' @PUSH ''I'','+IntToStr(_doo)+' \ ';
       str:=' \ @PULL ''J'','+IntToStr(_doo);
      end;

     end;


     rodzaj := t_prc[indeks].typ;  // rodzaj procedury, sposobu przekazywania parametrow

     get_parameters(i,zm,par,false);


     // sprawdzamy liczbe przekazanych parametrow, jesli ich liczba sie nie zgadza to
     // wystapi blad 'Improper number of actual parameters'
     // w przypadku procedur typu __pReg, __pVar moze byc mniej parametrow, ale nie wiecej

       _doo:=High(par);

       for _odd:=_doo-1 downto 0 do begin

        txt:=par[_odd];

        if txt='' then
         if rodzaj=__pDef then
          blad(zm,40)
         else
          txt:=';';                       // dla __pReg mozemy pomijac parametry

        if (txt[1]='"') and (length(txt)>2) then txt:=copy(txt,2,length(txt)-2);

        par[_odd]:=txt;
       end;


     // sprawdz typ parametrow i wymus wykonanie makra @CALL_INIT, @CALL, @CALL_END
     // parametrem @CALL_INIT jest liczba bajtow zajmowanych przez parametry procedury

       case rodzaj of
     __pDef: begin
              if _doo<>idx then blad(zm,40);
              ety:=ety+' @CALL '+#39+'I'+#39+','+IntToStr(t_prc[indeks].ile);
             end;

     __pReg, __pVar:
             begin
              if _doo>idx then
               blad(zm,40)
              else
               if (pass=pass_end) and (_doo<idx) then warning(40);

              ety:=ety+' ';
             end;
       end;


       idx:=t_prc[indeks].str;       // indeks do nazw parametrow w T_MAC


      if _doo>0 then
       for k:=0 to _doo-1 do
        if par[k][1]<>';' then begin

         txt:=par[k];

         case rodzaj of
          __pDef: ety:=ety+' \ @CALL ';
         end;

         ch:=' ';
         v:=byte(' ');

         if txt='@' then begin
//          ety:=ety+#39+'@'+#39+',';
          v:=byte('@');
          war:=0;
          ch:='Z';
         end else
          if txt[1]='#' then begin
//           ety:=ety+#39+'#'+#39+',';
           v:=byte('#');
           branch:=true;
           tmp:=copy(txt,2,length(txt));
           war:=oblicz_wartosc(tmp,zm);
           ch:=value_code(war,zm,true);
          end else begin
//            ety:=ety+#39+' '+#39+',';
//            branch:=true;
//            war:=oblicz_wartosc(txt,zm);
           end;

       // typ parametru w deklaracji procedury (B,W,L,D)
       // funkcja VALUE_CODE zwrocila typ parametru (Z,Q,T,D)
        str_blad:=copy(t_mac[idx+k],2,length(t_mac[idx+k]));

        if ch<>' ' then
          case t_mac[idx+k][1] of
           'B': if ch<>'Z' then blad(zm,41); //blad_und(zm,t_mac[idx+k],41);
           'W': if (ch in ['T','D']) or (txt='@') then blad(zm,41); //blad_und(zm,t_mac[idx+k],41);
          end;


     if rodzaj<>__pVar then
      if txt[1]='#' then txt[1]:=' ';

     
     case rodzaj of
       __pDef: ety:=ety+#39+chr(v)+#39+',';

       __pReg: case chr(v) of
                '#': case t_mac[idx+k][1] of     // przez wartosc
                      'B': ety:=ety+'LD'+t_mac[idx+k][2]+'#'+txt;
                      'W': ety:=ety+'LD'+t_mac[idx+k][2]+'>'+txt + '\ LD'+t_mac[idx+k][3]+'<'+txt;
                      'L': ety:=ety+'LD'+t_mac[idx+k][2]+'^'+txt + '\ LD'+t_mac[idx+k][3]+'>'+txt + '\ LD'+t_mac[idx+k][4]+'<'+txt;
                     end;

                ' ': case t_mac[idx+k][1] of     // przez adres
                      'B': ety:=ety+'LD'+t_mac[idx+k][2]+' '+txt;
                      'W': ety:=ety+'LD'+t_mac[idx+k][2]+' '+txt + '+1\ LD'+t_mac[idx+k][3]+' '+txt;
                      'L': begin
                            ety:=ety+'LD'+t_mac[idx+k][2]+' '+txt + '+2\ LD'+t_mac[idx+k][3]+' '+txt + '+1\ LD'+t_mac[idx+k][4]+' '+txt;
                            if dreloc.use then warning(86);    // typ 'L' nie jest relokowalny
                           end;
                     end;

                '@': if t_mac[idx+k][2]<>'A' then ety:=ety+'TA'+t_mac[idx+k][2];
               end;

       __pVar: case chr(v) of
                '#',' ': case t_mac[idx+k][1] of      // przez wartosc '#' lub wartosc spod adresu ' '
                          'B': ety:=ety+'MVA '+txt+' '+str_blad;
                          'W': ety:=ety+'MWA '+txt+' '+str_blad;
                          'L': case chr(v) of
                                '#': begin
                                      txt[1]:='(';  txt:='#'+txt+')';
                                      ety:=ety+' MWA '+txt+'&$FFFF '+str_blad+'\';
                                      ety:=ety+' MVA '+txt+'>>16 '+str_blad+'+2\';
                                     end;

                                ' ': begin
                                      ety:=ety+' MWA '+txt+' '+str_blad+'\';
                                      ety:=ety+' MVA '+txt+'+2 '+str_blad+'+2';
                                     end;
                               end;
                          'D': case chr(v) of
                                '#': begin
                                      txt[1]:='(';  txt:='#'+txt+')';
                                      ety:=ety+' MWA '+txt+'&$FFFF '+str_blad+'\';
                                      ety:=ety+' MWA '+txt+'>>16 '+str_blad+'+2\';
                                     end;

                                ' ': begin
                                      ety:=ety+' MWA '+txt+' '+str_blad+'\';
                                      ety:=ety+' MWA '+txt+'+2 '+str_blad+'+2';
                                     end;
                               end;
                         end;

                    '@': ety:=ety+'STA '+str_blad;
               end;
     end;


         if rodzaj=__pDef then begin
          ety:=ety+#39+t_mac[idx+k][1]+#39+',';
          if txt[1] = '@' then ety:=ety+'0' else ety:=ety+'"'+txt+'"';
         end else ety:=ety+'\ ';

        end;

     if rodzaj=__pDef then
      zm:=ety+' \ @CALL '+#39+'X'+#39+','+t_prc[indeks].nam + ' \ @EXIT '+IntToStr(t_prc[indeks].ile) + str
     else
      zm:=ety+'JSR '+t_prc[indeks].nam;

     _odd:=High(t_mac);
     t_mac[_odd]:=zm;
     _doo:=_odd+1;
     analizuj_mem__(_odd,_doo, zm,a,old_str, 1, false);

     zm:='';

    end else begin
     txt:='JSR '+ t_prc[indeks].nam;
     i:=1; mne:=oblicz_mnemonik(i,txt,txt); // wymus wykonanie JSR
    end;

     ety:='';
    end;


(*----------------------------------------------------------------------------*)
(*  .ERROR [ERT] expression [string]                                          *)
(*----------------------------------------------------------------------------*)
   if mne.l in [__error,__ert] then
    if macro_rept_if_test then
     if pass=pass_end then begin

        save_lst(zm,' ');

        txt:=get_string(i,zm,txt,true);

        if txt<>'' then begin
         if not(run_macro) then writeln(zm) else writeln(old_str);
         blad(txt,34)
        end else begin
          war:=___wartosc_noSPC(zm,zm,i,#0,'F');
          if war<>0 then blad(zm,30);
        end;

      end else mne.l:=__nill;

      
(*----------------------------------------------------------------------------*)
(*  .EXIT                                                                     *)
(*----------------------------------------------------------------------------*)
  if mne.l=__exit then
   if macro_rept_if_test then
    if not(run_macro) then blad(zm,58) else begin

     save_lab(ety,adres,bank,zm);
     save_lst(zm,' ');

     wymus_zapis_lst(zm);

     run_macro:=false;

     wyjscie:=true;

     ety:='';

     exit;
    end;


(*----------------------------------------------------------------------------*)
(*  .ENDP                                                                     *)
(*----------------------------------------------------------------------------*)
  if mne.l=__endp then
     if ety<>'' then blad(zm,38) else
      if not(proc) then blad(zm,39) else begin

       save_lst(zm,' ');

       oddaj_var;

       oddaj_lokal(zm);

//       dec(adres, t_end[end_idx-1].adr);
//       inc(adres, t_end[end_idx-1].old);

//       dec(end_idx);

       t_prc[proc_nr-1].len := cardinal(adres) - t_prc[proc_nr-1].adr;

       get_address_update;

       proc      := false;

       org_ofset := 0;   // po .ENDP zerujemy ORG_OFSET

       proc_name := '';
      end;


(*----------------------------------------------------------------------------*)
(*  label .PROC [label]                                                       *)
(*  jesli wystepuja parametry ograniczone nawiasami '()' to zapamietaj je     *)
(*----------------------------------------------------------------------------*)
  if mne.l= __proc then
         begin
          if ety='' then ety:=get_lab(i,zm, true);

          save_lst(zm,'a');
          txt:=zm; zapisz_lst(txt);
          bez_lst:=true;
                                  
          label_type:='P';

          ety:=lokal_name+ety;

          zapisz_lokal;
          lokal_name:='';

          
          get_address(i,zm);     // pobieramy nowy adres asemblacji dla .PROC


          save_end(__endp);

          
          proc_lokal:=end_idx;   // koniecznie po SAVE_END, nie wczesniej

          save_lst(zm,'a');  proc_name:='';

          if (pass=pass_end) and not(exclude_proc) and not(dreloc.use) then
           if not(t_prc[proc_nr].use) then blad_und(zm,ety,69);


          if pass=0 then
           get_procedure(ety,ety,zm ,i)       // zapamietujemy parametry procedury
          else
           upd_procedure(ety,zm,adres);       // uaktualniamy adresy procedury


          add_proc_nr;

          if proc and (pass>0) then begin
            save_lst(zm,' ');
            i:=1; mne:=oblicz_mnemonik(i,zm,zm);
          end;

          proc      := true;

          proc_name := ety+'.';

          ety:=''
         end;


(*----------------------------------------------------------------------------*)
(*----------------------------------------------------------------------------*)
(*----------------------------------------------------------------------------*)


  case mne.l of

(*----------------------------------------------------------------------------*)
(*  wykonaj .STRUCT (np. deklaracja pola struktury za pomoca innej struktury) *)
(*  mo¿liwe jest przypisanie pol zdefiniowanych przez strukture nowej zmiennej*)
(*----------------------------------------------------------------------------*)
  __struct_run, __struct_run_noLabel:
  if ety='' then blad(zm,15) else
   if macro_rept_if_test then begin

    indeks:=mne.i;

  // sprawdzamy czy struktura nie wywoluje sama siebie
    if t_str[indeks].lab=lokal_name then blad(zm,57);


     _doo := adres-struct_adres;

     if mne.l=__struct_run then save_lab(ety,_doo,bank,zm);
     save_lst(zm,' ');

   // odczytujemy liczbe pol struktury
     k:=t_str[indeks].ofs;
     inc(indeks);

     for idx:=indeks to indeks+k-1 do begin

      txt:=t_str[idx].lab;

      if mne.l=__struct_run_noLabel then
       str:=txt
      else begin
       _odd:=pos('.',txt);
       if _odd>0 then txt:=copy(txt,_odd,length(txt));

       if txt[1]<>'.' then txt:='.'+txt;

       str:=ety+txt;
      end;

      j:=t_str[idx].siz;

      if struct then begin
       k:=t_str[idx].ofs+_doo; // konieczna operacja, bo STRUCT_ADRES nie zostal zwiekszony

       save_str(str,k,j,1,adres,bank);           // tutaj zwiekszony zostaje STRUCT_ADRES

       save_lab(str,adres-struct_adres,bank,zm); // tutaj operujemy na nowej wartosci STRUCT_ADRES

       inc(struct_cnt);        // zwiekszamy licznik pol w strukturze
      end else
       save_lab(str,adres,bank,zm);

      inc(adres, j);
     end;

    ety:='';
   end;


(*----------------------------------------------------------------------------*)
(*  wykonaj .MACRO gdy PASS>0                                                 *)
(*----------------------------------------------------------------------------*)
  __macro_run:
//        if macro then halt {inc(macro_nr)} else
        if if_test then begin

         save_lab(ety,adres,bank,zm);

         save_lst(zm,'i');
         txt:=zm;         zapisz_lst(txt);

         indeks:=mne.i;  

//-         zapisz_lokal;

       // zapamietujemy aktualne makro w 'OLD_MACRO_NR'
                 
         old_macro_nr:=macro_nr;
         
         txt:=t_mac[indeks+1];
         str:='Macro: '+txt+' [Source: '+t_mac[indeks+0]+']';

         if macro_nr='' then
          macro_nr:=macro_nr+lokal_name+proc_name+txt+t_mac[indeks+3]+'.'
         else
          macro_nr:=macro_nr+proc_name+txt+t_mac[indeks+3]+'.';

//-         lokal_name:='';

         omin_spacje(i,zm);  SetLength(par,2);
        // na pozycji par[0] zostanie wpisana liczba parametrow

         k:=ord(t_mac[indeks+2][1]);      // tryb pracy
         ch:=t_mac[indeks+2][2];          // separator

//         while not(zm[i] in [#0,';']) and ((zm[i]<>'/') and (zm[i+1]<>'/')) do begin
         while not(test_char(i,zm,#0,#0)) do begin

          txt:=get_dat(i,zm,ch,true);

        // dyrektywy (oraz FOX_RIPIT '#') zostana bezwglednie wyliczone
          if (txt[1]='.') or ( (txt[1]='#') and _eol(txt[2]) ) then begin
            war:=oblicz_wartosc(txt,zm);
            txt:=IntToStr(war);
          end;

        // jesli przekazywany parametr jest miedzy apostrofami " " to jest to ciag znakowy
          if txt<>'' then
           if (txt[1]='"') and (txt[length(txt)]='"') then txt:=copy(txt,2,length(txt)-2);

          _odd:=High(par);

          if k=byte('''') then begin
           par[_odd]:=txt;
           SetLength(par,_odd+2);
          end else begin

            if txt[1]='#' then begin
             par[_odd]:='''#''';
             txt:=copy(txt,2,length(txt));
            end else
             if txt[1] in ['<','>'] then begin
              par[_odd]:='''#''';
              war:=oblicz_wartosc(txt,zm);
              txt:=IntToStr(war);
             end else par[_odd]:=''' ''';

           SetLength(par,_odd+3);
           par[_odd+1]:=txt;
          end;

//          omin_spacje(i,zm);
          if zm[i] in [',',' ',#9] then __next(i,zm);

           if ch<>' ' then
            if zm[i]=ch then __inc(i,zm); // else Break;

         end;

        // zapisujemy liczbe parametrow dla :0
         par[0]:=IntToStr(High(par)-1);


        // pobieramy numer wywolania makra z T_MAC[indeks+3] i zapisujemy w 'MACRO_NR'
        // zwiekszamy numer wywolania makra

         _doo:=integer( StrToInt(t_mac[indeks+3]) );
         t_mac[indeks+3]:=IntToStr(_doo+1);


        // !!! zabezpieczenie przed rekurencja bez konca !!!
        // zatrzymujemy wykonanie makra jesli liczba wywolan przekroczy 4095
         if _doo>4095 then blad(zm,66);


         _doo:=integer( StrToInt(t_mac[indeks+4]) );
         txt:=t_mac[indeks];

         inc(wyw_idx);
         if wyw_idx>High(t_wyw) then SetLength(t_wyw,wyw_idx+1);

         t_wyw[wyw_idx].zm := zm;
         t_wyw[wyw_idx].pl := txt;
         t_wyw[wyw_idx].nr := _doo;

        // zapamietujemy aktualny indeks do T_MAC w _ODD
        // odczytujemy makro z T_MAC[indeks], podstawiamy parametry i zapisujemy do T_MAC
        // potem zwolnimy miejsce na podstawie wczesniej zapamietanego indeksu w _ODD
        
         _odd:=High(t_mac);

         while true do begin
          txt:=t_mac[indeks+5];

          j:=1;
          ety:=get_datUp(j,txt,#0,false);  // koniecznie potrzebuje duzych liter

          tst:=fCRC16(ety);                // aby odnalezc wpis .ENDM, .MEND

          if not(tst=__endm) then begin

           j:=1;
           while j<=length(txt) do
            if test_param(j,txt) then begin

             k:=j;
             if txt[j]=':' then inc(j) else inc(j,2);

//             war:=get_value(j,txt);
//             if war<0 then blad(zm,47);

             ety:='';
             while _dec(txt[j]) do begin ety:=ety+txt[j]; inc(j) end;

             war:=StrToInt(ety);

             delete(txt,k,j-k);  dec(j,j-k);
             if war>High(par)-1 then begin
              insert('$FFFFFFFF',txt,k); inc(j,9);   // musi koniecznie wpisac ciag $FFFFFFFF
             end else begin
              insert(par[war],txt,k); inc(j,length(par[war]));
             end;

            end else inc(j);

           save_mac(txt);
          end else Break;

          inc(indeks);
         end;


         if not(FOX_ripit) and not(rept_run) then put_lst(str);

        // zapamietaj w zmiennych lokalnych
         old_run_macro   := run_macro;
         old_else_used   := else_used;
         old_elseif_used := elseif_used;
         old_ifelse      := ifelse;
         old_loopused    := loop_used;

         run_macro := true;

         loop_used := false;

         _doo:=High(t_mac);

//         for idx:=_odd to _doo-1 do writeln(t_mac[idx],','); halt;

         analizuj_mem__(_odd,_doo, zm,a,old_str, 1, false);

         if not(FOX_ripit) then bez_lst:=true;

         run_macro   := old_run_macro;
         else_used   := old_else_used;
         elseif_used := old_elseif_used;
         ifelse      := old_ifelse;
         macro_nr    := old_macro_nr;
         loop_used   := old_loopused;

//-         oddaj_lokal(zm);

         if not(lst_off) and not(FOX_ripit) and not(rept_run) then put_lst(show_full_name(a,full_name,true));

         dec(wyw_idx);

         SetLength(t_mac,_odd+1);

         if_test     := true;          // po zakonczeniu makra zawsze mamy
                                       // IF_TEST = TRUE, poniewaz makro wykonujemy
                                       // tylko jesli IF_TEST = TRUE :)
         ety:='';
        end;


(*----------------------------------------------------------------------------*)
(*  label .MACRO [label]                                                      *)
(*  wystapienie dyrektywy .MACRO oznacza conajmniej 3 przebiegi asemblacji    *) 
(*----------------------------------------------------------------------------*)
   __macro:
         begin
          if ety='' then ety:=get_lab(i,zm, true);

          if (pass=0) and if_test then begin

           reserved_word(ety,zm);
           save_lab(ety,High(t_mac),__id_macro,zm);

           str:=show_full_name(a,full_name,false);  save_mac(str);  // zapisanie nazwy pliku z makrem
           str:={lokal_name+}ety;                   save_mac(str);  // zapisanie nazwy makra

           ety:=''''; ch:=',';

           omin_spacje(i,zm);
           if zm[i] in ['''','"'] then begin
           // wczytujemy i sprawdzamy poprawnosc
            ety:=zm[i];
            str:=get_string(i,zm,zm,true);

            if str<>'' then ch:=str[1];

//            if length(txt)>1 then blad(zm,3) else
//             if txt='' then txt:=',';
           end;

           str:=ety+ch;         save_mac(str); // separator i tryb dzialania
           str:='0';            save_mac(str); // numer wywolania makra
           str:=IntToStr(line); save_mac(str); // numer linii z makrem

           if pass_end<3 then pass_end:=3;     // jesli sa makra to musza byc conajmniej 3 przebiegi
          end;

          macro := true;

          save_lst(zm,' ');

//          save_end(__endm);

          ety:=''
         end;

(*----------------------------------------------------------------------------*)
(*  .IF [IFT] expression                                                      *)
(*----------------------------------------------------------------------------*)
   __if:
       if ety<>'' then blad(zm,38) else
//        if macro then inc(ifelse) else
         if not(rept) then begin

           if_stos[ifelse]._else    := else_used;
           if_stos[ifelse]._elseif  := elseif_used;
           if_stos[ifelse]._if_test := if_test;

           inc(ifelse);
           if ifelse>High(if_stos) then SetLength(if_stos,ifelse+1);

           if_stos[ifelse]._okelse:=$7FFFFFFF;      // zablokowany .ELSE

           if if_test then begin
            save_lst(zm,' ');

            else_used   := false;
            elseif_used := false;

            if_stos[ifelse]._okelse := ifelse;

            branch := true;               // tutaj nie ma mowy o relokowalnosci

            war:=___wartosc_noSPC(zm,zm,i,#0,'F');

            if_test := (war<>0);
           end;

           if_stos[ifelse]._else    := else_used;
           if_stos[ifelse]._elseif  := elseif_used;
           if_stos[ifelse]._if_test := if_test;

         end else if_test:=false;

(*----------------------------------------------------------------------------*)
(*  .ENDIF [EIF]                                                              *)
(*----------------------------------------------------------------------------*)
   __endif:
       if ety<>'' then blad(zm,38) else
//        if macro then dec(ifelse) else
         if not(rept) then begin

          if ifelse>0 then begin

           dec(ifelse);

           if_test     := if_stos[ifelse]._if_test;
           else_used   := if_stos[ifelse]._else;
           elseif_used := if_stos[ifelse]._elseif;

          end else blad(zm,37);

         end else if_test := true;
            

(*----------------------------------------------------------------------------*)
(*  .ELSE [ELS]                                                               *)
(*----------------------------------------------------------------------------*)
   __else:
       if ety<>'' then blad(zm,38) else
        if not(rept) then
         if if_stos[ifelse]._okelse=ifelse then begin

          if else_used then blad(zm,1);
          if ifelse=0 then blad(zm,37);

          if_stos[ifelse]._else:=true;
          else_used := true;

          if_test := not(if_stos[ifelse]._if_test);
         end;

(*----------------------------------------------------------------------------*)
(*  .PRINT 'string' [,string2...] [,expression1,expression2...]               *)
(*----------------------------------------------------------------------------*)
   __print:
       if ety<>'' then blad(zm,38) else
        if macro_rept_if_test then
         if pass=pass_end then begin

           save_lst(zm,' ');

           pisz   := true;
           branch := true;              // dla .PRINT nie istnieje relokowalnosc

           oblicz_dane(i,zm,zm,4);

           pisz   := false;

           end_string := end_string + #13#10;
          end;

(*----------------------------------------------------------------------------*)
(*  .ELSEIF [ELI] expression                                                  *)
(*----------------------------------------------------------------------------*)
   __elseif:
       if ety<>'' then blad(zm,38) else
        if not(rept) then
         if if_test and else_used then blad(zm,42) else
           if ifelse=0 then blad(zm,37) else 
            if not(if_test) and not(elseif_used) then begin

              save_lst(zm,' ');

              branch:=true;               // tutaj nie ma mowy o relokowalnosci
              war:=___wartosc_noSPC(zm,zm,i,#0,'F');

              if war<>0 then begin
               elseif_used := true;
               if_test     := true;

               if_stos[ifelse]._if_test := true;
              end;
              
            end else if_test:=false;

(*----------------------------------------------------------------------------*)
(*  label .LOCAL [label]                                                      *)
(*----------------------------------------------------------------------------*)
   __local:
        if macro_rept_if_test then begin

          if ety='' then begin
           omin_spacje(i,zm);
           ety:=get_lab(i,zm, false);
          end;

        // jesli brak nazwy obszaru .LOCAL to przyjmij domyslna nazwe
          if ety='' then begin
           ety:='L@C?L?'+IntToStr(lc_nr);
           inc(lc_nr);
          end;

          if pass=0 then if ety[1]='?' then warning(8);


          t_loc[lokal_nr].ofs := org_ofset;


          get_address(i,zm);       // nowy adres asemblacji dla .LOCAL


//          save_lab(ety,adres,bank,zm);

   if run_macro then tmp:=macro_nr+ety else         // skopiowana zawartosc SAVE_LAB
    if proc then tmp:=proc_name+lokal_name+ety else
     tmp:=lokal_name+ety;

   s_lab( tmp, adres, bank, zm, '?' );              // znak '?' zapobiega bledowi 'label declared twice'


          save_lst(zm,'a');

          t_loc[lokal_nr].adr := adres;
          idx:=load_lab(ety, false);

          t_loc[lokal_nr].idx := idx;


          save_end(__endl);

          zapisz_lokal;
          lokal_name:=lokal_name+ety+'.';

//-          if first_org then blad(zm,10);

          ety:='';
         end;

(*----------------------------------------------------------------------------*)
(*  .ENDL                                                                     *)
(*----------------------------------------------------------------------------*)
   __endl:
        if ety<>'' then blad(zm,38) else
         if macro_rept_if_test then
          if lokal_nr>0 then begin

           save_lst(zm,' ');

           if not(proc) then oddaj_var;

           oddaj_lokal(zm);

           if t_loc[lokal_nr].idx>=0 then
            t_lab[t_loc[lokal_nr].idx].lln:=adres-t_loc[lokal_nr].adr;

           org_ofset := t_loc[lokal_nr].ofs;

//           dec(end_idx);

           get_address_update;

          end else blad(zm,28);

(*----------------------------------------------------------------------------*)
(*  .REPT expression                                                          *)
(*----------------------------------------------------------------------------*)
   __rept:
        if if_test then
         if rept then blad(zm,43) else begin

         save_lab(ety,adres,bank,zm);
         save_lst(zm,' ');

         save_end(__endr);

         rept_ile:=integer( ___wartosc_noSPC(zm,zm,i,#0,'F') );
         testRange(zm, rept_ile, 0);

         line_add := line;

         rept_nr  := High(t_mac);
         rept     := true;

         ety:='';
        end;


(*----------------------------------------------------------------------------*)
(*  label .STRUCT [label]                                                     *)
(*  wystapienie dyrektywy .STRUCT oznacza conajmniej trzy przebiegi asemblacji*)
(*----------------------------------------------------------------------------*)
   __struct:
        if macro_rept_if_test then
         if struct then blad(zm,56) else begin

           sav_lab_no:=true;

           if ety='' then ety:=get_lab(i,zm, true);

           if pass=0 then reserved_word(ety,zm);

           txt:=lokal_name+ety;

           struct_cnt := 0;

          // sprawdzamy czy mamy juz zapamietana ta strukture
           idx:=loa_str(txt, struct_id);

          // nie znalazl ofsetu do tablicy (idx = -1)
           if idx<0 then begin

            save_str(txt,adres,0,1,adres,bank);      // dopisz do tablicy

            struct_idx:=loa_str(txt, struct_id);

            save_lab(ety,struct_idx,__id_struct,zm);

           end else begin
          // znalazl ofset do tablicy
            struct_idx:=idx;         

            save_lab(ety,struct_idx,__id_struct,zm);
           end;


           if pass_end<3 then pass_end:=3;     // jesli sa struktury to musza byc conajmniej 3 przebiegi


           zapisz_lokal;
           lokal_name:=lokal_name+ety+'.';

           struct := true;

         // zapamietujemy adres, aby oddac go po .ENDS
           struct_adres := adres;

           save_lst(zm,'a');

           save_end(__ends);

           ety:='';
          end;

(*----------------------------------------------------------------------------*)
(*  .ENDS                                                                     *)
(*  zapisujemy w tablicy 'T_STR' dlugosc i liczbe pol struktury               *)
(*----------------------------------------------------------------------------*)
   __ends:
        if ety<>'' then blad(zm,38) else
         if macro_rept_if_test then
          if not(struct) then blad(zm,55) else begin

           save_lst(zm,' ');

           oddaj_lokal(zm);

           struct     := false;
           sav_lab_no := false;

           t_str[struct_idx].siz := adres - struct_adres; // zapisujemy dlugosc struktury

           t_str[struct_idx].ofs := struct_cnt;           // i liczbe pol struktury

           adres := struct_adres;                         // zwracamy stary adres asemblacji

           inc(struct_id);  // zwiekszamy identyfikator struktury (liczba struktur)

           struct_cnt := -1;

//           dec(end_idx);
           dec_end(zm,__ends);

          end;

(*----------------------------------------------------------------------------*)
(*  zapisujemy wartosc do tablicy .ARRAY                                      *)
(*----------------------------------------------------------------------------*)
   __array_val:
      if ety<>'' then blad(zm,38) else begin

        get_data_array(i,zm, t_arr[array_idx].idx, t_arr[array_idx].siz);

      end;

(*----------------------------------------------------------------------------*)
(*  .ARRAY                                                                    *)
(*  tablica ze zdefiniowanymi wartosciami                                     *)
(*----------------------------------------------------------------------------*)
   __array:
        if aray then blad(zm,60) else
         if macro_rept_if_test then begin

          if ety='' then ety:=get_lab(i,zm, true);

          if pass=0 then reserved_word(ety,zm);

          array_idx := High(t_arr);

          save_lab(ety,array_idx,__id_array,zm);
          save_lst(zm,'a');

          save_arr(adres,bank);

          omin_spacje(i,zm);
          txt:=get_dat(i,zm,' ',true);

          idx := integer( oblicz_wartosc(txt,zm) );

          t_arr[array_idx].idx:=idx;

          r:=get_type(i,zm,true);

          t_arr[array_idx].siz := r;
          t_arr[array_idx].len := (idx+1)*r;

          //if (idx<0) or (t_arr[array_idx].len>$FFFF) then blad(zm,62);
          testRange(zm, idx, 62);
          testRange(zm, t_arr[array_idx].len, 62);

          array_used.typ := tType[ t_arr[array_idx].siz ];

          war:=0;       // dopuszczalna maksymalna wartosc typu D-WORD

          omin_spacje(i,zm);
          if zm[i]='=' then begin
            __inc(i,zm);
            war:=oblicz_wartosc_noSPC(zm,zm,i,#0,tType[r]);
          end;

          for j:=0 to idx do t_tmp[j]:=cardinal(war);    // FILLCHAR wypelnia tylko bajtami

          aray := true;

          save_end(__enda);

          ety:='';
         end;

(*----------------------------------------------------------------------------*)
(*  .ENDA                                                                     *)
(*----------------------------------------------------------------------------*)
   __enda:
        if ety<>'' then blad(zm,38) else
         if macro_rept_if_test then
          if not(aray) then blad(zm,59) else begin

           aray := false;

           v    := t_arr[array_idx].siz;
           _doo := t_arr[array_idx].len div v;

           for idx:=0 to _doo-1 do  save_dta(t_tmp[idx],zm, tType[v],0);

           t:=''; save_lst(zm,' ');

//           dec(end_idx);
           dec_end(zm,__enda);

          end;


(*----------------------------------------------------------------------------*)
(*  label EXT type                                                            *)
(*----------------------------------------------------------------------------*)
   __ext:
   if ety='' then blad(zm,15) else
    if macro_rept_if_test then
     if loop_used then blad(zm,36) else begin

      v := get_typeExt(i,zm);

      save_extLabel(i,ety,zm,v);

      nul.i:=0;
      save_lst(zm,'l');

      ety:='';
     end;


(*----------------------------------------------------------------------------*)
(*  .EXTRN label1, label2, label3 ... type                                    *)
(*  rozbudowany odpowiednik pseudo rozkazu EXT                                *)
(*----------------------------------------------------------------------------*)
 __extrn:
    if macro_rept_if_test then begin
//     if loop_used then blad(zm,36) else begin

      nul.i:=0;
      save_lst(zm,'l');
      v:=0;

      if ety='' then begin         // jesli .EXTRN nie poprzedza etykieta

       while true do begin

        get_parameters(i,zm,par,false);
        v:=get_typeExt(i,zm);

        _doo:=High(par);

        for _odd:=_doo-1 downto 0 do begin
         txt:=par[_odd];

         if txt<>'' then save_extLabel(i,txt,zm,v) else blad(zm,15);
        end;

        omin_spacje(i,zm);
        if (v=__proc) or (test_char(i,zm,#0,#0)) then Break;
       end;

      end else begin               // jesli .EXTRN poprzedza etykieta
       v := get_typeExt(i,zm);
       save_extLabel(i,ety,zm,v);
      end;

    ety:='';
   end;


(*----------------------------------------------------------------------------*)
(*  .VAR label1, label2, label3 ... type                                      *)
(*----------------------------------------------------------------------------*)
 __var:
  if ety<>'' then blad(zm,38) else
   if macro_rept_if_test then begin
//    if loop_used then blad(zm,36) else begin

     nul.i:=0;
     save_lst(zm,'l');

     while true do begin
      get_vars(i,zm,par);

      omin_spacje(i,zm);
      if test_char(i,zm,#0,'=') then Break;
     end;

   // sprawdz czy zostal okreslony adres zmiennych '= expression'
     idx:=-1;

     if zm[i]='=' then begin
      inc(i);
      idx:=integer( oblicz_wartosc_noSPC(zm,zm,i,#0,'A') );
     end;


     if idx>=0 then
      for _doo:=0 to var_idx-1 do
       if t_var[_doo].id=var_id then begin
        t_var[_doo].adr:=idx;
        inc(idx, t_var[_doo].cnt*t_var[_doo].siz);
       end;

     inc(var_id);

     ety:='';
    end;


(*----------------------------------------------------------------------------*)
(*  .BY [+byte] bytes and/or ASCII                                            *)
(*  .WO words                                                                 *)
(*  .HE hex bytes                                                             *)
(*----------------------------------------------------------------------------*)
 __by, __wo, __he, __sb:
  if (mne.l<>__he) and (dreloc.use or dreloc.sdx) then blad(zm,71) else
   if macro_rept_if_test then begin

   save_lab(ety,adres,bank,zm);

   case mne.l of
    __by: get_maeData(zm,i,'B');
    __wo: get_maeData(zm,i,'W');
    __he: get_maeData(zm,i,'H');
    __sb: get_maeData(zm,i,'S');
   end;

   ety:='';
  end;


(*----------------------------------------------------------------------------*)
(*  .WHILE (.BYTE | .WORD) ARG1 OPERAND ARG2                                  *)
(*----------------------------------------------------------------------------*)
 __while:
    if macro_rept_if_test then begin
//     if loop_used then blad(zm,36) else begin

//      if ety='' then ety:=get_lab(i,zm, true);

      if ety<>'' then  save_lab(ety,adres,bank,zm);
      save_lst(zm,'a');

      if while_name='' then while_name:=lokal_name;
      while_name:=while_name+IntToStr(while_nr)+'.';   // sciezka dostepu do WHILE


      long_test:='';
      wyrazenie_warunkowe(i, long_test, zm,txt,tmp,v,r);


      if long_test<>'' then begin

       create_long_test(v, r, long_test, txt, tmp);

       long_test:=long_test+'\EX LDA#0\:?J/2-1 ORA#0\.ENDL';

      end;


      save_end(__endw);


      ety:='##B'+while_name;                // poczatek .WHILE

      save_fake_label(ety,zm,adres);


      ety:='@?@?@ML?E'+while_name;          // koniec WHILE


      if long_test='' then
       mne := asm_test(txt,tmp,zm, ety, r,v)
      else begin

       idx:=High(t_mac);  _odd:=idx+1;

       t_mac[idx]:=long_test+'\ JEQ '+ety;

       idx:=0; _odd:=1;

       save_lst(zm,'i');
       txt:=zm;
       zapisz_lst(txt);

       tst:=opt;
       opt:=opt and (not(4));

       analizuj_mem__(idx,_odd, zm,a,old_str, 1, false);

       opt:=tst;

       bez_lst:=true;
      end;
  

      inc(whi_idx);

      inc(while_nr);

      ety:='';

    end;


(*----------------------------------------------------------------------------*)
(*  .ENDW                                                                     *)
(*----------------------------------------------------------------------------*)
 __endw:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then
      if whi_idx>0 then begin
//     if loop_used then blad(zm,36) else begin

        save_lst(zm,'a');

        dec(whi_idx);


     ety:='##B'+while_name;

     war:=load_lab(ety,false);    // odczytujemy wartosc etykiety poczatku petli WHILE ##B
     if war>=0 then begin
      tst:=t_lab[war].adr;

      save_relAddress(integer(war), reloc_value);

      if pass=pass_end then
       if t_lab[war].bnk<>bank then warning(70); // petla .WHILE musi znajdowac sie w obszarze tego samego banku
     end else
      tst:=0;


        txt:='JMP '+IntToStr(tst);
        k:=1;  mne:=oblicz_mnemonik(k,txt,zm);


     ety:='@?@?@ML?E'+while_name;

     idx := adres + 3;            // E## = aktualny adres + 3 bajty (JMP)

     save_fake_label(ety,zm,idx);


        obetnij_kropke(while_name);

//        dec(end_idx);
        dec_end(zm,__endw);

        ety:='';
       end else blad(zm,88);


(*----------------------------------------------------------------------------*)
(*  .TEST (.BYTE | .WORD) ARG1 OPERAND ARG2 ...                               *)
(*----------------------------------------------------------------------------*)
 __test:
    if macro_rept_if_test then begin

      if ety<>'' then  save_lab(ety,adres,bank,zm);
      save_lst(zm,'a');

      if test_name='' then test_name:=lokal_name;
      test_name:=test_name+IntToStr(test_nr)+'.';   // sciezka dostepu do TEST

      long_test:='';
      wyrazenie_warunkowe(i, long_test,zm,txt,tmp,v,r);

      if long_test<>'' then begin

       create_long_test(v, r, long_test, txt, tmp);

       long_test:=long_test+'\EX LDA#0\:?J/2-1 ORA#0\.ENDL';

      end;


      save_end(__endt);


      ety:='##TB'+test_name;                // poczatek .TEST

      save_fake_label(ety,zm,adres);


      ety:='@?@?@ML?TE'+test_name;          // koniec TEST


      if long_test='' then
       mne := asm_test(txt,tmp,zm, ety, r,v)
      else begin

       idx:=High(t_mac);  _odd:=idx+1;

       t_mac[idx]:=long_test+'\ JEQ '+ety;

       idx:=0; _odd:=1;

       save_lst(zm,'i');
       txt:=zm;
       zapisz_lst(txt);

       tst:=opt;
       opt:=opt and (not(4));

       analizuj_mem__(idx,_odd, zm,a,old_str, 1, false);

       opt:=tst;

       bez_lst:=true;
      end;


      inc(test_idx);

      inc(test_nr);

      ety:='';
    end;


(*----------------------------------------------------------------------------*)
(*  .ENDT                                                                     *)
(*----------------------------------------------------------------------------*)
 __endt:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then
      if test_idx>0 then begin
//     if loop_used then blad(zm,36) else begin

        save_lst(zm,'a');

        dec(test_idx);


     ety:='##TB'+test_name;

     war:=load_lab(ety,false);    // odczytujemy wartosc etykiety poczatku petli TEST ##TB
     if war>=0 then
      if pass=pass_end then
       if t_lab[war].bnk<>bank then warning(70); // TEST musi znajdowac sie w obszarze tego samego banku


     ety:='@?@?@ML?TE'+test_name;       // TE## = aktualny adres

     save_fake_label(ety,zm,adres);


        obetnij_kropke(test_name);

//        dec(end_idx);
        dec_end(zm,__endt);

        ety:='';
       end else blad(zm,95);


(*----------------------------------------------------------------------------*)
(*  .DEF label                                                                *)
(*----------------------------------------------------------------------------*)
 __def:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then begin

      idx:=adres;

      omin_spacje(i,zm);
      ety:=get_lab(i,zm,true);

      omin_spacje(i,zm);

      if zm[i]='=' then begin
       __inc(i,zm);

       idx:=oblicz_wartosc_noSPC(zm,a,i,#0,'W');
      end else
       if not(test_char(i,zm,#0,#0)) then blad(zm,58);

      nul.i:=idx;
      save_lst(zm,'l');
      data_out := true;     // wymus pokazanie w pliku LST podczas wykonywania makra

      old_run_macro := run_macro;
      run_macro     := false;
      txt           := lokal_name;
      _odd          := lokal_nr;

//-      oddaj_lokal(zm);

      save_lab(ety,idx,bank,zm);

      run_macro     := old_run_macro;
      lokal_name    := txt;
      lokal_nr      := _odd;

      ety:='';
     end;


(*----------------------------------------------------------------------------*)
(*  .USING label [,label2...]                                                 *)
(*----------------------------------------------------------------------------*)
 __using:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then begin

      save_lst(zm,'i');
 
      get_parameters(i,zm,par,false);

      if pass>0 then
       for k:=0 to High(par)-1 do begin

        txt:=par[k];

        _odd:=load_lab(txt, false);
        if _odd<0 then blad_und(zm,txt,5);

        t_usi[usi_idx].lok:=end_idx;
        t_usi[usi_idx].lab:=txt;

        inc(usi_idx);

        SetLength(t_usi, usi_idx+1);
       end;

     end;

(*----------------------------------------------------------------------------*)
(*  .FL                                                                       *)
(*----------------------------------------------------------------------------*)
 __fl:
    if macro_rept_if_test then begin

     save_lab(ety,adres,bank,zm);

     save_lst(zm,'a');

     omin_spacje(i,zm);

     while not(test_char(i,zm,#0,#0)) do begin
       txt:=get_dat(i,zm,',',true);
       save_fl(txt, zm);
       if zm[i] in [',',' ',#9] then __next(i,zm) else Break;
     end;

     ety:='';
    end;


(*----------------------------------------------------------------------------*)
(*  label EQU [=] expression                                                  *)
(*----------------------------------------------------------------------------*)
   __equ,__smb,__addEqu:
       if ety='' then blad(zm,15) else
        if macro_rept_if_test then
         if loop_used then blad(zm,36) else begin

           if dreloc.use then
            if mne.l in [__equ,__smb] then blad(zm,71);

           label_type:='C';   

           old_case   := dreloc.use;   // deklaracje etykiet w bloku .RELOC nie moga byc relokowalne
           dreloc.use := false;

          // SMB
           if mne.l=__smb then begin

            txt:=get_smb(i,zm);

          // wymuszamy relokowalnosc dla tej etykiety
          // jesli BLOK>1 to zaznaczy jako etykiete relokowalna
            k:=blok; blok:=$FFFF;
            save_lab(ety,smb_idx,__id_smb,zm);
            blok:=k;

            save_smb(txt);
            war:=__rel;

           end else begin
            branch:=true;       // dla EQU nie ma relokowalnosci

         // nie mozna przypisac wartosci etykiety external, smb

            blocked := true;
            war:=___wartosc_noSPC(zm,zm,i,#0,'F');
            blocked := false;

            mne_used:=true;    // konieczny test dla zmieniajacych sie wartosci etykiet

         {   if mne.l=__addEqu then
             s_lab(ety,cardinal(war),bank,a,ety[1])           // __ADD_EQU
            else }
             save_lab(ety,cardinal(war),bank,zm);             // EQU

            data_out := true;     // wymus pokazanie w pliku LST podczas wykonywania makra
           end;

           nul.i:=integer( war );
           save_lst(zm,'l');

           dreloc.use := old_case;

           ety:='';
          end;


(*----------------------------------------------------------------------------*)
(*  OPT holscmtb?f +-                                                         *)
(*----------------------------------------------------------------------------*)
(*  bit                                                                       *)
(*   0 - Header                        default = yes   'h+'                   *)
(*   1 - Object file                   default = yes   'o+                    *)
(*   2 - Listing                       default = no    'l-'                   *)
(*   3 - Screen (listing on screen)    default = no    's-'                   *)
(*   4 - CPU 8bit/16bit                default = 6502  'c-'                   *)
(*   5 - visible macro                 default = no    'm-'                   *)
(*   6 - track sep rep                 default = no    't-'                   *)
(*   7 - banked mode                   default = no    'b-'                   *)
(*   8 - MAE ?labels                   default = no    '?-'                   *)
(*----------------------------------------------------------------------------*)
   __opt:
       if macro_rept_if_test then begin

         txt:=get_dat_noSPC(i,zm,',',#0,zm);   // pomijamy spacje

         j:=1;

         while j<=length(txt) do begin

          ch:=txt[j+1];

          opt_tmp:=opt;

          tst:=0;

          case UpCase(txt[j]) of
           'F': raw.use:= (ch='+');
           'H': tst:=1;
           'O': tst:=2;
           'L': tst:=4;
           'S': tst:=8;
           'C': tst:=16;
           'M': tst:=32;
           'T': tst:=64;
           'B': tst:=128;
           '?': tst:=256;
          else
           blad(zm,16);
          end;

          case ch of
           '+': opt:=opt or tst;
           '-': opt:=opt and (not(tst));
          else
           blad(zm,16);
          end;

          if (opt_tmp and 1)<>(opt and 1) then        // OPT H-
           if (opt and 1)=0 then save_hea; 

          inc(j,2);
         end;

         data_out:=true;

         save_lst(zm,' ');
       end;


(*----------------------------------------------------------------------------*)
(*  ORG adres [,adres2]                                                       *)
(*  RUN adres                                                                 *)
(*  INI adres                                                                 *)
(*  BLK                                                                       *)
(*----------------------------------------------------------------------------*)
   __org, __run, __ini, __blkSpa, __blkRel, __blkEmp:
    if if_test then
     if loop_used or rept then blad(zm,36) else
      if dreloc.use then blad(zm,71) else
       if first_org and (ety<>'') then blad(zm,10) else begin


         if (org_ofset>0) and ((lokal_name<>'') or proc) then blad(zm,71);


         if hea_ofs.adr>=0 then
          raw.old := hea_ofs.adr+(adres-hea_ofs.old)
         else
          raw.old := adres;


         label_type:='C';    

         data_out:=true;

         save_lst(zm,'a');

         branch:=true;    // relokowalnosc tutaj niemozliwa

         rel_ofs:=0; {org_ofs:=0;}
         idx:=-$FFFF;  hea_ofs.adr:=-1;  _odd:=-1;

         save_lab(ety,adres,bank,zm);

         omin_spacje(i,zm);

         v := mne.l;    // !!! koniecznie V := MNE.L !!! aby zadzialalo RUN, INI
         
         case v of
         // BLK SPARTA a
          __blkSpa:
               begin
                dreloc.sdx:=true;

                opt_tmp := opt;
                opt_h_minus;

                blok:=0;

              // a($fffa),a(str_adr),a(end_adr)
                save_dstW( $fffa );

                idx:=integer( ___wartosc_noSPC(zm,zm,i,',','A') );
                opt := opt_tmp;
               end;

         //BLK R[eloc] M[ain]|E[xtended]
          __blkRel:
              begin
                dreloc.sdx:=true;

                ds_empty:=0;

                opt_tmp := opt;
                opt_h_minus;

                v := getMemType(i,zm);

                add_blok(zm);

              // a($fffe),b(blk_num),b(blk_id)
              // a(blk_off),a(blk_len)
                save_dstW( $fffe );
                save_dst(byte(blok));
                save_dst(memType);

                if blok=1 then
                 idx:=__rel
                else begin
                 rel_ofs:=adres-__rel;
                 _odd:=adres; idx:=adres;
                end;

                opt := opt_tmp;
              end;

         //BLK E[mpty] a M[ain]|E[xtended]
          __blkEmp:
              begin
                opt_tmp := opt;
                opt_h_minus;

                _odd:=integer( ___wartosc_noSPC(zm,zm,i,' ','A') );  // !!! koniecznie znak spacji ' ' !!!
                                                                     // blk empty empend-tdbuf extended
                v := getMemType(i,zm);

                blk_empty(_odd, zm);

//                inc(adres, _odd);
                idx:=adres + _odd;

                opt := opt_tmp;

                if ds_empty>0 then blad(zm,57);  // albo .DS albo BLK EMPTY, nie mozna obu naraz
              end;

          // ORG
          __org: begin

                if dreloc.sdx then blad(zm,71);

                oddaj_var;

                if zm[i]='[' then begin
                 opt_tmp := opt;
                 opt_h_minus;

                 txt:=ciag_ograniczony(i,zm,true);
                 k:=1; oblicz_dane(k,txt,zm,1);

                 omin_spacje(i,zm);
                 if zm[i]=',' then begin
                  inc(i);
                  idx:=integer( ___wartosc_noSPC(zm,zm,i,#0,'A') );
                 end;

                 opt := opt_tmp;

                end else idx:=integer( ___wartosc_noSPC(zm,zm,i,',','A') );

                org_ofset:=0;

                omin_spacje(i,zm);
                if zm[i]=',' then begin
                 inc(i);

                 {org_ofs:=idx;}
                 hea_ofs.adr := integer( ___wartosc_noSPC(zm,zm,i,#0,'A') );
                 if hea_ofs.adr<0 then blad(zm,10);

                 hea_ofs.old := idx;

                { if adres<0 then
                  org_ofset := hea_ofs.adr
                 else   }
                  org_ofset := idx - hea_ofs.adr;

                end;

               end;

          // RUN,INI
          __run,__ini:
               begin

                if dreloc.sdx then blad(zm,71);

                oddaj_var;

                idx:=integer( ___wartosc_noSPC(zm,zm,i,#0,'A') );
                mne.l:=2; mne.h[0]:=byte(idx); mne.h[1]:=byte(idx shr 8);
                
                idx:=$2e0 + v - __run;
               end;
         end;


         if (adres<>idx) or (_odd>=0) then begin

           if raw.use then begin
           
             if raw.old<0 then
              k:=0
             else
              if hea_ofs.adr>=0 then
               k:=hea_ofs.adr-raw.old
              else
               k:=idx-raw.old;

              if k<0 then blad(zm,108);

             if not(hea) then
              for j:=0 to k-1 do put_dst($ff);

           end else
            save_hea;

           adres:=idx;

           if mne.l<>__blkEmp then org:=true;
         end;


         if (idx>=0) and (idx<=$FFFF) then
          first_org:=false
         else
          blad(zm,0);    // !!! koniecznie blad(zm,0) !!! w celu akceptacji
                         // ORG-ów <0 w poczatkowych przebiegach asemblacji

         ety:='';
        end;


(*----------------------------------------------------------------------------*)
(*  .PUT [index] = VALUE,...                                                  *)
(*----------------------------------------------------------------------------*)
   __put:
     if ety<>'' then blad(zm,38) else
      if macro_rept_if_test then begin

       omin_spacje(i,zm);     

       put_used:=true;

       blocked := true;
       get_data_array(i,zm,$FFFF,1);
       blocked := false;

       put_used:=false;
      end;


(*----------------------------------------------------------------------------*)
(*  .SAV [index] ['file'],length                                                *)
(*----------------------------------------------------------------------------*)
   __sav:
//    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then begin

       save_lab(ety,adres,bank,zm);

       save_lst(zm,'a');

       idx_get:=0;

       omin_spacje(i,zm);

       if zm[i] in ['[','('] then begin
        txt:=ciag_ograniczony(i,zm,true);
        k:=1; idx_get:=integer( ___wartosc_noSPC(txt,zm,k,#0,'A') );
       end;

       txt:=get_string(i,zm,zm,false);

       omin_spacje(i,zm);

       if txt<>'' then
        if zm[i]=',' then __inc(i,zm) else blad(zm,23);

       _doo:=integer( ___wartosc_noSPC(zm,zm,i,',','A') );

       _odd:=idx_get+_doo;      
       testRange(zm, _odd, 62); //subrange_bounds(zm,idx_get+_doo,$FFFF);

       test_eol(i,zm,zm,#0);

       if txt<>'' then begin
         txt:=GetFile(txt,zm);

         if pass=pass_end then begin
           AccessFile(txt); AssignFile(g, txt); FileMode:=1; Rewrite(g,1);
           blockwrite(g,t_get[idx_get],_doo);
           closefile(g);
         end;

       end else begin

         if (pass=pass_end) and (_doo>0) then
          for idx:=0 to _doo-1 do save_dst(t_get[idx_get+idx]);

         inc(adres,_doo);
       end;

       ety:='';
      end;


(*----------------------------------------------------------------------------*)
(*  .PAGES                                                                    *)
(*----------------------------------------------------------------------------*)
   __pages:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then
      if adres<0 then blad(zm,10) else begin

       save_lst(zm,'a');

       war:=1;
       txt:=get_dat_noSPC(i,zm,' ',#0,zm);

       if txt<>'' then begin
        k:=1; war:=___wartosc_noSPC(txt,zm,k,#0,'A');   // dopuszczalny zakres wartosci to .WORD

        k:=integer(war);
        testRange(zm, k, 0);
       end;

       t_pag[pag_idx].adr:= integer(adres and $7FFFFF00);
       t_pag[pag_idx].cnt:= integer(war) shl 8;

       inc(pag_idx);
       if pag_idx>High(t_pag) then SetLength(t_pag,pag_idx+1);

       save_end(__endpg);

//       ety:='';
      end;


(*----------------------------------------------------------------------------*)
(*  .ENDPG                                                                    *)
(*----------------------------------------------------------------------------*)
   __endpg:
    if ety<>'' then blad(zm,38) else 
     if macro_rept_if_test then
      if pag_idx=0 then blad(zm,64) else begin

       save_lst(zm,'a');

       dec(pag_idx);

       _odd := t_pag[pag_idx].adr;
       _doo := (adres-1) and $7FFFFF00;

       if pass=pass_end then
        if (_doo-_odd) >= t_pag[pag_idx].cnt then warning(70);

//       dec(end_idx);
       dec_end(zm,__endpg);
       
//       ety:='';
      end;
      

(*----------------------------------------------------------------------------*)
(*  .RELOC                                                                    *)
(*----------------------------------------------------------------------------*)
   __reloc:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then
      if (adres>=0) and not(dreloc.use) then blad(zm,83) else begin

       inc(bank);
       if bank>=__id_param then blad(zm,45);

       test_wyjscia(zm,false);

       save_hea;

       if dreloc.use then begin
        rel_idx:=0; ext_idx:=0; extn_idx:=0; skip.idx:=0; pub_idx:=0;
        smb_idx:=0; sym_idx:=0;
        ext_used.use:=false; rel_used:=false; blocked:=false;
        blkupd.adr:=false; blkupd.ext:=false; blkupd.pub:=false;
        blkupd.sym:=false; blkupd.new:=false;
       end;

       save_lst(zm,' ');

       k:=get_type(i,zm,false);

       if k=1 then
        rel_ofs := __rel
       else
        rel_ofs := __relASM;

       dreloc.use:=true;
       adres:=rel_ofs;

       first_org:=false;
       org:=true;

       save_dstW( __relHea );      // dodatkowy naglowek bloku relokowalnego 'MR'
       save_dstW( rel_ofs );       // informacja o rodzaju bloku .WORD (bit0)

     // zapisujemy wartosci etykiet dla stosu programowego
       indeks:=adr_label(0,false);  save_dstW( indeks );  // @stack_pointer
       indeks:=adr_label(1,false);  save_dstW( indeks );  // @stack_address
       indeks:=adr_label(2,false);  save_dstW( indeks );  // @proc_vars_adr

      end;


(*----------------------------------------------------------------------------*)
(*  .LINK 'filename'                                                          *)
(*  pozwala dolaczyc kod relokowalny tzn. pliki DOS o adresie $0000           *)
(*----------------------------------------------------------------------------*)
   __link:
//    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then
      if dreloc.use then blad(zm,57) else begin

       save_lab(ety,adres,bank,zm);

//       save_lst(zm,'a');

//       omin_spacje(i,zm);
       txt:=get_string(i,zm,zm,true);

       txt:=GetFile(txt,zm);   if not(TestFile(txt)) then blad(txt,18);
       test_eol(i,zm,zm,#0);

       AssignFile(g, txt); FileMode:=0; Reset(g,1);

     // sprawdzamy czy wczytujemy plik DOS'a (pierwsze dwa bajty pliku = __HEA_DOS)
       t_lnk[0]:=0;
       t_lnk[1]:=0;

       blockread(g,t_lnk,2);
       if (t_lnk[0]+t_lnk[1] shl 8)<>__hea_dos then blad(zm,74);

       Reset(g,1);
       blockread(g,t_lnk,sizeof(t_lnk),IDX); // wczytujemy caly plik do T_LNK o dlugosci IDX

// w glownej petli uzywamy zmiennych IDX, K, _ODD

 _odd:=0; dlink.use:=false; dlink.len:=0; dlink.emp:=0;

 while _odd<idx do begin

        j:=fgetW(_odd);
        if j=$FFFF then j:=fgetW(_odd);


        case j of

 // blk RELOC
 __hea_reloc:
   begin

       if dlink.use then flush_link(zm);

       k:=fgetW(_odd);              // odczytujemy dlugosc pliku relokowalnego
       inc(k);                      // zwiekszamy o 1
//       subrange_bounds(zm,k,$FFFF); // maksymalna dlugosc pliku $FFFF
       testRange(zm,k,62);

       j:=fgetW(_odd);              // odczytujemy 2 bajty z dodatkowego naglowka 'MR'
       if j<>__relHea then blad(zm,74);
(*----------------------------------------------------------------------------*)
(* bajt 0 - nieuzywany                                                        *)
(* bajt 1 - bit 0     kod strony zerowej (0), kod poza strona zerowa (1)      *)
(*          bit 1..7  nieuzywne                                               *)
(*----------------------------------------------------------------------------*)
       fgetB(_odd);                 // odczytujemy 2 bajty z informacja o pliku .RELOC
       v:=fgetB(_odd);

       if (v=0) and (adres>$FF) then blad(zm,76);

       __link_stack_pointer_old := fgetW(_odd);       // @stack_pointer
       __link_stack_address_old := fgetW(_odd);       // @stack_address
       __link_proc_vars_adr_old := fgetW(_odd);       // @proc_vars_adr

       if pass=0 then begin

        if dlink.stc then
         if (__link_stack_pointer_old<>__link_stack_pointer) or
            (__link_stack_address_old<>__link_stack_address) or
            (__link_proc_vars_adr_old<>__link_proc_vars_adr) then warning(75);

        if not(dlink.stc) then begin
         __link_stack_pointer := __link_stack_pointer_old;
         __link_stack_address := __link_stack_address_old;
         __link_proc_vars_adr := __link_proc_vars_adr_old;

         txt:=mads_stack[0]; save_fake_label(txt,zm,__link_stack_pointer); //@stack_pointer
         txt:=mads_stack[1]; save_fake_label(txt,zm,__link_stack_address); //@stack_address
         txt:=mads_stack[2]; save_fake_label(txt,zm,__link_proc_vars_adr); //@proc_vars_adr
        end;

       end;

       move(t_lnk[_odd],t_ins,k);      // wczytujemy blok relokowalny do T_INS
       inc(_odd,k);

       dlink.len:=k; dlink.use:=true; dlink.stc:=true;
   end;

      // BLK UPDATE ADDRESS
         __hea_address:
                begin
                 ch := chr( fgetB(_odd) );
                 j  := fgetW(_odd);

                 while j>0 do begin

                  idx_get:=fgetW(_odd);

                  tst:=adres;

                  case ch of

                   'E': begin                     // pusty blok rezerwujacy pamiec
                         dlink.emp := idx_get;
                        end;

                   '<','B':
                        begin
                         inc(tst, t_ins[idx_get]);

                         t_ins[idx_get]  := byte(tst);
                        end;

                   '>': begin
                         inc(tst, t_ins[idx_get] shl 8);

                         v:=fgetB(_odd);    // dodatkowy bajt dla relokacji starszych adresow

                         inc(tst,v);

                         t_ins[idx_get]  := byte(tst shr 8);
                        end;

                   'W': begin
                         inc(tst, t_ins[idx_get]);
                         inc(tst, t_ins[idx_get+1] shl 8);

                         t_ins[idx_get]  := byte(tst);
                         t_ins[idx_get+1]:= byte(tst shr 8);
                        end;

                   'L': begin
                         inc(tst, t_ins[idx_get]);
                         inc(tst, t_ins[idx_get+1] shl 8);
                         inc(tst, t_ins[idx_get+2] shl 16);

                         t_ins[idx_get]  := byte(tst);
                         t_ins[idx_get+1]:= byte(tst shr 8);
                         t_ins[idx_get+2]:= byte(tst shr 16);
                        end;

                   'D': begin
                         inc(tst, t_ins[idx_get]);
                         inc(tst, t_ins[idx_get+1] shl 8);
                         inc(tst, t_ins[idx_get+2] shl 16);
                         inc(tst, t_ins[idx_get+3] shl 24);

                         t_ins[idx_get]  := byte(tst);
                         t_ins[idx_get+1]:= byte(tst shr 8);
                         t_ins[idx_get+2]:= byte(tst shr 16);
                         t_ins[idx_get+3]:= byte(tst shr 24);
                        end;

                  end;

                  dec(j);
                 end;

                end;

      // BLK UPDATE EXTERNAL
         __hea_external:
                begin
                 ch := chr ( fgetB(_odd) );
                 j  := fgetW(_odd);

                 txt:=fgetS(_odd);           // label_ext name

                 idx_get:=load_lab(txt,false);
                 if idx_get<0 then begin
                  war:=0;
                  if pass=pass_end then blad_und(zm,txt,73);
                 end else
                  war:=oblicz_wartosc(txt,zm);

                 v:=ord(value_code(war,zm,true));

              // sprawdzamy czy zgadza sie typ etykiety
                 if pass=pass_end then
                  case ch of
                   'B': if chr(v)<>'Z' then blad_und(zm,txt,41);
                   'W': if not(chr(v) in ['Z','Q']) then blad_und(zm,txt,41);
                   'L': if not(chr(v) in ['Z','Q','T']) then blad_und(zm,txt,41);
                  end;


                 while j>0 do begin
                  idx_get:=fgetW(_odd);

                  tst:=word(war);

                  case ch of
                    'B': begin
                          inc(tst, t_ins[idx_get]);

                          t_ins[idx_get]  := byte(tst);
                         end;

                    'W': begin
                          inc(tst, t_ins[idx_get]);
                          inc(tst, t_ins[idx_get+1] shl 8);

                          t_ins[idx_get]  := byte(tst);
                          t_ins[idx_get+1]:= byte(tst shr 8);
                         end;

                    'L': begin
                          inc(tst, t_ins[idx_get]);
                          inc(tst, t_ins[idx_get+1] shl 8);
                          inc(tst, t_ins[idx_get+2] shl 16);

                          t_ins[idx_get]  := byte(tst);
                          t_ins[idx_get+1]:= byte(tst shr 8);
                          t_ins[idx_get+2]:= byte(tst shr 16);
                         end;

                    'D': begin
                          inc(tst, t_ins[idx_get]);
                          inc(tst, t_ins[idx_get+1] shl 8);
                          inc(tst, t_ins[idx_get+2] shl 16);
                          inc(tst, t_ins[idx_get+3] shl 24);

                          t_ins[idx_get]  := byte(tst);
                          t_ins[idx_get+1]:= byte(tst shr 8);
                          t_ins[idx_get+2]:= byte(tst shr 16);
                          t_ins[idx_get+3]:= byte(tst shr 24);
                         end;

                  end;

                  dec(j);
                 end;

                end;


      // BLK UPDATE PUBLIC
         __hea_public:
                begin
                 j:=fgetW(_odd);

                  while j>0 do begin

                   typ:= chr ( fgetB(_odd) );  // TYPE   B-YTE, W-ORD, L-ONG, D-WORD

                   ch := chr ( fgetB(_odd) );  // LABEL_TYPE   V-ARIABLE, P-ROCEDURE, C-ONSTANT

                   if dlink.use then tst:=adres else tst:=0;

                   case ch of
                    'P': begin
                          str:=fgetS(_odd);               // label_pub name

                          inc(tst, fgetW(_odd));          // adres procedury

                          r:=fgetB(_odd);                 // kolejnosc rejestrow CPU

                          rodzaj:=chr(fgetB(_odd));       // typ procedury

                          if not(rodzaj in [__pDef, __pReg, __pVar]) then blad_und(zm,str,41);


                          idx_get:=fgetW(_odd);           // liczba danych na temat parametrow

                          if pass=0 then begin

                           _doo:=_odd+idx_get;

                           txt:='(';
                           while _odd<_doo do begin

                             v:=fgetB(_odd);              // typ parametru
                             v:=TypeToByte( chr( v ) );   // liczba bajtow przypadajaca na parametr

                             txt:=txt+mads_param[v];

                             case rodzaj of               // parametr jesli trzeba
                              __pDef: tmp:='par'+IntToStr(_odd);

                              __pReg: begin
                                       tmp:='';
                                       while v<>0 do begin
                                        tmp:=tmp+ByteToReg(r);
                                        dec(v)
                                       end;
                                      end;

                              __pVar: tmp:=fgetS(_odd);
                             end;

                             txt:=txt+tmp+' ';
                           end;

                           txt:=txt+')';

                           case rodzaj of
                            __pReg: txt:=txt+' .REG';
                            __pVar: txt:=txt+' .VAR';
                           end;

                           i:=1;
                           get_procedure(str,str,txt,i);    // odczytujemy parametry

                           proc:=false;                     // koniecznie wylaczamy PROC
                           proc_name:='';                   // i koniecznie PROC_NAME := ''

                          end else inc(_odd,idx_get);       // koniecznie zwiekszamy _ODD gdy PASS<>0

                          upd_procedure(str,zm,tst);

                          proc:=false;           // koniecznie wylaczamy PROC
                          proc_name:='';         // i koniecznie PROC_NAME = ''

                          add_proc_nr;           // zwiekszamy koniecznie numer procedury
                         end;

               'V': begin
                      str:=fgetS(_odd);

                      _doo:= fgetW(_odd);

                      inc(tst, _doo);                  // nowy adres etykiety

                      save_lab(str,tst,bank,zm);       // variable
                     end;

               'C': begin
                      str:=fgetS(_odd);

                      case typ of
                       'B': vtmp:=fgetB(_odd);
                       'W': vtmp:=fgetW(_odd);
                       'L': vtmp:=fgetL(_odd);
                       'D': vtmp:=fgetD(_odd);
                      end;

                      save_lab(str,vtmp,bank,zm);      // constant
                    end;

                   end;


                   dec(j);
                  end;

                 end;
        else

   begin
     flush_link(zm);

     k:=fgetW(_odd);              // odczytujemy dlugosc pliku relokowalnego
     inc(k);                      // zwiekszamy o 1
//     subrange_bounds(zm,k,$FFFF); // maksymalna dlugosc pliku $FFFF
     testRange(zm,k, 62);

     save_hea;
     adres:=j; org:=true;

     dlink.len:=k-j;

     move(t_lnk[_odd],t_ins,dlink.len);      // wczytujemy blok relokowalny do T_INS
     inc(_odd,dlink.len);
   end;

        end;



 end;

       flush_link(zm);

       closefile(g);

       ety:='';
      end;


(*----------------------------------------------------------------------------*)
(*  .PUBLIC label [,label2,label3...]                                         *)
(*----------------------------------------------------------------------------*)
   __public:
    if ety<>'' then blad(zm,38) else
     if macro_rept_if_test then begin

       save_lst(zm,' ');

       omin_spacje(i,zm);

       while not(test_char(i,zm,#0,#0)) do begin

        txt:=get_lab(i,zm, true);

        save_pub(txt,zm);

//        omin_spacje(i,zm);
//        if zm[i]<>',' then Break else __inc(i,zm);
        __next(i,zm);

       end;

      end;


(*----------------------------------------------------------------------------*)
(*  .SYMBOL label                                                             *)
(*----------------------------------------------------------------------------*)
 __symbol:
    if macro_rept_if_test then
     if not(dreloc.sdx) then blad(zm,53) else begin

       if ety='' then ety:=get_lab(i,zm, true);

       save_lst(zm,' ');

       if ety<>'' then save_sym(ety);
     end;

      
(*----------------------------------------------------------------------------*)
(*  INS 'filename' [+-expression] [,length[,offset]]                          *)
(*  .GET [index] 'filename' [+-expression] [,length[,offset]]                 *)
(*----------------------------------------------------------------------------*)
   __ins,__get:
     if macro_rept_if_test then
//      if loop_used then blad(zm,36) else       
       if first_org and (opt and 1>0) and (mne.l=__ins) then blad(zm,10) else begin

         data_out:=true;

         idx_get:=0;

         omin_spacje(i,zm);

         if mne.l=__get then
          if zm[i] in ['[','('] then begin
           txt:=ciag_ograniczony(i,zm,true);
           k:=1; idx_get:=integer( ___wartosc_noSPC(txt,zm,k,#0,'A') );
          end;

//         omin_spacje(i,zm);
         txt:=get_string(i,zm,zm,true); 

         txt:=GetFile(txt,zm);   if not(TestFile(txt)) then blad(txt,18);

         if (GetFileName(txt)=GetFileName(a)) or (GetFileName(txt)=GetFileName(plik_asm)) then blad(txt,18);

         AssignFile(g, txt); FileMode:=0; Reset(g,1);

         k:=integer(FileSize(g)); _odd:=0; _doo:=k;

         v:=byte( test_string(i,zm,'B') );

         if zm[i]=',' then begin
          __inc(i,zm);

          _odd:=integer( ___wartosc_noSPC(zm,zm,i,',','A') );

          if _odd<0 then begin
           _doo:=abs(_odd); _odd:=k+_odd;
          end else _doo:=k-abs(_odd);

          if zm[i]=',' then begin
           __inc(i,zm);

           _doo:=integer( ___wartosc_noSPC(zm,zm,i,',','A') );
           testRange(zm, _doo, 13);

           test_eol(i,zm,zm,#0);
          end;
         end else test_eol(i,zm,zm,#0);

        // sprawdz czy nie zostala przekroczona dlugosc pliku
         if (abs(_odd)>k) or (abs(_odd)+abs(_doo)>k) then blad(zm,24);
         k:=_doo;

        // maksymalna dlugosc pliku to 64kB
         testRange(zm,k, 25); //if k>$FFFF then blad(zm,25);

         save_lst(zm,'a');

         if mne.l=__get then begin           // .GET

           j:=idx_get+_doo;
           testRange(zm, j, 62);  // subrange_bounds(zm,idx_get+_doo,$FFFF+1);

           if _odd>0 then seek(g,_odd);      // omin _ODD bajtow w pliku
           blockread(g,t_get[idx_get],_doo); // odczytaj _DOO bajtow od indeksu [IDX_GET]

         end else                            // INS
         if (pass=pass_end) and (_doo>0) then begin

//           if opt and 1=0 then first_org := true;

           if _odd>0 then seek(g,_odd);      // omin _ODD bajtow w pliku
           blockread(g,t_ins,_doo);          // odczytaj _DOO bajtow

           for idx:=0 to _doo-1 do save_dst( byte( t_ins[idx]+v ) );
         end;

         closefile(g);

         save_lab(ety,adres,bank,zm);

         if mne.l<>__get then inc(adres, k);
         ety:='';
        end;


(*----------------------------------------------------------------------------*)
(*  END                                                                       *)
(*----------------------------------------------------------------------------*)
   __end, __en:
        if loop_used then blad(zm,36) else begin

          end_file:=true;

          save_lab(ety,adres,bank,zm);

          save_lst(zm,'a');

          mne.l:=0;
          ety:='';
        end;


(*----------------------------------------------------------------------------*)
(*  DTA [abefgtcd] 'string',expression...                                     *)
(*  lub dodajemy nowe pola do struktury  .STRUCT                              *)
(*----------------------------------------------------------------------------*)
   __dta,__byte..__dword:
        if macro_rept_if_test then
         if first_org and (opt and 1>0) and not(struct) then blad(zm,10) else begin

          if struct then begin                  // zapisujemy pola struktury

            if ety='' then blad(zm,15);         // pola struktury musza posiadac etykiety
            if mne.l=__dta then blad(zm,58);    // przyjmujemy tylko nazwy typow

            j:=mne.l-__byteValue;                  // J = <1..4>
            k:=adres-struct_adres;

            save_str(ety,k,j,rpt,adres,bank);
            save_lab(ety,k,bank,zm);

            nul.i:=k;
            save_lst(zm,'l');

            if loop_used then begin
             loop_used:=false;
             j := j*rpt;
            end;

            inc(adres, j);

            inc(struct_cnt);                    // zwiekszamy licznik pol struktury

            ety:='';

          end else begin            // tutaj tworzymy dane typu strukturalnego
                                    // wystapilo DTA STRUCT_NAME [EXPRESSION]
           struct_used.use:=false;

           _odd:=adres; war:=adres;
           _doo:=bank; k:=bank;

           save_lst(zm,'a');

           v := mne.l;

           if v>=__byte then
            //v:=v-__byteValue
            dec(v, __byteValue)
           else 
            v:=1;

           test_skipa;

           oblicz_dane(i,zm,zm,v);

       // jesli stworzylismy strukture to odpowiednio zapamietaj
       // jej dane, adres, stworzyciela itp.
           if struct_used.use then begin

            if ety='' then blad(zm,15);


            idx:=load_lab(ety,true);  


       // jesli etykieta byla juz zadeklarowana i to jest PASS=0
       // tzn ze mamy blad LABEL DECLARED TWICE
            if (pass=0) and (idx>=0) then blad_und(zm,ety,2);


            _doo:=__dta_struct;

            if t_lab[idx].bnk=__dta_struct then begin
         // wystapila juz ta deklaracja danych strukturalnych
             _odd:=t_lab[idx].adr;

             t_str[_odd].adr := cardinal( war );
             t_str[_odd].bnk := word( k );

            end else begin

         // w TMP tworzymy nazwe uwzgledniaj¹c¹ lokalnosc 'TMP:= ??? + ETY'
             if run_macro then tmp:=macro_nr+{lokal_name+}ety else
              if proc then tmp:=proc_name+lokal_name+ety else
               tmp:=lokal_name+ety;

         // nie wystapila jeszcze ta deklaracja danych strukturalnych
             save_str(tmp,struct_used.cnt,0,1, integer(war), word(k));

             _odd:=loa_str(tmp, struct_id);

             t_str[_odd].idx:=struct_used.idx;
            end;

           end;

           save_lab(ety,cardinal(_odd),word(_doo),zm);     // zapisujemy etykiete normalnie poza struktur¹
          end;

          ety:='';
         end;

         
(*----------------------------------------------------------------------------*)
(*  ICL 'filename'                                                            *)
(*----------------------------------------------------------------------------*)
   __icl:
       if macro_rept_if_test then
        if loop_used then blad(zm,36) else begin

          save_lab(ety,adres,bank,zm);
          save_lst(zm,'a');

          txt:=get_string(i,zm,zm,true); 

          txt:=GetFile(txt,zm);  if not(TestFile(txt)) then blad(txt,18);
          test_eol(i,zm,zm,#0);

          if (GetFileName(txt)=GetFileName(a)) or (GetFileName(txt)=GetFileName(plik_asm)) then blad(txt,18);

        // sprawdzamy czy jest to plik tekstowy w pierwszych dwóch przebiegach asemblacji
          if pass<2 then begin
           assignfile(txtFile,txt); Reset(txtFile);
           readln(txtFile,tmp);
           CloseFile(txtFile);
           if pos(#0,tmp)>0 then blad(zm,74);
          end;

          str:=zm; zapisz_lst(str);

          old_icl_used := icl_used;
          icl_used:=true;

          analizuj_plik__(txt,zm);

          bez_lst:=true;
//          put_lst(show_full_name(a,full_name,true),'');
          global_name:=a;

          line:=nr;

          icl_used := old_icl_used;

          ety:='';
          mne.l:=0;
         end;

  end;


 // zapamietanie etykiety jesli wystapila
 // i zapisanie zdekodowanych rozkazow
  if if_test then begin

   if ety<>'' then begin

    //if mne.l<>0 then
    if mne_used then
     label_type:='V'
    else
     label_type:='C';

    if pass=pass_end then
     if adres<0 then warning(10);

     save_lab(ety,adres,bank,zm);   // pozostale etykiety bez zmian

    save_lst(zm,'a');
   end;

   if mne.l<__equ then begin
    nul:=mne;
    if (mne.l=0) and (ety='') then save_lst(zm,' ') else save_lst(zm,'a');
    nul.l:=0;
   end;

  end;


 // zapisz wynik asemblacji do pliku LST

  if not(loop_used) and not(FOX_ripit) then begin

   if not(bez_lst) then zapisz_lst(zm);

   bez_lst:=false;
 end;

end;


procedure get_linia(var zm:string; var end_file,ok:Boolean; var _odd,_doo:integer);
(*----------------------------------------------------------------------------*)
(*  pobieramy linie i sprawdzamy czy linia nie jest komentarzem               *)
(*----------------------------------------------------------------------------*)
var i, j: integer;
    str: string;
begin
   if end_file then exit;

    noWarning:=false;

    if pos('\',zm)>0 then begin       // test na obecnosc znaku '\'
     i:=1;
     str:=get_dat(i,zm,'\',false);

     if zm[i]='\' then begin
       save_lst(zm,';');

       _odd:=High(t_lin);
       i:=1;
       while true do begin
        str:=get_dat(i,zm,'\',false);
        save_lin(str);
        if zm[i]='\' then inc(i) else Break;
       end;

       _doo:=High(t_lin);

       lst_off:=true;

       ok:=false;
       exit;
     end;

    end;


   i:=1;

   if zm<>'' then begin
    omin_spacje(i,zm);

    if not((zm[i] in [';','*','/','|']) or komentarz) then ok:=true;

    if (zm[i]='/') and (zm[i+1]='*') then begin
     komentarz:=true; inc(i,2);
    end;

     if komentarz then begin
      omin_spacje(i,zm);     // szukamy znakow konczacych komentarz wieloliniowy */
      j:=i;

      if zm[j]='*' then begin
        while zm[j]='*' do __inc(j,zm);
        if zm[j]='/' then komentarz:=false;
      end else begin
        str:=get_dat_noSPC(j,zm,'*',#0,zm);
        while str<>'' do str:=get_dat_noSPC(j,zm,'*',#0,zm);
        if (zm[j]='*') and (zm[j+1]='/') then komentarz:=false;
      end;

     end;

   end;

 omin_spacje(i,zm);

 if i>length(zm) then ok:=false;


 if not(macro) and not(rept) and not(run_macro) and not(rept_run) then
  if (zm='') or not(ok) then begin
   save_lst(zm,';'); put_lst(t);
   ok:=false;
  end;

end;


procedure analizuj_plik(var a:string; old_str: string);
(*----------------------------------------------------------------------------*)
(*  odczyt pliku ASM wiersz po wierszu                                        *)
(*----------------------------------------------------------------------------*)
var f: textfile;
    rept_nr, rept_ile, nr, _odd, _doo: integer;
    end_file, ok, wyjscie: Boolean;
    zm: string;
begin
 if not(TestFile(a)) then blad(a,18);

 AssignFile(f,a); FileMode:=0; Reset(f);

 _odd:=0; _doo:=0; rept_ile:=0; rept_nr:=0;
 nr:=0;                        // nr linii w asemblowanym pliku
 global_name:=a;               // nazwa pliku dla funkcji 'BLAD'
 end_file:=false;              // czy napotkal rozkaz 'END'
 wyjscie:=false;               // czy wystapilo EXIT w makrze

 // nazwe pierwszego pliku zawsze zapisze do LST
 // pod warunkiem ze (opt and 4>0) czyli wystapilo OPT L+
 if (opt and 4>0) then
  if (pass=pass_end) and (a[2]=':') then
   writeln(lst,show_full_name(global_name,true,true))
  else
   put_lst(show_full_name(global_name,full_name,true));


 while (not eof(f)) or (_doo>0) do begin

  ok:=false;

  if _doo>0 then begin
   zm:=t_lin[_odd];   
   inc(_odd);
   if _odd>=_doo then begin _doo:=0; lst_off:=false; end;
  end else begin
   readln(f,zm);

   if length(zm)>$FFFF then begin blad(zm,101); koniec(2) end;

   inc(nr); line:=nr; inc(line_all); 
  end;


  get_linia(zm,end_file,ok,_odd,_doo);


  if macro then dirMACRO(zm) else       // aby poprawnie obliczal linie z bledem 
   if ok then
    if rept then dirREPT(zm,a,old_str,rept_nr,rept_ile,nr) else
     if not(komentarz) then
      analizuj_linie(zm,a,old_str, rept_nr,rept_ile, nr, end_file,wyjscie);

  if end_file then Break;

 end;

 test_skipa;
 if skip.use then blad(zm,84);             // Can't skip over this

 
 oddaj_var;

 oddaj_ds;


 if pass=pass_end then
 if (a=plik_asm) {and not(first_org)} then   // wymuszamy BLK UPDATE na koncu glownego pliku
  if dreloc.use or dreloc.sdx then begin

   save_lst(zm,'a');
   if not(blkupd.adr) then begin zm:=load_mes(91)+load_mes(92); blk_update_address(zm) end;
   save_lst(zm,'a');
   if not(blkupd.ext) then begin zm:=load_mes(91)+load_mes(93); blk_update_external(zm) end;
   save_lst(zm,'a');
   if not(blkupd.pub) then begin zm:=load_mes(91)+load_mes(94); blk_update_public(zm) end;
   save_lst(zm,'a');
   if not(blkupd.sym) then begin zm:=load_mes(91)+load_mes(95); blk_update_symbol(zm) end;
   save_lst(zm,'a');

   oddaj_sym;

  end;


 test_wyjscia(zm,wyjscie);

 closefile(f);
end;



procedure analizuj_mem(var start,koniec:integer; var old,a,old_str:string; const p_max:integer; const rp:Boolean);
(*----------------------------------------------------------------------------*)
(*  odczyt i analiza wierszy zapisanych w tablicy dynamicznej T_MAC           *)
(*  P_MAX okresla liczbe powtorzen                                            *)
(*----------------------------------------------------------------------------*)
var rept_ile, rept_nr, licznik, nr, licz, _odd, _doo: integer;
    end_file, ok, wyjscie, old_icl_used: Boolean;
    zm: string;
begin

      old_icl_used := icl_used;
      icl_used     := true;

 _odd:=0; _doo:=0; rept_ile:=0; rept_nr:=0;

 licz := 0;
 while licz < p_max do begin

 if rp or FOX_ripit then ___rept_ile := licz;

 licznik:=start;

 nr:=line_add;                 // nr linii w asemblowanym pliku
 end_file:=false;              // czy napotkal rozkaz 'END'
 wyjscie:=false;               // czy wystapilo EXIT w makrze

 while (licznik<koniec) or (_doo>0) do begin

  ok:=false;

  if _doo>0 then begin
   zm:=t_lin[_odd];      
   inc(_odd);
   if _odd>=_doo then begin _doo:=0; lst_off:=false end;
  end else begin
   zm:=t_mac[licznik]; inc(licznik);
   inc(nr); line:=nr; inc(line_all);
  end;


  get_linia(zm,end_file,ok, _odd,_doo);


  if ok then
   if rept then dirREPT(zm,a,old_str,rept_nr,rept_ile,nr) else
    if not(end_file) and not(komentarz) then
     analizuj_linie(zm,a,old_str, rept_nr,rept_ile, nr, end_file,wyjscie);


  if wyjscie then Break;          // zakonczenie przetwarzania makra przez dyrektywe .EXIT

 end;

 test_wyjscia(old,wyjscie);
 inc(licz); 
 end;

      icl_used      := old_icl_used;
end;



procedure asem(var a:string);
(*----------------------------------------------------------------------------*)
(*  asemblacja glownego pliku *.ASM                                           *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 while (pass<=pass_end) and (pass<16) do begin   // maksymalnie 16 przebiegow

  line_all:=0;


  analizuj_plik(a,'');

  if list_mac then analizuj_plik(plik_mac,' icl '''+plik_mac+'''');

  t_hea[hea_i]:=adres-1;            // koniec programu, ostatni wpis

  inc(pass);

 // jesli NEXT_PASS = TRUE to zwieksz liczbe przebiegow
  if (pass=pass_end) or (pass<1) then
   if next_pass then inc(pass_end);

 // wyzeruj numer wywolania makra
  for i:=High(t_lab)-1 downto 0 do
   if t_lab[i].bnk=__id_macro then t_mac[ t_lab[i].adr + 3 ] := '0';

  label_type:='V';

  adres:=-$FFFF; raw.old:=-$FFFF;

  hea_ofs.adr:=-1; struct_cnt:=-1;

  hea_i:=0; bank:=0; ifelse:=0; blok:=0; rel_ofs:=0; org_ofset:=0;
  proc_nr:=0; lokal_nr:=0; lc_nr:=0;
  line_add:=0; struct_id:=0; wyw_idx:=0; rel_idx:=0;
  ext_idx:=0; extn_idx:=0; skip.idx:=0; smb_idx:=0; sym_idx:=0;
  pag_idx:=0; end_idx:=0; var_idx:=0; pub_idx:=0; usi_idx:=0;
  whi_idx:=0; while_nr:=0; ora_nr:=0; test_nr:=0;
  test_idx:=0; var_id:=0; proc_lokal:=0;  

  __link_stack_pointer := adr_label(0,false);       // @STACK_POINTER
  __link_stack_address := adr_label(1,false);       // @STACK_ADDRESS
  __link_proc_vars_adr := adr_label(2,false);       // @PROC_VARS_ADR


  siz_idx:=1; 

  opt := optdef;

  hea:=true; first_org:=true; if_test:=true;

  loop_used:=false; macro:=false; proc:=false;
  else_used:=false; elseif_used:=false;
  icl_used:=false; bez_lst:=false; empty:=false;
  reloc:=false; branch:=false; vector:=false; rept:=false;
  rept_run:=false; struct:=false; dta_used:=false;
  struct_used.use:=false; aray:=false; next_pass:=false;
  mne_used:=false; skip.use:=false; skip.xsm:=false; FOX_ripit:=false;
  put_used:=false; ext_used.use:=false; dreloc.use:=false;
  rel_used:=false; blocked:=false; dlink.stc:=false;
  blokuj_zapis:=false; overflow:=false; test_symbols:=false;
  lst_off:=false; noWarning:=false; raw.use:=false; variable:=false;

  komentarz:=false;

  lokal_name:=''; macro_nr:=''; str_blad:=''; while_name:=''; test_name:='';

  if binary_file.use then begin
   adres     := binary_file.adr;
   org       := true;
   first_org := false;
  end;
 
//  SetLength(t_loc,1);
//  SetLength(t_wyw,1);
//  SetLength(t_rel,1);
//  SetLength(t_smb,1);
 end;


 // jesli nie wystapil zaden blad i mamy 16 przebiegow to na pewno nastapila petla bez konca

 if (status and 2=0) and (pass=16) then begin
  writeln(#13#10'Infinite loop !!!');
  koniec(2);
 end;

end;


procedure Syntax;
(*----------------------------------------------------------------------------*)
(*  wyswietlamy informacje na temat przelacznikow, konfiguracji MADS'a        *)
(*----------------------------------------------------------------------------*)
begin
 Writeln(load_mes(111+1));
 halt(4);
end;


function NewFileExt(nam:string; const n: byte): string;
var b: string;
const
 extension: array [0..6] of string[3]=
 ('lst','obx','lab','mac','h','asm','hea');
    
begin

 b:=extension[n];
 Result:=nam+'.'+b;

 if name<>'' then begin
  obetnij_kropke(nam);
  Result:=nam+b;
 end;

end;


function nowy_plik(var a: string; var i:integer): string;
begin
 Result:=a;

 inc(i,2);                          // omijamy znak przelacznika i znak ':'

 name:=copy(t,i,length(t));

 if GetFilePath(name)<>'' then path:=GetFilePath(name);

 if name<>'' then Result:=path+GetFileName(name);

 inc(i,length(name));
end;


procedure INITIALIZE;
(*----------------------------------------------------------------------------*)
(*  procedura obliczajaca tablice CRC16, CRC32, mniej miejsca zajmuje anizeli *)
(*  gotowa predefiniowana tablica                                             *)
(*----------------------------------------------------------------------------*)
var IORes, _i: integer;
    x, y: word;
    crc: cardinal;
    crc_: Int64;
    tmp: string;

const
 // HASH_VAL i HASH_OFS wylicza osobny program
 // nie trzeba przechowywac w pamieci stringow z nazwami
 hash_val: array [0..260] of byte=(
 $56,$01,$58,$42,$1E,$1F,$59,$3E,$0E,$86,$A0,$04,
 $9E,$9E,$29,$2A,$98,$98,$43,$48,$8D,$89,$8C,$93,
 $97,$3C,$CA,$3D,$D3,$9D,$0A,$33,$9F,$9B,$9B,$07,
 $50,$12,$22,$18,$13,$51,$36,$9F,$9B,$9B,$4E,$9D,
 $9C,$24,$44,$1B,$49,$08,$85,$9C,$97,$BC,$57,$63,
 $32,$9F,$9B,$9B,$A2,$63,$A2,$65,$83,$B9,$B6,$68,
 $CD,$54,$23,$19,$AA,$31,$9F,$9B,$9B,$8A,$67,$20,
 $AC,$6B,$45,$94,$17,$A6,$87,$9C,$9C,$15,$30,$97,
 $9F,$9B,$9B,$09,$4C,$55,$BF,$C6,$61,$C2,$88,$40,
 $C3,$70,$3B,$3A,$1C,$1D,$0F,$0C,$3F,$BE,$2F,$4D,
 $41,$35,$9F,$9B,$9B,$A5,$99,$99,$14,$16,$AC,$D2,
 $0B,$0D,$34,$9F,$9B,$9B,$4F,$A6,$84,$21,$37,$9F,
 $9B,$9B,$2B,$AF,$A1,$38,$A3,$8B,$82,$8E,$69,$95,
 $81,$B2,$1A,$A3,$9A,$9A,$9C,$B8,$9C,$97,$A4,$62,
 $2D,$02,$28,$46,$4A,$BA,$68,$26,$11,$CB,$2E,$05,
 $9E,$9E,$53,$2C,$03,$27,$47,$4B,$25,$10,$06,$9E,
 $9E,$52,$AB,$39,$6F,$A9,$67,$6D,$6A,$69,$C9,$B7,
 $A7,$77,$62,$71,$74,$76,$AA,$A9,$B9,$AE,$61,$B0,
 $C1,$BB,$65,$B4,$66,$AD,$64,$BE,$BD,$CF,$AE,$C5,
 $B0,$C0,$73,$75,$6E,$C8,$66,$A1,$C3,$6C,$B1,$6B,
 $6C,$CF,$CE,$B3,$6A,$D5,$B4,$CD,$C4,$C3,$D0,$C7,
 $72,$CC,$D1,$64,$A8,$D5,$AF,$B5,$D4);

 hash_ofs: array [0..260] of word=(
 $0458,$048C,$04A4,$04B0,$0510,$0590,$05C9,$0642,$064F,$0684,$068A,$0693,
 $06CD,$06ED,$0714,$0734,$0853,$0881,$0910,$0990,$09AC,$09AE,$09B2,$09B3,
 $0A03,$0A54,$0A68,$0A74,$0A82,$0AB3,$0C53,$0C62,$0C6A,$0C72,$0C73,$0C81,
 $0C94,$0CA4,$0CB3,$0D83,$0DC9,$0E74,$0EC2,$0ECA,$0ED2,$0ED3,$1074,$1081,
 $10A4,$10B3,$1110,$1183,$1190,$11C1,$11C5,$11C9,$1203,$1284,$1478,$155E,
 $15C2,$15CA,$15D2,$15D3,$1925,$1A4F,$1B79,$1C4B,$1E4F,$1EE6,$1EE7,$2258,
 $22D8,$2437,$24B3,$2583,$2585,$25A2,$25AA,$25B2,$25B3,$25C9,$266F,$2692,
 $2760,$2C28,$2D10,$2D82,$2E42,$2F88,$3069,$30A4,$31C9,$31F2,$3202,$3203,
 $320A,$3212,$3213,$3261,$3292,$3497,$354A,$361E,$3721,$3AA5,$3AB2,$3ACD,
 $3FD3,$400D,$40B2,$40B3,$4110,$4190,$41A3,$41AA,$41E3,$41E6,$41EE,$4293,
 $42CD,$44A2,$44AA,$44B2,$44B3,$463C,$4910,$4990,$49E5,$49F2,$4A25,$4A40,
 $4A6A,$4A6C,$4C62,$4C6A,$4C72,$4C73,$4C74,$4D85,$4DC9,$4E92,$4EC2,$4ECA,
 $4ED2,$4ED3,$4F14,$4FA1,$50C9,$5122,$51D4,$51E2,$520F,$5245,$5297,$5305,
 $5625,$56C2,$5983,$5A04,$5C53,$5C81,$5CA4,$5D5E,$5DC9,$5E03,$5E83,$5EDF,
 $6034,$608C,$60A4,$6110,$6190,$61A1,$61A6,$61C9,$6203,$6231,$6274,$6293,
 $62CD,$62ED,$6334,$6434,$648C,$64A4,$6510,$6590,$65C9,$6603,$6693,$66CD,
 $66ED,$6714,$68C2,$6A93,$733C,$73F5,$7833,$7B65,$7C8D,$7E9D,$7F58,$7F79,
 $8154,$864A,$8976,$8D4A,$92F2,$9704,$990E,$9998,$9B88,$9E9D,$9F52,$A307,
 $A3EE,$A421,$A934,$A9FB,$AB24,$ACD0,$AFC6,$B2B3,$B633,$B904,$B9DA,$B9F0,
 $BA41,$C10A,$C257,$CA0E,$CA5A,$CD5F,$CDE6,$CE0D,$CF8A,$D040,$D0C2,$D0CD,
 $D894,$D91C,$DE1A,$E073,$E3FC,$E767,$E829,$E97F,$EB60,$EBA8,$EF94,$F129,
 $F166,$F1FE,$F5D1,$F5F1,$F6D0,$F6E5,$F8D5,$FAC5,$FCCE);
 
begin

// szukanie indeksow dla MES
 y:=0;
 for x:=0 to sizeof(mes)-1 do
  if ord(mes[x])>$7f then begin
   dec(mes[x],$80);
   imes[y]:=x;
   inc(y);
  end;
 

 for x:=0 to 255 do begin

  crc:=x shl 8;
  crc_:=crc;

  for y:=1 to 8 do begin
   crc := crc shl 1;
   crc_ := crc_ shr 1;

   if (crc and $00010000) > 0 then crc := crc xor $1021;
   if (crc_ and $80) > 0 then crc_ := crc_ xor $edb8832000;
  end;

  tcrc16[x] := integer(crc);
  tcrc32[x] := cardinal(crc_ shr 8);
 end;


 for IORes:=sizeof(hash_val)-1 downto 0 do hash[hash_ofs[IORes]] := hash_val[IORes];


(*----------------------------------------------------------------------------*)
(*  przetwarzanie parametrow, inicjalizacja zmiennych                         *)
(*----------------------------------------------------------------------------*)

 if ParamCount<1 then Syntax;

 // odczyt parametrow
 for IORes:=1 to ParamCount do begin
  t:=ParamStr(IORes);

  if not(t[1] in ['/','-']) then
   plik_asm:=t
  else begin

   _i:=2;
   while _i<=length(t) do begin

   case UpCase(t[_i]) of


    'C': case_used    := true;
//    'E': white_spaces := true;
    'F': labFirstCol  := true;
    'P': full_name    := true;
    'S': silent       := true;
    'X': exclude_proc := true;


    'B': if t[_i+1]<>':' then
          Syntax
         else begin
          inc(_i,2);

          tmp:=get_dat(_i,t,' ',true);
          
          binary_file.adr := integer( oblicz_wartosc(tmp, t) );

          binary_file.use := true;
         end;
    
    'D': if t[_i+1]<>':' then Syntax else begin
          inc(_i,2);
          def_label:=get_lab(_i,t, true);

          if t[_i]<>'=' then Syntax;

          inc(_i);
          nul.i:=integer( get_expres(_i,t,t, false) );

          s_lab(def_label,nul.i,bank,t,def_label[1]);
         end;

    'H': begin
          inc(_i);

          case UpCase(t[_i]) of
           'C': begin
                 list_hhh:=true;
                 if t[_i+1]=':' then plik_h:=nowy_plik(plik_h, _i);
                end;

           'M': begin
                 list_mmm:=true;
                 if t[_i+1]=':' then plik_hm:=nowy_plik(plik_hm, _i);
                end;
           else
            Syntax
           end;

         end;

    'I': if t[_i+1]<>':' then Syntax else begin
          name:=nowy_plik(name, _i);

          if name='' then Syntax else begin
           line_all:=High(t_pth);
           t_pth[line_all]:=name;            // procedura ASEM wyzeruje LINE_ALL
           SetLength(t_pth,line_all+2);
          end;

         end;

    'L': begin
          opt:=opt or 4;
          if t[_i+1]=':' then plik_lst:=nowy_plik(plik_lst, _i);
         end;

    'M': if t[_i+1]<>':' then Syntax else begin
          list_mac:=true;
          plik_mac:=nowy_plik(plik_mac, _i);
         end;

    'O': if t[_i+1]<>':' then Syntax else plik_obj:=nowy_plik(plik_obj, _i);

    'T': begin
          list_lab:=true;
          if t[_i+1]=':' then plik_lab:=nowy_plik(plik_lab, _i);
         end;
   else
    Syntax;
   end;

   inc(_i);
   end;

  end;

 end;


 if plik_asm='' then Syntax;

 path:=GetFilePath(plik_asm);
 if path='' then begin GetDir(0,path); path:=path+PathDelim end;

 name:=GetFileName(plik_asm);
 global_name:=name;

// sprawdzamy obecnosc pliku ASM
 plik_asm:=path+name;
 if not(TestFile(plik_asm)) then plik_asm := path + NewFileExt(name,5);

 if plik_lst = '' then plik_lst := path + NewFileExt(name,0);
 if plik_obj = '' then plik_obj := path + NewFileExt(name,1);
 if plik_lab = '' then plik_lab := path + NewFileExt(name,2);
 if plik_mac = '' then plik_mac := path + NewFileExt(name,3);
 if plik_h   = '' then plik_h   := path + NewFileExt(name,4);
 if plik_hm  = '' then plik_hm  := path + NewFileExt(name,6);

 t:=load_mes(50+1);

 if not(silent) then new_message(t);

 if list_lab then begin
  AccessFile(plik_lab); AssignFile(lab,plik_lab); FileMode:=1; Rewrite(lab);
  writeln(lab,t);
  writeln(lab,load_mes(54+1));
 end;


 name:=GetFileName(plik_asm);
 _i:=1; name:=get_datUp(_i,name,'.',false);

 if list_mmm then begin
  AccessFile(plik_hm); AssignFile(mmm,plik_hm); FileMode:=1; Rewrite(mmm);
 end;

 if list_hhh then begin
  AccessFile(plik_h); AssignFile(hhh,plik_h); FileMode:=1; Rewrite(hhh);
  writeln(hhh,'#ifndef _'+name+'_ASM_H_');
  writeln(hhh,'#define _'+name+'_ASM_H_'+#13#10);
 end;

 AccessFile(plik_lst); AssignFile(lst,plik_lst); FileMode:=1; Rewrite(lst);
 AccessFile(plik_obj); Assignfile(dst,plik_obj); FileMode:=1; Rewrite(dst,1);

 Writeln(lst,t);        // naglowek z nazwa programu do pliku LST
end;

 
{
procedure tttt(a: string);
begin
 case length(a) of
  1,2: writeln(hex(ord(a[1]) shl 8+ord(a[2]),8));
  3: writeln(hex(ord(a[1]) shl 16+ord(a[2]) shl 8+ord(a[3]),8));
  4: writeln(hex(ord(a[1]) shl 24+ord(a[2]) shl 16+ord(a[3]) shl 8+ord(a[4]),8));
 end;
end;
}


(*----------------------------------------------------------------------------*)
(*                         M A I N   P R O G R A M                            *)
(*----------------------------------------------------------------------------*)
begin

 oblicz_mnemonik__ :=  oblicz_mnemonik;
 analizuj_plik__   :=  analizuj_plik;
 analizuj_mem__    :=  analizuj_mem;
 ___wartosc_noSPC  :=  oblicz_wartosc_noSPC;

 SetLength(t_lab,1);
 SetLength(t_hea,1);
 SetLength(t_mac,1);
 SetLength(t_loc,1);
 SetLength(t_prc,1);
 SetLength(t_pth,1);
 SetLength(t_wyw,1);
 SetLength(t_rel,1);
 SetLength(t_smb,1);
 SetLength(t_ext,1);
 SetLength(t_extn,1);
 SetLength(t_str,1);
 SetLength(t_arr,1);
 SetLength(t_pag,1);
 SetLength(t_end,1);
 SetLength(t_mad,1);
 SetLength(t_pub,1);
 SetLength(t_var,1);
 SetLength(t_skp,1);
 SetLength(t_lin,1);
 SetLength(t_sym,1);
 SetLength(t_usi,1);
 SetLength(if_stos,1);

 SetLength(t_siz,2);

 SetLength(messages,1);


(*----------------------------------------------------------------------------*)
(* tworzenie tablic 'TCRC16', 'TCRC32' oraz tablicy 'HASH', odczyt parametrow *)
(*----------------------------------------------------------------------------*)
 INITIALIZE;


 if binary_file.use then begin
  opt       := opt or 2;
  adres     := binary_file.adr;
  org       := true;
  first_org := false;
 end;

 optdef := opt;

 open_ok:=true;

 t:='';

 nul.l:=0; nul.i:=0; 

 asem(plik_asm);     

 over:=true;
 koniec(status);
end.

