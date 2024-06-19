#!/usr/bin/perl

use strict vars;
use warnings;

$| = 1;

our $VERSION = "1.7";
my $DATE = "2022-02-01";
$0 =~ m!(([^\/\\]+?)(\.\w+)?)$!;
my $NAME = $2 // "xex-filter.pl";
my $FILENAME = $1 // $NAME;

use Getopt::Std;
our($opt_a, $opt_b, $opt_d, $opt_e, $opt_f, $opt_i, $opt_m, $opt_o, $opt_r, $opt_s, $opt_v, $opt_w, $opt_x, $opt_z);
$Getopt::Std::STANDARD_HELP_VERSION = 1;
getopts('a:bde:fi:mo:rs:v:w:x:z:') or die "Check command line, use '$FILENAME --help' for syntax\n";

my $direcciones = $opt_a;
my $esbinario = $opt_b;
my $solodatos = $opt_d;
my $extrae = $opt_e;
my $corrige = $opt_f;
my $trozos = $opt_i;
my $creamapa = $opt_m;
my $salida = $opt_o;
my $remueve = $opt_r;
my $recorta = $opt_s;
my $valores = $opt_v;
my $palabras = $opt_w;
my $exclusiones = $opt_x;
my $zero = $opt_z;

unless (@ARGV || defined $valores || defined $palabras) {
  VERSION_MESSAGE();
  HELP_MESSAGE();
  exit;
}

die "-o option is required for selected options\n"
  if (defined $zero || defined $trozos || defined $recorta || defined $solodatos || defined $extrae ||
      defined $direcciones || defined $creamapa || defined $remueve || defined $exclusiones) && !defined $salida;

die "Do not use -a or -s options with -d or -m\n"
  if (defined $direcciones || defined $recorta) && (defined $solodatos || defined $creamapa);

die "Do not use -a or -m options with -r\n"
  if (defined $direcciones || defined $creamapa) && defined $remueve;

die "Do not use -m option with -e\n"
  if defined $creamapa && defined $extrae;

die "Do not use -x option with -i\n"
  if defined $exclusiones && defined $trozos;

my %etiqueta = ();
my %valetiq = ();
while (<DATA>) {
  if (/^\s*(\w+)\s*=\s*(\$[0-9a-f]{1,4}|\d+)\s*$/i) {
    my $e = uc($1);
    my $v = sacahexa($2);
    $etiqueta{$v} = $e;
    $valetiq{$e} = $v;
  }
}

my $datos = undef;
my $valordec = undef;
my $valorhex = undef;

my $arch = undef;

my @lista = ();
if (defined $trozos) {
  if ($trozos =~ m!^\d+([,\-]\d+)*$!) {
    $trozos =~ s!(\d+)\-(\d+)!join(',', $2 < $1 ? reverse($2 .. $1) : $1 .. $2)!ge;
    die "Invalid block count list (double \"-\")\n" if $trozos =~ m!-!;
    @lista = split /,/, $trozos;
  } else {
    die "Invalid block count list\n";
  }
}

if (defined $zero) {
  die "Invalid max filler length\n" unless $zero =~ m!^\d+$!;
}

my @cortes = ();
if (defined $recorta) {
  $recorta = sacahexa($recorta);
  if ($recorta =~ m!^\d+([,\-]\d+)*$!) {
    $recorta =~ s!-(\d+)!',' . (1 + $1)!ge;
    my %l = map { 0 + $_ => 1 } split /,/, $recorta;
    @cortes = sort {$a <=> $b} keys %l;
    my $ultimo = pop @cortes;
    die "Split address $ultimo is out of range\n" if $ultimo > 65536;
    push @cortes, $ultimo unless $ultimo > 0xFFFF;
  } else {
    die "Invalid split addresses list\n";
  }
}

