#/!bin/sh
# wydobycie trafien o okreslonej dlugosci z pliku noperfect
awk -v p1="12" -v p2="13" "\$p1-\$p2==$1" $2 > x
cut -f14 -d" " x | sort -u > o2gen$1 # wyciecie kolumny oligo:gen

# do ilu genow pasuje dane oligo
cut -f1 -d":" o2gen$1 | uniq -d > unmapped$1id

echo "ile unikalnych niezmapowanych"
cut -f1 -d" " unmapped$1id | sort -u | wc -l # ile unikalnych niezmapowanych
# odsianie niezmapowanych (nieunikalnych) z trafien o okreslonej dlugosci
grep -Fwvf unmapped$1id x > mapped$1
echo "unikalne zmapowane"
cut -f1 -d" " mapped$1 | sort -u | wc -l # ile unikalnych zmapowanych
# odsianie niezmapowanych (nieunikalnych) z pliku zrodlowego
grep -Fwvf unmapped$1id $2 > x3
# ids zmapowanych $1
cut -f1 -d" " mapped$1 | sort -u | sed 's/>//' > xmap$1id
# odsianie zmapowanych i zapis pliku z gorszymi trafieniami
grep -Fwvf xmap$1id x3 > xno$1
echo "pozostalo noperfect"
cut -f1 -d" " xno$1 | sort -u | wc -l # ile zostalo nieperfect
# dalej skrypt_v2.sh i komendy_skrypt
