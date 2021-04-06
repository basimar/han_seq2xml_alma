#! /usr/bin/perl

#use warnings;
use strict;
use Text::CSV;
use Catmandu::Importer::MARC::ALEPHSEQ;
use Catmandu::Exporter::MARC::ALEPHSEQ;
use Catmandu::Fix::marc_remove as => 'marc_remove';
use Catmandu::Fix::marc_add as => 'marc_add';
use Catmandu::Fix::marc_map as => 'marc_map';
use Catmandu::Fix::marc_set as => 'marc_set';

# Unicode-Support innerhalb des Perl-Skripts
use utf8;
# Unicode-Support für Output
binmode STDOUT, ":utf8";

die "Argumente: $0 Input Output \n" unless @ARGV == 2;

my($inputfile,$outputfile) = @ARGV;
my $tempfile = './temp.seq';

open my $in, "<:encoding(UTF-8)", $inputfile or die "$0: open $inputfile: $!";
open my $out, ">:encoding(UTF-8)", $tempfile or die "$0: open $tempfile: $!";

my $fmt;

NEWLINE: while (<$in>) {
    my $sysnumber = (substr $_ , 0, 9);
    my $line = $_;
    my $field = (substr $line, 10, 3);
    my $ind1 = (substr $line, 13, 1);
    my $ind2 = (substr $line, 14, 1);
    my $content = (substr $line, 18);
    chomp $line;
    chomp $content;

    my @subfields = split(/\$\$/, $line);
    shift @subfields;

    # Satzformat in Variable einlesen
    if ($field =~ /(FMT)/) {
        $fmt = $content;
    }

    # Zu löschende Felder entfernen
    if ($field =~ /(DEL|CAT|001|090|240|830|903)/) {
        next NEWLINE;
    }
    
    # LDR/18 auf c und LDR/08 auf a und LDR/09 auf a setzen, leere Positionen korrekt setzen
    if ($field =~ /(LDR)/) {
        substr($content,0,5) = '     ';
        substr($content,8,1) = 'a';
        substr($content,9,1) = 'a';
        substr($content,12,5) = '     ';
        substr($content,17,1) = ' ' if substr($content,17,1) =~ /(-|4)/;
        substr($content,18,1) = 'c';
        substr($content,19,1) = ' ';
        $line = $sysnumber . ' LDR   L ' . $content;
    }

    # Indikatoren in fixen Feldern löschen, leere Positionen korrekt setzen
    if ($field =~ /(006)/) {

        my $f006_0 = substr($content,0,1);

        if ($f006_0 eq 'a' ) {
            substr($content,12,1) = '|' if substr($content,12,1) =~ /-/;
            substr($content,13,1) = '|' if substr($content,13,1) =~ /-/;
            substr($content,14,1) = '|' if substr($content,14,1) =~ /-/;
            substr($content,16,1) = '|' if substr($content,16,1) =~ /-/;
        } elsif ($f006_0 eq 'c' ) {
            substr($content,1,1) = '|' if substr($content,1,1) =~ /-/;
            substr($content,2,1) = '|' if substr($content,2,1) =~ /-/;
            substr($content,3,1) = '|' if substr($content,3,1) =~ /-/;
        } elsif ($f006_0 =~ /(g|k|o)/ ) {
            substr($content,1,1) = '|' if substr($content,1,1) =~ /-/;
            substr($content,2,1) = '|' if substr($content,2,1) =~ /-/;
            substr($content,3,1) = '|' if substr($content,3,1) =~ /-/;
            substr($content,16,1) = '|' if substr($content,16,1) =~ /-/;
            substr($content,17,1) = '|' if substr($content,17,1) =~ /-/;
        }

        $content =~ s/-/ /g;

        $line = $sysnumber . ' 006   L ' . $content;

    } elsif ($field =~ /(007)/) {

        substr($content,2,1) = ' ' if substr($content,2,1) =~ /-/;
        $content =~ s/-/\|/g;
        $line = $sysnumber . ' 007   L ' . $content;

    } elsif ($field =~ /(008)/) {

        substr($content,0,6) = '000000' if substr($content,0,6) =~ /(------|\?\?\?\?\?\?)/;
        substr($content,7,1) = ' ' if substr($content,7,1) =~ /-/;
        substr($content,8,1) = ' ' if substr($content,8,1) =~ /-/;
        substr($content,9,1) = ' ' if substr($content,9,1) =~ /-/;
        substr($content,10,1) = ' ' if substr($content,10,1) =~ /-/;
        substr($content,11,1) = ' ' if substr($content,11,1) =~ /-/;
        substr($content,12,1) = ' ' if substr($content,12,1) =~ /-/;
        substr($content,13,1) = ' ' if substr($content,13,1) =~ /-/;
        substr($content,14,1) = ' ' if substr($content,14,1) =~ /-/;
        substr($content,15,1) = ' ' if substr($content,15,1) =~ /-/;
        substr($content,16,1) = ' ' if substr($content,16,1) =~ /-/;
        substr($content,17,1) = ' ' if substr($content,17,1) =~ /-/;
        substr($content,38,1) = ' ' if substr($content,38,1) =~ /-/;
        substr($content,39,1) = 'd' if substr($content,39,1) =~ /-/;

        if ($fmt eq 'BK') {
            substr($content,29,1) = '|' if substr($content,29,1) =~ /-/;
            substr($content,30,1) = '|' if substr($content,30,1) =~ /-/;
            substr($content,31,1) = '|' if substr($content,31,1) =~ /-/;
            substr($content,33,1) = '|' if substr($content,33,1) =~ /-/;
        } elsif ($fmt eq 'CF') {
            substr($content,26,1) = '|' if substr($content,26,1) =~ /-/;
        } elsif ($fmt eq 'MP') {
            substr($content,25,1) = '|' if substr($content,25,1) =~ /-/;
            substr($content,31,1) = '|' if substr($content,31,1) =~ /-/;
        } elsif ($fmt eq 'MU') {
            substr($content,18,1) = '|' if substr($content,18,1) =~ /-/;
            substr($content,19,1) = '|' if substr($content,19,1) =~ /-/;
            substr($content,20,1) = '|' if substr($content,20,1) =~ /-/;
        } elsif ($fmt eq 'SE') {
            substr($content,29,1) = '|' if substr($content,29,1) =~ /-/;
            substr($content,34,1) = '|' if substr($content,34,1) =~ /-/;
        } elsif ($fmt eq 'VM') {
            substr($content,18,1) = '|' if substr($content,18,1) =~ /-/;
            substr($content,19,1) = '|' if substr($content,19,1) =~ /-/;
            substr($content,20,1) = '|' if substr($content,20,1) =~ /-/;
            substr($content,33,1) = '|' if substr($content,33,1) =~ /-/;
            substr($content,34,1) = '|' if substr($content,34,1) =~ /-/;
        }
        
        $content =~ s/-/ /g;

        $line = $sysnumber . ' 008   L ' . $content;
        #print $sysnumber . ' ' . $fmt . ' ' . $content . "\n";
    }
    
    # Feld 019: Verbundcode an den Anfang von Unterfeld $5 hinzufügen
    if ($field =~ /(019)/) {
        $line =~ s/\$\$5/\$\$5HAN\//g;
    }

    # Feld 019XX löschen
    if ($field =~ /(019)/ && $ind1 eq 'X' && $ind2 eq 'X') {
        next NEWLINE;
    }
    
    if ($field =~ /(041)/) {
        if ($content =~ /\$\$h/) {
            $line = $sysnumber . ' 0411  L ' . $content;
        } else {
            $line = $sysnumber . ' 0410  L ' . $content;
        }
    }

    # Unterfeld $1 in $0 umwandeln und $9 löschen 
    if ($field =~ /(100|110|111|130|600|610|611|630|650|651|700|710|711|730|751)/) {
        $line =~ s/\$\$1/\$\$0/g;
        $line =~ s/\$\$9.+?(?=(\$\$|$))//g; 
    }
    
    # Beziehungskennzeichnung nur als Code migrieren (in TL3 ausgeschaltet, stattdessen $$eAutor durch $$eVerfasser ersetzen, inkl. Zweifelhafter Autor)
    if ($field =~ /(100|110|700|710)/) {
        #$line =~ s/\$\$e.+?(?=(\$\$|$))//g; 
        $line =~ s/\$\$eAutor/\$\$eVerfasser/g; 
        $line =~ s/\$\$eZweifelhafter Autor/\$\$eZweifelhafter Verfasser/g; 
    } elsif ($field =~ /(111|711)/ ) {
        #$line =~ s/\$\$j.+?(?=(\$\$|$))//g; 
        $line =~ s/\$\$jAutor/\$\$jVerfasser/g; 
        $line =~ s/\$\$jZweifelhafter Autor/\$\$jZweifelhafter Verfasser/g; 
    }
    

    # IDS-Unterfelder in Feld 245 entfernen 
    if ($field =~ /245/) {
        my $f245a;
        my $f245b;
        my $f245c;
        my $f245h;
        my $f2456;
 
        for (@subfields) {
            $f245a .= '$$' . $_ if $_ =~ /^a/;
            $f245c .= '$$' . $_ if $_ =~ /^c/;
            $f245h .= '$$' . $_ if $_ =~ /^h/;
            $f2456 .= '$$' . $_ if $_ =~ /^6/;
            
            $f245b .= ' : ' . substr($_,1) if $_ =~ /^b/;
            $f245b =~ s/^ : //g;

        }

        $f245b = '$$b' . $f245b if $f245b;
        $line = $sysnumber . ' 24510 L ' . $f245a .  $f245b . $f245c . $f2456;
    }
    
    # Feld 254 in Feld 348 umwandeln
    if ($field =~ /254/) {
        if ( $content =~ /\$\$aStimme/ ) {
            $content =~ s/\$\$aStimmen/\$\$aStimme/g;
            $line = $sysnumber . ' 348   L ' . $content . '$$2gnd-music';
        } elsif ($content =~ /\$\$a(Aufführungsmaterial|Chorbuch|Chorpartitur|Klavier-Direktionsstimme|Klavierauszug|Klavierbearbeitung|Particell|Partitur|Studienpartitur|Table Book|Violin-Direktionsstimme)$/ ) {
            $line = $sysnumber . ' 348   L ' . $content . '$$2gnd-music';
        } else {
            $line = $sysnumber . ' 348   L ' . $content;
        }
    }
    
    # Feld 490 anpassen, Feld 830 ergänzen
    if ($field =~ /490/) {

        my $f490a;
        my $f490i;
        my $f490v;
        my $f490w;

        foreach (@subfields) {
            if (substr($_,0,1) eq 'a')  {
                $f490a = substr($_,1)
            }
            if (substr($_,0,1) eq 'i')  {
                $f490i = substr($_,1)
            }
            if (substr($_,0,1) eq 'v')  {
                $f490v = substr($_,1)
            }
            if (substr($_,0,1) eq 'w')  {
                $f490w = substr($_,1)
            }
        }
        
        # Systemnummer auf 9 Stellen ergänzen
        $f490w = sprintf("%09d", $f490w);
        $f490w = '(HAN)' . $f490w . 'DSV05';
     
        $line = $sysnumber . ' 4900  L $$a' . $f490a . '$$v' . $f490v;

        $line =~ s/\$\$a\$\$/\$\$/g;
        $line =~ s/\$\$v$//g;
        my $line830 = $sysnumber . ' 830   L $$a' . $f490a .  '$$v' . $f490i . '$$w' . $f490w;
        
        $line830 =~ s/\$\$a\$\$/\$\$/g;
        $line830 =~ s/\$\$v\$\$/\$\$/g;
        $line830 =~ s/\$\$w$//g;
        $line830 =~ s/\$\$w000000000$//g;

        print $out $line830 . "\n";
    }

    # Feld 505: HAN-Unterfelder in $a überführen, Indikatoren 1 und 2 setzen
    if ($field =~ /505/) {
        
        #my $f505n;
        #my $f505g;
        #my $f505i;
        #my $f505s;
        #my $f505v;

        #foreach (@subfields) {
        #    if (substr($_,0,1) eq 'n')  {
        #        $f505n =  "(" . substr($_,1) . ")";
        #    }
        #}
        
        #foreach (@subfields) {
        #    if (substr($_,0,1) =~ 'g')  {
        #        $f505g = substr($_,1);
        #    }
        #}

        #foreach (@subfields) {
        #    if (substr($_,0,1) eq 'i')  {
        #        $f505i =  substr($_,1);
        #    }
        #}

        #foreach (@subfields) {
        #    if (substr($_,0,1) eq 's')  {
        #        $f505s = "Anmerkungen: " . substr($_,1);
        #    }
        #}
        
        #foreach (@subfields) {
        #    if (substr($_,0,1) eq 'v')  {
        #        $f505v = $f505v . '$$gNachweis: ' . substr($_,1);
        #        $line =~ s/^\$\$g//g;
        #    }
        #}

        if ($content =~ /\$\$a/ ) {
            $line = $sysnumber . ' 520   L ' .  $content;
        } else {       
            if ( $ind1 eq '2' ) {
                $line = $sysnumber . ' 59631 L ' .  $content;
            } else {
                $line = $sysnumber . ' 59630 L ' .  $content;
            }
        }
            #$content =~ s/\$\$n.+?(?=(\$\$|$))//g; 
            #$content =~ s/\$\$g.+?(?=(\$\$|$))//g; 
            #$content =~ s/\$\$i.+?(?=(\$\$|$))//g; 
            #$content =~ s/\$\$s.+?(?=(\$\$|$))//g; 
            #$content =~ s/\$\$v.+?(?=(\$\$|$))//g; 
#
#            unless ($f505g || $f505i || $f505s || $f505v) {
#                $line = $sysnumber . ' 50500 L ' . '$$g' . $f505n . $content;
#                $line =~ s/\$\$g\$\$/\$\$/g;
#            } else {
#                $line = $sysnumber . ' 50500 L ' . '$$g' . $f505g . '$$g' . $f505i . '$$g' . $f505s . '$$g' . $f505v . $content;
#                $line =~ s/\$\$g\$\$/\$\$/g;
#                $line =~ s/\$\$g\$\$/\$\$/g;
#                $line =~ s/\$\$g\$\$/\$\$/g;
#                $line =~ s/\$\$g\$\$/\$\$/g;
# 
#                $line =~ s/\$\$g/\$\$g$f505n /;
#                $line =~ s/\$\$g /\$\$g/g;
#            }
#        }
    }
    
    # Feld 880 - 505: HAN-Unterfelder in $a überführen, Indikatoren 1 und 2 setzen
    if ($field =~ /880/) {

        my $f8806;
        
        foreach (@subfields) {
            if (substr($_,0,1) eq '6')  {
                $f8806 =  substr($_,1);
            }
        }

        if ( $f8806 =~ /^505/ ) {
        
            if ($content =~ /\$\$a/ ) {
                $content =~ s/\$\$6505/\$\$6520/g;
                $line = $sysnumber . ' 880   L ' .  $content;
            } else {       
                $content =~ s/\$\$6505/\$\$6596/g;
                if ( $ind1 eq '2' ) {
                    $line = $sysnumber . ' 88031 L ' .  $content;
                } else {
                    $line = $sysnumber . ' 88030 L ' .  $content;
                }
            }
        }
    }
    
    # Feld 510: Unterfeld $i in $a integrieren, Indikator 1 setzen
    if ($field =~ /510/) {
       
        my $f510i;
        my $f510a;
        my $f510u;
        my $f5103;
        
        foreach (@subfields) {
            if (substr($_,0,1) eq 'a')  {
                $f510a = substr($_,1)
            } elsif (substr($_,0,1) eq 'i')  {
                $f510i = substr($_,1)
            } elsif (substr($_,0,1) eq 'u')  {
                $f510u = substr($_,1)
            } elsif ( substr($_,0,1) eq '3')  {
                $f5103 = substr($_,1)
            }
        }
        
        if ($content =~ /((S|Nr|pp|Bd|Bl|ff)\.|Seite)/ ) {
            $line = $sysnumber . ' 5104  L $$a' . $f510i . ': ' . $f510a . '$$u' . $f510u . '$$3' . $f5103;
        } else {
            $line = $sysnumber . ' 5103  L $$a' . $f510i . ': ' . $f510a . '$$u' . $f510u . '$$3' . $f5103;
        }
        
        $line =~ s/\$\$a\$\$/\$\$/g;
        $line =~ s/\$\$a: /\$\$a/g;
        $line =~ s/\$\$u\$\$/\$\$/g;
        $line =~ s/\$\$3$//g;
    }
    

    # Copyright-Hinweis in Feld 542 mit Indikator 2=1 in Feld 910 umwandeln 
    if ($field =~ /542/) {
        if ($ind2 eq '1' ) {
            $content =~ s/\$\$l/\$\$c/g;
            $line = $sysnumber . ' 910   L ' . $content;
        } else {
            $line = $sysnumber . ' 542' . $ind1 . '  L ' . $content;
        }
    }
    
    # Feld 581: Unterfeld $i in $a integrieren
    if ($field =~ /581/) {
       
        my $f581i;
        my $f581a;
        my $f5813;
        
        foreach (@subfields) {
            if (substr($_,0,1) eq 'a')  {
                $f581a = substr($_,1)
            } elsif (substr($_,0,1) eq 'i')  {
                $f581i = substr($_,1)
            } elsif ( substr($_,0,1) eq '3')  {
                $f5813 = substr($_,1)
            }
        }
        
        $line = $sysnumber . ' 581   L $$a' . $f581i . ': ' . $f581a . '$$3' . $f5813;
        $line =~ s/\$\$a\$\$/\$\$/g;
        $line =~ s/\$\$a: /\$\$a/g;
        $line =~ s/\$\$3$//g;
    }
    
    # Feld 588 in 583 umwandeln 
    if ($field =~ /588/) {
        $content =~ s/\$\$aKurzeintrag/\$\$aErschliessungsniveau Kurzeintrag/g;
        $content =~ s/\$\$aMinimalniveau/\$\$aErschliessungsniveau Minimalniveau/g;
        $content =~ s/\$\$aNormalniveau/\$\$aErschliessungsniveau Normalniveau/g;
        $line = $sysnumber . ' 5831  L ' . $content;
    }
    
    
    # HAN-Fussnoten 592, 593 und 594 in Feld 596 
    if ($field =~ /592/) {
        $line = $sysnumber . ' 5960  L ' . $content;
    } elsif ($field =~ /593/) {
        $line = $sysnumber . ' 5961  L ' . $content;
    } elsif ($field =~ /594/) {
        $line = $sysnumber . ' 5962  L ' . $content;
    }
   
    # Feld 596 in 500 umwandeln 
    if ($field =~ /596/) {
        if ( $ind2 =~ /5/ ) {
            $content =~ s/\$\$a/\$\$aBezug des Briefes zu Bänden der gedruckten Bernoulli Werkausgabe: /g;
        } elsif ( $ind2 =~ /6/ ) {
            $content =~ s/\$\$a/\$\$aBezug des Briefes zu anders bezeichneten Werken: /g;
        }
        $line = $sysnumber . ' 500   L ' . $content;
    }
    
    # Feld 597 in 019 umwandeln 
    if ($field =~ /597/) {
        $content =~ s/\$\$arekata voll/\$\$aRekatalogisierungsgrad voll\$\$5HAN/g;
        $content =~ s/\$\$arekata teil/\$\$aRekatalogisierungsgrad teil\$\$5HAN/g;
        $line = $sysnumber . ' 019   L ' . $content;
    }
    
    
    # Feld 655 (neu) aufgrund Feld 655 (alt)

    if ($field =~ /655/) {
        
        unless ($content =~ /\$\$2gnd-/ ) {
    
            if ($content =~ /\$\$aAufführungsmaterial/ ) {
                $line = $sysnumber . ' 655 4 L $$aAufführungsmaterial';
            } 
    
            if ($content =~ /\$\$aAstronomische Tabellen\/Kalender/ ) {
                $line = $sysnumber . ' 655 7 L $$aTabelle$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aAutograph/ ) {
                $line = $sysnumber . ' 655 7 L $$aAutograf$$2gnd-content';
            } 
   
            if ($content =~ /\$\$aBericht/ ) {
                $line = $sysnumber . ' 655 7 L $$aBericht$$2gnd-content';
            } 
   
            if ($content =~ /\$\$aChronikalisches/ ) {
                $line = $sysnumber . ' 655 7 L $$aGeschichtsschreibung$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aGutachten/ ) {
                $line = $sysnumber . ' 655 4 L $$aGutachten';
            } 
    
            if ($content =~ /\$\$aLiturgicum/ ) {
                $line = $sysnumber . ' 655 7 L $$aLiturgische Handschrift$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aNachruf/ ) {
                $line = $sysnumber . ' 655 7 L $$aNachruf$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aNotiz/ ) {
                $line = $sysnumber . ' 655 4 L $$aNotiz';
            } 
    
            if ($content =~ /\$\$aPorträt/ ) {
                $line = $sysnumber . ' 655 7 L $$aBildnis$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aPredigt/ ) {
                $line = $sysnumber . ' 655 7 L $$aPredigthilfe$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aProtokoll/ ) {
                $line = $sysnumber . ' 655 4 L $$aProtokoll';
            } 
     
            if ($content =~ /\$\$aRede\/Vortrag/ ) {
                $line = $sysnumber . ' 655 7 L $$aRede$$2gnd-content';
            } 
     
            if ($content =~ /\$\$aReisebericht/ ) {
                $line = $sysnumber . ' 655 7 L $$aReisebericht$$2gnd-content';
            } 
    
            if ($content =~ /\$\$aRezepte/ ) {
                $line = $sysnumber . ' 655 4 L $$aRezepte';
            }  
     
            if ($content =~ /\$\$aSammlungsverzeichnis\/Katalog/ ) {
                $line = $sysnumber . ' 655 7 L $$aKatalog$$2gnd-content';
            } 
     
            if ($content =~ /\$\$aSchulmaterialien/ ) {
                $line = $sysnumber . ' 655 7 L $$aSchulbuch$$2gnd-content';
            }  
     
            if ($content =~ /\$\$aSelbstzeugnis/ ) {
                $line = $sysnumber . ' 655 7 L $$aTagebuch$$2gnd-content';
            } 
     
            if ($content =~ /\$\$aStammbuch/ ) {
                $line = $sysnumber . ' 655 7 L $$aStammbuch$$2gnd-content';
            }  
     
            if ($content =~ /\$\$aVorlesung/ ) {
                $line = $sysnumber . ' 655 4 L $$aVorlesung';
            }
        }
    }

    # Alphabetische Indikatoren in Feld 690 löschen und durch Unterfelder $4 und $5 ersetzen
    if ($field =~ /690/) {
        if ($ind1 eq 'A' && $ind2 eq '1' ) {
            $line = $sysnumber . ' 690   L ' . $content . '$$2han-A1';
        } elsif ($ind1 eq 'A' && $ind2 eq '2' ) {
            $line = $sysnumber . ' 690   L ' . $content . '$$2han-A2';
        } elsif ($ind1 eq 'A' && $ind2 eq '3' ) {
            $line = $sysnumber . ' 690   L ' . $content . '$$2han-A3';
        } elsif ($ind1 eq 'A' && $ind2 eq '4' ) {
            $line = $sysnumber . ' 690   L ' . $content . '$$2han-A4';
        } elsif ($ind1 eq 'F' && $ind2 eq 'J' ) {
            $line = $sysnumber . ' 690   L ' . $content . '$$2ids-music';
           
            # Umwandlung von Feld 690 in Feld 382 + 655
            
            my $line_music_382 = $sysnumber . ' 382   L ' . $content;
            $line_music_382 =~ s/\$\$a.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$t.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$o.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$v.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$x.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$c.+?(?=(\$\$|$))//g; 
            $line_music_382 =~ s/\$\$q-//g; 
            $line_music_382 =~ s/\$\$q\[Besetzung \(verschiedene\)\]//g;
            $line_music_382 =~ s/\$\$q/\$\$a/g;
            $line_music_382 =~ s/ \(([0-9])\), /\$\$n$1\$\$a/g;
            $line_music_382 =~ s/ \(([0-9]{2})\), /\$\$n$1\$\$a/g;
            $line_music_382 =~ s/ \(([0-9])\)$/\$\$n$1/g;
            $line_music_382 =~ s/ \(([0-9]{2})\)$/\$\$n$1/g;
            $line_music_382 =~ s/, /\$\$n1\$\$a/g;
            $line_music_382 =~ s/$/\$\$n1/g unless ($line_music_382 =~ /[0-9]$/ || $line_music_382 =~ /[0-9]{2}$/ || length($line_music_382) == 18);
            $line_music_382 =~ s/ \(mehrere\)\$\$n1/\$\$nmehrere/g;
    
            print $out $line_music_382 . '$$2idsmusi' . "\n" unless length($line_music_382) == 18;
            
            my $line_music_655 = $sysnumber . ' 655 7 L ' . $content . '$$2idsmusg';
            $line_music_655 =~ s/\$\$a-//g; 
            #$line_music_655 =~ s/\$\$a\[Gattung \(verschiedene\)\]//g;
            $line_music_655 =~ s/\$\$q.+?(?=(\$\$|$))//g; 
            $line_music_655 =~ s/\$\$v.+?(?=(\$\$|$))//g; 
            $line_music_655 =~ s/\$\$c.+?(?=(\$\$|$))//g; 
            $line_music_655 =~ s/\$\$t/\$\$y/g;
            $line_music_655 =~ s/\$\$o/\$\$z/g;
            $line_music_655 =~ s/\$\$x/\$\$v/g;

            print $out $line_music_655 . "\n";
            
        } elsif ($ind1 eq 'W' && $ind2 eq '1' ) {
            $line = $sysnumber . ' 960   L ' . $content . '$$2ubs-W1$$9LOCAL';
        } elsif ($ind1 eq 'W' && $ind2 eq '2' ) {
            $line = $sysnumber . ' 960   L ' . $content . '$$2ubs-W2$$9LOCAL';
        } elsif ($ind1 eq 'W' && $ind2 eq '3' ) {
            $line = $sysnumber . ' 960   L ' . $content . '$$2ubs-W3$$9LOCAL';
        }
    }

    # Indikatoren in Feld 773 korrigieren, Systemnummer in $w mit führenden Nullen auffüllen, Feld $j in $q verschieben.
    if ($field =~ /773/) {
        my $f773g;
        my $f773j;
        my $f773t;
        my $f773w;

        foreach (@subfields) {
            if (substr($_, 0, 1) eq 'g') {
                $f773g = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 'j') {
                $f773j = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 't') {
                $f773t = substr($_, 1)
            }
            if (substr($_, 0, 1) eq 'w') {
                $f773w = substr($_, 1)
            }
        }

        $f773w = sprintf("%09d", $f773w);
        $f773w = '(HAN)' . $f773w . 'DSV05';

        $line = $sysnumber . ' 7731  L $$g' . $f773g . '$$q' . $f773j . '$$t' . $f773t . '$$w' . $f773w;
        $line =~ s/\$\$g\$\$/\$\$/g;
        $line =~ s/\$\$q\$\$/\$\$/g;
        $line =~ s/\$\$t\$\$/\$\$/g;
        $line =~ s/\$\$w$//g;
        $line =~ s/\$\$w000000000$//g;
    }
    
    #Alternativsignaturen und ehemalige Signaturen verschieben, übrige Felder 852 anpassen, so dass in Alma Holdings generiert werden können 
    if ($field =~ /852/) {

        my $f852a;
        my $f852b;
        my $f852c;
        my $f852n;
        my $f852p;
        my $f852q;
        my $f852x;
        my $f852z;
        
        foreach (@subfields) {
            if (substr($_, 0, 1) eq 'a') {
                $f852a = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'b') {
                $f852b = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'c') {
                $f852c = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'n') {
                $f852n = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'p') {
                $f852p = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'q') {
                $f852q = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'x') {
                $f852x = substr($_, 1)
            } elsif (substr($_, 0, 1) eq 'z') {
                $f852z = substr($_, 1)
            }
        }

        if ($ind1 eq 'A') {

            next NEWLINE;
            
            #if ($f852p) { 
            #    if ( $f852a =~ /Basel UB Wirtschaft - SWA/ ) {
            #        $f852p =~ s/^CH //g;
            #    } elsif ( $f852a =~ /Basel UB/ ) {
            #        $f852p =~ s/^/UBH /g;
            #    }
            #    my $temp_sig_a = $sysnumber . ' 853   L $$a' . $f852p;
            #    print $out $temp_sig_a . "\n";
            #}
 
            #$f852a = "Standort: " . $f852a if $f852a;
            #$f852b = ", " . $f852b if $f852b;
            #$f852p = ". Signatur: " . $f852p if $f852p;
            #$f852q = ". Zugang: " . $f852q if $f852q;
            #$f852z = " Hinweis: " . $f852z if $f852z;

            #$line = $sysnumber . ' 5611  L $$aAlternative Signatur: ' . $f852a . $f852b . $f852p . $f852q . $f852z;
            #my $line690_sig_a = $sysnumber . ' 690   L $$aAlternative Signatur: ' . $f852a . $f852b . $f852p . $f852q . $f852z . '$$2HAN-A5';
            #print $out $line690_sig_a . "\n";

        } elsif ($ind1 eq 'E') {
            
            $f852a = "Standort: " . $f852a if $f852a;
            $f852b = ", " . $f852b if $f852b;
            my $f852j = ". Signatur: " . $f852p if $f852p;
            $f852q = ". Zugang: " . $f852q if $f852q;
            $f852z = " Hinweis: " . $f852z if $f852z;

            #$line = $sysnumber . ' 5611  L $$aEhemalige Signatur: ' . $f852a . $f852b . $f852p . $f852q . $f852z;
            $line = $sysnumber . ' 690   L $$aEhemalige Signatur: ' . $f852a . $f852b . $f852j . $f852q . $f852z . '$$e' . $f852p .  '$$2HAN-A5';
            #my $line690_sig_e = $sysnumber . ' 690   L $$aEhemalige Signatur: ' . $f852a . $f852b . $f852p . $f852q . $f852z . '$$2HAN-A6';
            #print $out $line690_sig_e . "\n";

        } else {
            if ( $f852a =~ /Basel UB Wirtschaft - SWA/ ) {
                $f852b = 'A125';
                $f852c = '125PA';
                $f852p =~ s/^CH //g;
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
                $line =~ s/\$\$.\$\$/\$\$/g;
            } elsif ( $f852a =~ /Basel UB/ ) {
                if ($f852b =~ /Handschriften/ ) {
                    $f852c = '102HSS'
                } elsif ( $f852b =~ /Magazin/ ) {
                    $f852c = 'MAG'
                } elsif ( $f852b =~ /Porträtsammlung/ ) {
                    $f852c = '100KS'
                } elsif ( $f852b =~ /Kartensammlung/ ) {
                    $f852c = '100KS'
                } 
                $f852b = 'A100';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$jUBH ' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Beromünster Stift/ ) {
                if ($f852b =~ /Bibliothek/ ) {
                    $f852c = '380BI'
                } elsif ( $f852b =~ /Archiv/ ) {
                    $f852c = '380AR'
                } elsif ( $f852b =~ /Schatzkammer/ ) {
                    $f852c = '380SK'
                } 
                $f852b = 'A380';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y68';
            } elsif ( $f852a =~ /KB Thurgau/ ) {
                $f852c = '381HB';
                $f852b = 'A381';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Zofingen SB/ ) {
                $f852c = '382HS';
                $f852b = 'A382';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y68';
            } elsif ( $f852a =~ /St. Gallen Stiftsbibliothek/ ) {
                $f852c = 'KGSR';
                $f852b = 'SGSTI';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y68';
            } elsif ( $f852a =~ /Appenzell Ausserrhoden/ ) {
                $f852c = 'ZSA';
                $f852b = 'SGARK';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /KB Aargau/ ) {
                if ($f852b =~ /Magazin/ ) {
                    $f852c = 'AKBMA'
                } elsif ( $f852b =~ /Handschriften/ ) {
                    $f852c = 'AKBHA'
                } elsif ( $f852b =~ /Nachlässe/ ) {
                    $f852c = 'AKBNA'
                } 
                $f852b = 'AKB';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /St. Gallen KB Vadiana/ ) {
                if ($f852b =~ /Rara Vadianische Sammlung/ ) {
                    $f852c = 'RAVS'
                } elsif ( $f852b =~ /Rara KB Vadiana St. Gallen/ ) {
                    $f852c = 'RAKB'
                } elsif ( $f852b =~ /Rara KB St. Gallen/ ) {
                    $f852c = 'RAKB'
                } elsif ( $f852b =~ /St. Galler Zentrum für das Buch/ ) {
                    $f852c = 'RAZB'
                } 
                $f852b = 'SGKBV';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Luzern ZHB/ ) {
                if ($f852b =~ /Sondersammlung Tresor BB/ ) {
                    $f852c = 'ZBTRB'
                } elsif ( $f852b =~ /Sondersammlung Tresor KB/ ) {
                    $f852c = 'ZBTRK'
                } elsif ( $f852b =~ /Sondersammlung 114/ ) {
                    $f852c = 'ZBT14'
                } elsif ( $f852b =~ /Sondersammlung U30/ ) {
                    $f852c = 'ZBT10'
                } elsif ( $f852b =~ /Sondersammlung Rollgestell/ ) {
                    $f852c = 'ZBT10'
                } elsif ( $f852b =~ /Sondersammlung Rollgestell U30/ ) {
                    $f852c = 'ZBT10'
                } elsif ( $f852b =~ /Sondersammlung Elektronisches Archiv ZHB/ ) {
                    $f852c = 'ZBT14'
                } elsif ( $f852b =~ /Sondersammlung Graphiksammlung/ ) {
                    $f852c = 'ZBSOS'
                } 
                $f852b = 'LUZHB';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Bern UB Schweizerische Osteuropabibliothek/ ) {
                $f852c = '415H2';
                $f852b = 'B415';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Bern UB Bibliothek Münstergasse/ ) {
                $f852c = '404U3';
                $f852b = 'B404';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Bern UB Archives REBUS/ ) {
                $f852c = '400K1';
                $f852b = 'B400';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Bern UB Medizingeschichte: Rorschach-Archiv/ ) {
                $f852c = '583RO';
                $f852b = 'B583';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Bern Gosteli-Archiv/ ) {
                if ($f852b =~ /Biografische Notizen/ ) {
                    $f852c = '445BN'
                } else  {
                    $f852c = '445AN'
                } 
                $f852b = 'B445';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } elsif ( $f852a =~ /Solothurn ZB/ ) {
                if ($f852b =~ /Handschriften/ ) {
                    $f852c = '150SO'
                } elsif ($f852b =~ /Alte Drucke/ ) {
                    $f852c = '150SO'
                } elsif ($f852b =~ /Historische Musiksammlung/ ) {
                    $f852c = '150SO'
                } 
                $f852b = 'A150';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852z . '$$y12';
            } else {
                my $f852a_old = "Standort: " . $f852a if $f852a;
                my $f852b_old = ", " . $f852b if $f852b;
                $f852c = '117B1';
                $f852b = 'A117';
                $line = $sysnumber . ' 8524  L $$b' . $f852b . '$$c' . $f852c . '$$n' .  $f852n . '$$j' .  $f852p . '$$z' . $f852q . '$$x' . $f852x . '$$z' . $f852a_old . $f852b_old . '$$y12';
            }
        }

        $line =~ s/\$\$z\$\$/\$\$/g;
        $line =~ s/\$\$x\$\$/\$\$/g;
        $line =~ s/\$\$z$//g;
        
        #if ( $f852q =~ /(Zugang|Benutzung) eingeschränkt/ ) {
        #    $line =~ s/\$\$y12/\$\$y67/g;
        #    $line =~ s/\$\$y68/\$\$y67/g;
        #}
    }

    # Indikator 1 in Feld 856 auf 4 setzen (damit Link in Primo VE angezeigt wird) 
    if ($field =~ /856/) {
        $line = $sysnumber . ' 8564' . $ind2 . ' L ' . $content;
    }
    
    # Feld 909 in 900 verschieben und mit Präfix ergänzen
    if ($field =~ /909/) {
        if ( $content =~ /(collect_this|hide_this|emanuscripta)/ ) {
            $line = $sysnumber . ' 900   L ' . $content;
            $line =~ s/\$\$f/\$\$fHAN/g;
        } else {
            $line = $sysnumber . ' 990   L ' . $content;
            $line =~ s/$/\$\$9LOCAL/g;
        } 
    }
    
    print $out $line . "\n";
}