my @cdesde = ();
my @chasta = ();
if (defined $direcciones) {
  $direcciones = sacahexa($direcciones);
  if ($direcciones =~ m!^\d+([,\-]\d+)*$!) {
    for my $rango (split /,/, $direcciones) {
      my ($desde, $hasta, $x) = split /-/, $rango;
      die "Invalid new addresses list (double \"-\")\n" if defined $x;
      die "New address $desde is out of range\n" if $desde > 65535;
      die "New address $hasta is out of range\n" if defined $hasta && $hasta > 65535;
      die "Invalid new addresses range ($desde-$hasta)\n" if defined $hasta && $hasta < $desde;
      push @cdesde, $desde;
      push @chasta, $hasta;
    }
  } else {
    die "Invalid new addresses list\n";
  }
}

my @edesde = ();
my @ehasta = ();
if (defined $extrae) {
  $extrae = sacahexa($extrae);
  if ($extrae =~ m!^\d+([,\-]\d+)*$!) {
    my $ultimo = 65536;
    for my $rango (reverse split /,/, $extrae) {
      my ($desde, $hasta, $x) = split /-/, $rango;
      die "Invalid extraction addresses list (double -)\n" if defined $x;
      die "Extraction address $desde is out of range\n" if $desde > 0xFFFF;
      $hasta = $ultimo - 1 unless defined $hasta;
      die "Extraction address $hasta is out of range\n" if $hasta > 0xFFFF;
      die "Invalid extraction addresses range ($desde-$hasta)\n" if $hasta < $desde;
      unshift @edesde, $desde;
      unshift @ehasta, $hasta;
      $ultimo = $desde
    }
  } else {
    die "Invalid extraction addresses list\n";
  }
}

my @valordir = ();
my @valorval = ();
if (defined $valores) {
  $valores = sacahexa($valores);
  my $siguiente = 0;
  if ($valores =~ m!^\d+([,\=]\d+)*$!) {
    for my $asigna (split /,/, $valores) {
      my ($direccion, $contenido, $x) = split /=/, $asigna;
      die "Invalid value assign list (double \"=\")\n" if defined $x;
      if (!defined $contenido) {
        $contenido = $direccion;
        $direccion = $siguiente;
      }
      $siguiente = $direccion + 1;
      die "Address $direccion for new value is out of range\n" if $direccion > 0xFFFF;
      die "Value $contenido is out of range\n" if $contenido > 0xFF;
      push @valordir, $direccion;
      push @valorval, $contenido;
    }
  } else {
    die "Invalid new values list parameter\n";
  }
}

my @palabradir = ();
my @palabraval = ();
if (defined $palabras) {
  $palabras = sacahexa($palabras);
  my $siguiente = 0x02E0;
  if ($palabras =~ m!^\d+([,\=]\d+)*$!) {
    for my $asigna (split /,/, $palabras) {
      my ($direccion, $contenido, $x) = split /=/, $asigna;
      die "Invalid word assign list (double \"=\")\n" if defined $x;
      if (!defined $contenido) {
        $contenido = $direccion;
        $direccion = $siguiente;
      }
      $siguiente = $direccion + 2;
      die "Address $direccion for new word is out of range\n" if $direccion > 0xFFFF;
      die "Value $contenido for word is out of range\n" if $contenido > 0xFFFF;
      push @palabradir, $direccion;
      push @palabraval, $contenido;
    }
  } else {
    die "Invalid new words list parameter\n";
  }
}

my %excluye = ();
if (defined $exclusiones) {
  if ($exclusiones =~ m!^\d+([,\-]\d+)*$!) {
    $exclusiones =~ s!(\d+)\-(\d+)!join(',', $2 < $1 ? reverse($2 .. $1) : $1 .. $2)!ge;
    die "Invalid block exclusion list (double \"-\")\n" if $exclusiones =~ m!-!;
    for my $x (split /,/, $exclusiones) {
      $excluye{$x} = 1;
    }
  } else {
    die "Invalid block exclusion list\n";
  }
}

my @trozo = (pack("v", 0xFFFF));
my @tdesde = (-1);
my @thasta = (-1);
my $cuenta = 0;

my $grabado = 0;
my $nuevo = 0;

my $mapa = pack("B", 0x00) x 65536;
my $mapeando = $creamapa // defined $extrae;

while ($arch = shift) {
  print "Analyzing \"$arch\"...\n";
  open(F, "<", $arch) or die "ERROR - Cannot open $arch\n";
  binmode(F);
  my $verificado = 0;
  if (!defined $esbinario) {
    while (leeword()) {
      my $mensaje = "";
      my $desde = $valordec;
      my $desde2 = $valorhex;
      if ($desde == 0xFFFF) {
        muestra("-", $desde);
        $verificado++;
        next;
      } else {
        die "ERROR - Not an XEX file\n" unless $verificado || $corrige;
      }
      if (leeword()) {
        my $hasta = $valordec;
        my $hasta2 = $valorhex;
        if ($hasta < $desde) {
          print "-: $desde-$hasta [$desde2-$hasta2]\n";
          if ($corrige) {
            print "Corrupt file: invalid addresses\n";
            last;
          } else {
            die "ERROR - Corrupt file: invalid addresses\n";
          }
        }
        $cuenta++;
        push @tdesde, $desde;
        push @thasta, $hasta;
        my $largo = $hasta - $desde + 1;
        my $real = read(F, $datos, $largo);
        if ($real < $largo) {
          $datos .= pack("C", 0x00) x ($largo - $real);
          unless ($corrige) {
            muestra($cuenta, $desde, $hasta, $datos);
            die "ERROR - Corrupt file: $real bytes of $largo\n";
          }
        }
        push @trozo, $datos;
        if ($largo > $real) {
          $mensaje = "truncated at $real bytes";
        }
        muestra($cuenta, $desde, $hasta, $datos, $mensaje);
      } else {
        die "ERROR - Extra pointers at end of file\n" unless $corrige;
      }
    }
  } else {
    while (my $n = read(F, $datos, 65536)) {
      $cuenta++;
      push @trozo, $datos;
      push @tdesde, 0;
      push @thasta, $n - 1;
      muestra($cuenta, 0, $n - 1, $datos);
    }
  }
  close(F);
}
if (defined $valores) {
  print "Adding values...\n";
  for my $direccion (@valordir) {
    my $contenido = shift(@valorval);
    $cuenta++;
    my $datos = pack("C", $contenido);
    my $he = uc(unpack("H*", $datos));
    push @trozo, $datos;
    push @tdesde, $direccion;
    push @thasta, $direccion;
    hexa($direccion);
    muestra($cuenta, $direccion, $direccion, $datos); 
  }
}
if (defined $palabras) {
  print "Adding words...\n";
  for my $direccion (@palabradir) {
    my $contenido = shift(@palabraval);
    $cuenta++;
    my $datos = pack("v", $contenido);
    my $he = uc(unpack("H*", pack("n", $contenido)));
    push @trozo, $datos;
    push @tdesde, $direccion;
    push @thasta, $direccion + 1;
    muestra($cuenta, $direccion, $direccion + 1, $datos); 
  }
}