close $out or warn "$0: close $tempfile $!";

my $importer = Catmandu::Importer::MARC::ALEPHSEQ->new(file => $tempfile);
my $exporter = Catmandu::Exporter::MARC::ALEPHSEQ->new(file => $outputfile);
#my $exporter = Catmandu::Exporter::MARC::XML->new(file => $outputfile);
#my $exporter = Catmandu::Exporter::MARC::XML->new(file => $outputfile, pretty => 1);

$importer->each(sub {
    my $data = $_[0];

    my $sysnumber = $data->{_id};
    my $f035 = '(HAN)' . $sysnumber . 'DSV05';
     
    # Feld 019 mit Unikatshinweishinzufügen     
    $data = marc_add($data,'019','a', 'Exemplarspezifische Aufnahme, gesperrt für Veränderungen und das Anhängen von Signaturen.$$5HAN/11.11.2020/bmt');

    # Feld 035 mit HAN-Systemnummer hinzufügen     
    $data = marc_add($data,'035','a', $f035);
        
    # Feld 040 hinzufügen
    $data = marc_add($data,'040','a', 'CH-001880-7$$bger$$eHAN-Katalogisierungsregeln');
     
    # Feld 900 mit Unikatshinweis hinzufügen     
    $data = marc_add($data,'900','a', 'HANunikat');

    # Formatbegriffe anpassen
    $data = marc_map($data,'LDR','LDR');
    my $ldrpos6 = substr($data->{LDR}, 6, 1);
    $data = marc_map($data,'655','f655');
    $data = marc_map($data,'906','f906');
    $data = marc_map($data,'907','f907');
    $data = marc_map($data,'300b','f300');
    
    # Feld 336 aufgrund 300
    if ($data->{f300} =~ /Buchschmuck\/Illustration/ ) {
        $data = marc_add($data,'336','a','unbewegtes Bild','b','sti','2','rdacontent');
    }

    # Feld 336 aufgrund Leader/06
    if ($ldrpos6 =~ /a/ ) {
        $data = marc_add($data,'336','a','Text','b','txt','2','rdacontent');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /t/ ) {
        $data = marc_add($data,'336','a','Text','b','txt','2','rdacontent');
        $data = marc_add($data,'655', 'ind2' ,'7','a','Handschrift','2','gnd-content');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /c/ ) {
        $data = marc_add($data,'336','a','Noten','b','ntm','2','rdacontent');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /d/ ) {
        $data = marc_add($data,'336','a','Noten','b','ntm','2','rdacontent');
        $data = marc_add($data,'655', 'ind2' ,'7','a','Musikhandschrift','2','gnd-content');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /e/ ) {
        $data = marc_add($data,'336','a','Kartografisches Bild','b','cri','2','rdacontent');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /f/ ) {
        $data = marc_add($data,'336','a','Kartografisches Bild','b','cri','2','rdacontent');
        $data = marc_add($data,'655', 'ind2', '7','a','Handschrift','2','gnd-content');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /g/ ) {
        if ($data->{f906} =~ /VM/ ) {
            $data = marc_add($data,'336','a','unbewegtes Bild','b','sti','2','rdacontent');
        } elsif ($data->{f906} =~ /MP/ ) {
            $data = marc_add($data,'336','a','zweidimensionales bewegtes Bild','b','tdi','2','rdacontent');
        } 
    } elsif ($ldrpos6 =~ /i/ ) {
        $data = marc_add($data,'336','a','gesprochenes Wort','b','spw','2','rdacontent');
    } elsif ($ldrpos6 =~ /j/ ) {
        $data = marc_add($data,'336','a','aufgeführte Musik','b','prm','2','rdacontent');
    } elsif ($ldrpos6 =~ /k/ ) {
        $data = marc_add($data,'336','a','unbewegtes Bild','b','sti','2','rdacontent');
        unless ($data->{f906}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /p/ ) {
        $data = marc_add($data,'336','a','Sonstige','b','xxx','2','rdacontent');
        unless ($data->{f906} || $data->{f907}) {
            $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
            $data = marc_add($data,'338','a','Sonstige','b','nz','2','rdacarrier');
        }
    } elsif ($ldrpos6 =~ /r/ ) {
        $data = marc_add($data,'336','a','dreidimensionale Form','b','xxx','2','rdacontent');
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Gegenstand','b','nr','2','rdacarrier');
    }
 
    # Feld 337, 338, 655 aufgrund von 906/907
    if ($data->{f906} =~ /Briefe = Correspondance/ || $data->{f907} =~ /Briefe = Correspondance/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Briefsammlung','2','gnd-content');
    } 
   
    if ($data->{f906} =~ /Festschrift/ || $data->{f907} =~ /Festschrift/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Festschrift','2','gnd-content');   
    } 
   
    if ($data->{f906} =~ /Gesetze und Verordnungen/ || $data->{f907} =~ /Gesetze und Verordnungen/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
    }
   
    if ($data->{f906} =~ /Hochschulschrift/ || $data->{f907} =~ /Hochschulschrift/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Hochschulschrift','2','gnd-content');   
    } 
    
    if ($data->{f906} =~ /Werke = Oeuvres/ || $data->{f907} =~ /Werke = Oeuvres/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
    } 
    
    if ($data->{f906} =~ /CF CD-ROM/ || $data->{f907} =~ /CF CD-ROM/ ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Computerdisk','b','cd','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','CD-ROM','2','gnd-carrier');
    } 
    
    if ($data->{f906} =~ /CF DVD-ROM/ || $data->{f907} =~ /CF DVD-ROM/ ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Computerdisk','b','cd','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','DVD-ROM','2','gnd-carrier');
    } 
    
    if ($data->{f906} =~ /CF Elektron. Daten Fernzugriff/ || $data->{f907} =~ /CF Elektron. Daten Fernzugriff/ ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Online-Ressource','b','cr','2','rdacarrier');
    } 
    
    if ($data->{f906} =~ /CF Magnetband-Kassette/ || $data->{f907} =~ /CF Magnetband-Kassette/ ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Magnetbandkassette','b','cf','2','rdacarrier');
    } 
    
    if ($data->{f906} =~ /CF Magnetband / || $data->{f907} =~ /CF Magnetband / ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Magnetbandspule','b','ch','2','rdacarrier');
    }
    
    if ($data->{f906} =~ /CF Diskette/ || $data->{f907} =~ /CF Diskette/ ) {
        $data = marc_add($data,'337','a','Computermedien','b','c','2','rdamedia');
        $data = marc_add($data,'338','a','Computerdisk-Cartridge','b','ce','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Diskette','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /MP Videoaufzeichnung/ || $data->{f907} =~ /MP Videoaufzeichnung/ ) {
        $data = marc_add($data,'337','a','Video','b','v','2','rdamedia');
        $data = marc_add($data,'338','a','Videokassette','b','vf','2','rdacarrier');
    } 

    if ($data->{f906} =~ /MP Film/ || $data->{f907} =~ /MP Film/ ) {
        $data = marc_add($data,'007','_', 'mr ||||||||||||||||||||');
        $data = marc_add($data,'337','a','Video','b','g','2','rdamedia');
        $data = marc_add($data,'338','a','Videobandspule','b','mr','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Film','2','gnd-content');
    } 

    if ($data->{f906} =~ /MP DVD-Video/ || $data->{f907} =~ /MP DVD-Video/ ) {
        $data = marc_add($data,'337','a','Video','b','v','2','rdamedia');
        $data = marc_add($data,'338','a','Videodisk','b','vd','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','DVD-Video','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /PM Unbekannt/ || $data->{f907} =~ /PM Unbekannt/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
    } 

    if ($data->{f906} =~ /PM Andere Ausgabeform/ || $data->{f907} =~ /PM Andere Ausgabeform/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
    } 

    if ($data->{f906} =~ /PM Partitur/ || $data->{f907} =~ /PM Partitur/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'348','a','Partitur','2','gnd-music');
    } 

    if ($data->{f906} =~ /PM Klavierauszug/ || $data->{f907} =~ /PM Klavierauszug/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'348','a','Klavierauszug','2','gnd-music');
    } 

    if ($data->{f906} =~ /PM Particell/ || $data->{f907} =~ /PM Particell/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Band','b','nc','2','rdacarrier');
        $data = marc_add($data,'348','a','Particell','2','gnd-music');
    } 

    if ($data->{f906} =~ /CM Karte/ || $data->{f907} =~ /CM Karte/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
    } 

    if ($data->{f906} =~ /CM Andere Art/ || $data->{f907} =~ /CM Andere Art/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
    } 

    if ($data->{f906} =~ /CM Ansicht, Panorama/ || $data->{f907} =~ /CM Ansicht, Panorama/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
    } 

    if ($data->{f906} =~ /SR Schallplatte/ || $data->{f907} =~ /SR Schallplatte/ ) {
        $data = marc_add($data,'337','a','audio','b','s','2','rdamedia');
        $data = marc_add($data,'338','a','Audiodisk','b','sd','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Schallplatte','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /SR Tonband-Kompaktkassette/ || $data->{f907} =~ /SR Tonband-Kompaktkassette/ ) {
        $data = marc_add($data,'337','a','audio','b','s','2','rdamedia');
        $data = marc_add($data,'338','a','Audiokassette','b','ss','2','rdacarrier');
    } 

    if ($data->{f906} =~ /SR CD/ || $data->{f907} =~ /SR CD/ ) {
        $data = marc_add($data,'337','a','audio','b','s','2','rdamedia');
        $data = marc_add($data,'338','a','Audiodisk','b','sd','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','CD','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /SR Tonbandspule/ || $data->{f907} =~ /SR Tonbandspule/ ) {
        $data = marc_add($data,'337','a','audio','b','s','2','rdamedia');
        $data = marc_add($data,'338','a','Tonbandspule','b','st','2','rdacarrier');
    } 

    if ($data->{f906} =~ /VM Foto/ || $data->{f907} =~ /VM Foto/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Fotografie','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /VM Bild = Image/ || $data->{f907} =~ /VM Bild = Image/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Bild','2','gnd-content');
    } 

    if ($data->{f906} =~ /VM Diapositiv = Diapositive/ || $data->{f907} =~ /VM Diapositiv = Diapositive/ ) {
        $data = marc_add($data,'337','a','projizierbar','b','g','2','rdamedia');
        $data = marc_add($data,'338','a','Dia','b','gs','2','rdacarrier');
    } 

    if ($data->{f906} =~ /VM Andere Art = Autre forme/ || $data->{f907} =~ /VM Andere Art = Autre forme/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
    } 

    if ($data->{f906} =~ /VM Postkarte/ || $data->{f907} =~ /VM Postkarte/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Postkarte','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /VM Plakat = Affiche/ || $data->{f907} =~ /VM Plakat = Affiche/ ) {
        $data = marc_add($data,'337','a','ohne Hilfsmittel zu benutzen','b','n','2','rdamedia');
        $data = marc_add($data,'338','a','Blatt','b','nb','2','rdacarrier');
        $data = marc_add($data,'655', 'ind2', '7','a','Plakat','2','gnd-carrier');
    } 

    if ($data->{f906} =~ /VM Arbeitstransparent/ || $data->{f907} =~ /VM Arbeitstransparent/ ) {
        $data = marc_add($data,'337','a','projizierbar','b','g','2','rdamedia');
        $data = marc_add($data,'338','a','Overheadfolie','b','gt','2','rdacarrier');
    } 

    if ($data->{f906} =~ /MF Mikrofilmspule/ || $data->{f907} =~ /MF Mikrofilmspule/ ) {
        $data = marc_add($data,'337','a','Mikroform','b','h','2','rdamedia');
        $data = marc_add($data,'338','a','Mikrofilmrolle','b','hj','2','rdacarrier');
    } 

    if ($data->{f906} =~ /MF Mikrofiche/ || $data->{f907} =~ /MF Mikrofiche/ ) {
        $data = marc_add($data,'337','a','Mikroform','b','h','2','rdamedia');
        $data = marc_add($data,'338','a','Mikrofiche','b','he','2','rdacarrier');
    }
    
    if ($data->{f906} =~ /MF Andere Mikro/ || $data->{f907} =~ /MF Andere Mikro/ ) {
        $data = marc_add($data,'337','a','Mikroform','b','h','2','rdamedia');
        $data = marc_add($data,'338','a','Sonstige','b','hz','2','rdacarrier');
    }
    
    #Felder 906/907 löschen 
    $data = marc_remove($data,'906');
    $data = marc_remove($data,'907');
    

    #Unterfeld $a in 336/337/338 wieder löschen
    $data = marc_remove($data,'336a');
    $data = marc_remove($data,'337a');
    $data = marc_remove($data,'338a');
    
    #Alternativsignatur in Feld 852 hinzufügen
    #$data = marc_map($data,'853a','f853');
    #$data = marc_remove($data,'853');
    #$data = marc_set($data,'852', $f853)

    $exporter->add($data);
});

$exporter->commit;


exit;