if ($salida) {
  print "Writing \"$salida\"...\n";
  open(F, ">", $salida) or die "ERROR - Cannot write output file\n";
  binmode(F);
  unless (defined $solodatos) {
    print F pack("v", 0xFFFF);
    $grabado = 2;
    muestra('-', 65535);
#    print "-: 65535 [\$FFFF] \"binhead\"\n";
  } else {
    $grabado = 0;
  }
  if ($cuenta && !defined $trozos) {
    for my $i (1 .. $cuenta) {
      push @lista, $i unless defined $excluye{$i};
    }
  }
  die "ERROR - No blocks written\n" unless @lista;
  my $i = shift @lista;
  if (defined $i && $i > 0 && defined $trozo[$i]) {
    my $pend = $trozo[$i];
    my $pdesde = $tdesde[$i];
    my $phasta = $thasta[$i];
    for $i (@lista) {
      die "ERROR - Invalid block $i\n" unless $i > 0 && defined $trozo[$i];
      my $espacio = $tdesde[$i] - $phasta - 1;
      if (defined $zero && $espacio >= 0 && $espacio <= $zero) {
        $pend .= pack("B", 0x00) x $espacio if $espacio > 0;
        $pend .= $trozo[$i];
        $phasta = $thasta[$i];
      } else {
        graba($pdesde, $phasta, $pend);
        $pend = $trozo[$i];
        $pdesde = $tdesde[$i];
        $phasta = $thasta[$i];
      }
    }
    graba($pdesde, $phasta, $pend);
  } else {
    die "ERROR - Invalid block $i\n" if defined $i;
  }
  $mapeando = undef;
  if ($creamapa) {
    graba(0x0000, 0xFFFF, $mapa);
  } elsif (defined $extrae) {
    for my $desde (@edesde) {
      my $hasta = shift @ehasta;
      graba($desde, $hasta, substr($mapa, $desde, $hasta - $desde + 1));
    }
  }
  close(F);
  print "$grabado bytes written\n";
}

sub graba {
  my ($desde, $hasta, $datos) = @_;
  for my $corte (@cortes) {
    last if $corte > $hasta;
    if ($desde < $corte && $corte <= $hasta) {
      grabatrozo($desde, $corte - 1, substr($datos, 0, $corte - $desde));
      $datos = substr($datos, $corte - $desde);
      $desde = $corte;
    }
  }
  grabatrozo($desde, $hasta, $datos);
}

sub grabatrozo {
  my ($desde, $hasta, $datos) = @_;
  if ($remueve) {
    if (length($datos) > 2) {
      if ($datos =~ m!^(\x00+)(.*?)$!s) {
        $datos = $2 // '';
        $desde = $desde + length($1);
      }
      if ($datos =~ m!^(.*?)(\x00+)$!s) {
        $datos = $1 // '';
        $hasta = $hasta - length($2);
      }
    }
    while ($datos =~ m!^(.*?)(\x00{5,})(.*)$!s) {
      my ($datos1, $datos2, $datos3) = ($1 // '', $2 // '', $3 // '');
      my ($largo1, $largo2) = (length($datos1), length($datos2));
      if ($largo1) {
        grabatrozo($desde, $desde + $largo1 - 1, $datos1);
        $desde += $largo1 + $largo2;
        $datos = $datos3;
      }
    }
    return if length($datos) == 0;
  }
  my $real = length($datos);
  my $largo = $hasta - $desde + 1;
  if ($mapeando) {
    substr($mapa, $desde, $largo) = $datos;
  } else {
    $nuevo++;
    if (defined $direcciones) {
      $desde = shift @cdesde;
      die "ERROR - Missing addresses in -a list\n" unless defined $desde;
      $hasta = shift @chasta // $desde + $real - 1;
      die "ERROR - New end address $hasta out of range\n" if $hasta > 0xFFFF;
    }
    $grabado += $largo;
    if (defined $solodatos) {
      muestra($nuevo, undef, undef, $datos);
    } else {
      print F pack("vv", $desde, $hasta);
      muestra($nuevo, $desde, $hasta, $datos, $real > $largo ? "truncated" : $real < $largo ? "filled" : undef);
      $grabado += 4;
    }
    if ($real > $largo) {
      print F substr($datos, 0, $largo);
      unshift @cdesde, $desde + $largo;
      unshift @chasta, undef;
      grabatrozo($desde + $largo, undef, substr($datos, $largo));
    } elsif ($real < $largo) {
      print F $datos . (pack("B", 0x00) x ($largo - length($datos)));
  } else {
      print F $datos;
    }
  }
}

sub leeword {
  my $largo = read(F, $datos, 2);
  if ($largo == 1) {
    if ($corrige) {
      print "Incomplete address!\n";
    } else {
      die "ERROR - Corrupt file: Incomplete address\n";
    }
  }
  return undef if $largo < 2;
  $valordec = unpack("v", $datos);
  hexa($valordec);
  return 1;
}

sub hexa {
  my $v = shift;
  $valorhex = '$' . substr('000' . uc(unpack("H*", pack("n", $v))), -4);
  return $valorhex;
}

sub sacahexa {
  my $lista = shift;
  $lista =~ s!\$([0-9a-f]{1,4})\b!unpack('n', pack('H*', uc(substr('000' . $1, -4))))!gei;
  $lista =~ s!\b([a-z]\w+)\b!$valetiq{uc($1)} // $1!gei;
  die "ERROR - Unknown label \"$1\"\n" if $lista =~ /([a-z]\w+)/i;
  return $lista;
}

sub muestra {
  my ($cuenta, $desde, $hasta, $datos, $mensaje) = @_;
  my $desde2 = hexa($desde) if defined $desde;
  if ($cuenta eq '-') {
    printf '  -: %-11s [%s]               BINHEAD', $desde, $desde2;
  } elsif (!defined $desde) {
    print "$cuenta: (" . length($datos) . ")";
  } else {
    my $hasta2 = hexa($hasta);
    my $largo = $hasta - $desde + 1;
    printf "%3s: %5s-%-5s [%s-%s] %7s", $cuenta, $desde, $hasta, $desde2, $hasta2, "($largo)";
    print ' ' . $etiqueta{$desde} if defined $etiqueta{$desde};
    if ($largo == 1) {
      printf ' = %s [$%s] \'%s\'', unpack("C", $datos), uc(unpack("H*", $datos)), unpack("B*", $datos);
    } elsif ($largo == 2) {
      my $va = unpack("v", $datos);
      my $he = uc(unpack("H*", pack("n", $va)));
      print " -> $va [\$$he]";
    } else {
      print " <- CODE/DATA";
    }
  }
  print " $mensaje" if $mensaje;
  print "\n";
}

sub centra {
  my ($valor, $espacio) = @_;
  my $largo = length($valor);
  return sprintf '%*s', $espacio, $valor . ($espacio > $largo ? ' ' x int(($espacio - $largo)/2) : '');
}

sub VERSION_MESSAGE {
  print "\n$NAME version $VERSION ($DATE)\nCopyright (c) 2020-2022 by Victor Parada\n<https://www.vitoco.cl/atari/xex-filter/>\n";
}

sub HELP_MESSAGE {
  print <<EOH;

Usage: $FILENAME [-option]... [--] FILE1.XEX [FILE2.XEX]...

Options:
  -i n1,n2-n3,...  List of indexes for blocks selection
  -x n1,n2-n3,...  List of indexes for blocks exclusion
  -s a1,a2-a3,...  List of memory addresses where to split blocks
  -e a1,a2-a3,...  List of memory addresses for data extraction
  -a a1,a2-a3,...  New address list to assign to output blocks
  -v a1=v1,v2,...  Append blocks with byte value at \$0000 or address
  -w a1=v1,v2,...  Append blocks with word value at RUNAD or address
  -z max           Max number of bytes to fill between blocks
  -r               Removes zeros if there are more than 4 in a row
  -d               Writes data without address pointers or header
  -b               Reads input as blocks up to 64K of data at \$0000
  -f               Fix corrupt files by filling or discarding data
  -m               Makes a memory map with the selected blocks
  -o NEW.XEX       Output file (mandatory for -i -x -s -e -a -z -r -d and -m)

Addresses between 0 and 65535 or in \$hhhh format. Use "-" for a range.
EOH
}

__DATA__
#label=value
RUNAD=$2E0
INITAD=$2E2
PORTB=$D301
BOOT=9
DOSVEC=10
SOUNDR=65
RAMTOP=106
SDMCTL=559
SDLSTL=560
COLDST=580
COLOR0=708
COLOR1=709
COLOR2=710
COLOR3=711
COLOR4=712
MEMTOP=$2E5
MEMLO=$2E7
CH1=754
CHBAS=756
CH=764
BASICF=1016
BANK=$4000
CARTB=$8000
CARTA=$A000
ATRACT=77
