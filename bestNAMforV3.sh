# Przyporządkowania NAM do v3 wydobyte z maizeGDB. W pięciu częściach z względu na ograniczenie liczby w submisji.
# Poziom /media/mj/ANTIX-LIVE/anno_fun_v45
# Pliki gene_translate00v3v5 do gene_translate04v3v5
# Połączenie w plik gene_translate_all35, dużo operacji na kolumnach

# Dla niektórych NAM >1 GRMZ
# Wybranie takich
cut -f1 -d" " gene_translate_all35 | sort | uniq -d > NAM-mulitihit_v3
# transkrypty NAM w ../map_probes/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa
# transkrypty v3 z https://download.maizegdb.org/B73_RefGen_v3/
# usunięcie ndmiarowej info z nagłówka
cut -f1 -d" " Zea_mays.AGPv3.22.cdna.all.fa > x
mv x Zea_mays.AGPv3.22.cdna.all.fa

# Użycie fastafetch z exonerate (zainstalowane z repo ubuntu)
# poziom /media/mj/ANTIX-LIVE/map_probes
fastaindex -f Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa -i Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.in
# poziom /media/mj/ANTIX-LIVE/anno_fun_v45
# wydobycie IDs transkryptów bo fastafetch nie działa z regex
grep -Ff NAM-mulitihit_v3 ../map_probes/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa | tr -d '>' > NAM-mulitihit_v3_cdna
# Wydobycie sekwencji
fastafetch -f ../map_probes/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa -i ../map_probes/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.in \ 
-q NAM-mulitihit_v3_cdna -F > NAM-mulitihit_v3_cdna.fa

# Próba na podstawie uliniowań do mapowania sond
~/bin/exonerate-2.2.0-x86_64/bin/exonerate --query oligo_uniq.part-4.fa --target Zm-B73-REFERENCE-NAM-5.0.fa \
--showvulgar FALSE --showsugar FALSE --fsmmemory 5000 --ryo ">%S %V %em" --querytype dna --targettype dna > o2genome_pt4 &

# Do przemyślenia
 --model affine:bestfit albo affine:global
 --bestn <number>
 --subopt <boolean>


#********************* Inny pomysł, mapowanie MZ do cDNA v3 gdy do jednego NAM > 1 GRMZ **********************
#*********************** I sprawdzenie do którego GRMZ (przuporządkowanego do danego NAM) pasuje najlepiej ************
# Najpier wybór GRMZ, poziom /media/mj/ANTIX-LIVE/anno_fun_v45/map-multihit
grep -Fwf NAM-mulitihit_v3 ../gene_translate_all35 > NAM-v3-multihit
cut -f2 -d"    " NAM-v3-multihit | sort -u > grmz-ids-multi
# wydobycie podzbioru fasta
# Zamiana IDs genów na cdna
grep '^A' grmz-ids-multi | sed 's/_FG/_FGT/' > x
grep -v '^A' grmz-ids-multi > x2
grep -Ff x2 Zea_mays.AGPv3.22.cdna.all.fa | tr -d '>' > x3
cat x x3 > grmz-trans-ids-multi
# Indeksowanie
fastaindex -f Zea_mays.AGPv3.22.cdna.all.fa -i Zea_mays.AGPv3.22.cdna.all.in
fastafetch -f Zea_mays.AGPv3.22.cdna.all.fa -i Zea_mays.AGPv3.22.cdna.all.in -q grmz-trans-ids-multi -F > grmz-multihit.fa

# Wydobycie MZ pasujących do NAM dla których jest >1 GRMZ
# Z MZ dopasowanych do NAM wybieram NAM, które mają >1 GRMZ 
grep -Fwf NAM-mulitihit_v3 ../../map_probes/bbest_cdna/ids4sed | cut -f2 -d"/" > mz-NAM
# Indeksowanie, poziom /media/mj/ANTIX-LIVE/map_probes
fastaindex -f oligo_uniq.fa -i oligo_uniq.in
# wydobycie, poziom /media/mj/ANTIX-LIVE/anno_fun_v45/map-multihit
fastafetch -f ../../map_probes/oligo_uniq.fa -i ../../map_probes/oligo_uniq.in -q mz-NAM -F > mz-NAM.fa

# mapowanie, te same parametry co przy mapowaniu na NAM
exonerate --query mz-NAM.fa --target Zea_mays.AGPv3.22.cdna.all.fa --showvulgar FALSE --showsugar FALSE \ 
--fsmmemory 30000 --ryo ">%S %V %em" --querytype dna --targettype dna > o2v3

export LC_ALL=C
# Dalsza obróbka zgodnie z map_probes/oligo70/procedura_v2.sh
# inne przydatne pliki: komendy_skryptu, format_nagl, procedura50, skrypt_v2.sh
# wybor samych statystyk trafień
grep '^>' o2v3 > o2v3_hits
# wybor sond krotszych niz 70nt
grep -B1 '^[ACGT]\{40\}$' mz-NAM.fa | grep '>' | sed 's/>//' > oligo40nt
grep -B1 '^[ACGT]\{50\}$' mz-NAM.fa | grep '>' | sed 's/>//' > oligo50nt
# wybor trafien dla sond krotszych niz 70nt
grep -Fwf oligo40nt o2v3_hits > o2v3_hits40nt
grep -Fwf oligo50nt o2v3_hits > o2v3_hits50nt
# wybor trafien do sond 70nt, metoda negatywna
grep -Fwvf oligo40nt o2v3_hits > x
grep -Fwvf oligo50nt x > o2v3_hits70nt
#*********************************************************************************************************************
# wybor doskonalych dopasowan 70nt
awk '$11==70 && $12==70 && $13==0' o2v3_hits70nt > o2v3_perfect70
# wybor niedoskonalych dopasowan
awk '$11<70 || $12<70 || $13>0' o2v3_hits70nt > o2v3_noperfect70
# Odsianie par oligo:gen perfect ze zbioru noperfect
# dolaczenie ids oligo:gen
awk '{print $1":"$5}' o2v3_perfect70 | tr -d '>' | cut -f1 -d"_" > xperf70id
awk '{print $1":"$5}' o2v3_noperfect70 | tr -d '>' | cut -f1 -d"_" > xnoperf70id
paste -d" " o2v3_perfect70 xperf70id > o2v3_perfect70_combid
paste -d" " o2v3_noperfect70 xnoperf70id > o2v3_noperfect70_combid
# doczyszczenie
sed 's/-- completed exonerate analysis//' o2v3_noperfect70_combid > x
mv x o2v3_noperfect70_combid
# usuniecie z noperfect dodatkowych trafien dla par perfect
grep -Fwvf xperf70id o2v3_noperfect70_combid > o2v3_noperfect70_combid_noperfectid
# Czy mapowanie perfect sondy tylko dla jednego genu?
sort -u xperf70id > xperf70id_u
cut -f1 -d":" xperf70id_u | uniq -d > unmapped70id
# Odsianie multimammping perfect
grep -Fwvf unmapped70id o2v3_perfect70_combid > o2v3_perfect70_combid_1hit
# te oligo usuwam tez z noperfect
grep -Fwvf unmapped70id o2v3_noperfect70_combid_noperfectid > o2v3_noperfect70_combid_noperfectid_nounmpapped
# ids unikalnych sond z perfect trafieniami
cut -f1 -d" " o2v3_perfect70_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# odsianie trafien suboptymalnych dla sond z perfect trafieniami
grep -Fwvf ids_perf_1hit o2v3_noperfect70_combid_noperfectid_nounmpapped > o2v3_noperfect70_no1hit
# sa to sondy niezmapowane w zbiorze perfect

# Sekwencyjne usuwanie coraz gorszych dopasowan
# pierwszy krok ręcznie
# filtr, musi byc 69 sparowanych zasad
awk '$12-$13==69' o2v3_noperfect70_no1hit > x # dl. uliniowania - liczba mismaczy
cut -f14 -d" " x | sort -u > o2v3-69 # wydobycie kolumny oligo:gen
# tak samo dobre dla >1 oligo, czyli niezmapowane unikalnie
cut -f1 -d":" o2v3-69 | uniq -d > unmapped69id
# odsianie nieunikalnych ids ze zbioru
grep -Fwvf unmapped69id x > mapped69 # odsianie ze zbioru 69
grep -Fwvf unmapped69id o2v3_noperfect70_no1hit > x3 # odsianie ze zbioru wszystkich
# ids zmapowanych 69
cut -f1 -d" " mapped69 | sort -u | tr -d '>' > xmap69id
# usuniecie zmapowanych sond ze zbioru suboptymalnych
grep -Fwvf xmap69id x3 > xno69

# dalej krokowe wybieranie najlepszego unikalnego mapowania dla sond, coraz gorsze uliowanie, skrypt70.sh i lista polecen do wklejenia komendy70
# jeśli robione na pendrive to trzeba skrypt przekopiować na dysk komputera bo inaczej brak dostępu

################# skrypt70.sh JEST UNIWERSALNY!!! #######################

# Ewentualne usuwanie plikow dla uliniowania ponizej 19, reczne - to było potrzebne przy mapowaniu sond na NAM, tutaj NIE

# Usunięcie pustych plików
find . -type f -size 0b -delete

# polaczenie zmapowanych
cat o2v3_perfect70_combid_1hit mapped* > alluniqbest70

#*********************************************************************************************************************
#*********************** To samo dla sond 50nt ********************************
#*********************************************************************************************************************
# Podobnie dla sond 50nt
# dla porzadku w innym katalogu# Podobnie dla sond 50nt
# dla porzadku w innym katalogu
export LC_ALL=C
mkdir oligo50
cd oligo50
mv ../o2v3_hits50nt .
# wybor doskonalych dopasowan
awk '$11==50 && $12==50 && $13==0' o2v3_hits50nt > o2v3_perfect50
# wybor niedoskonalych dopasowan
awk '$11<50 || $12<50 || $13>0' o2v3_hits50nt > o2v3_noperfect50
# Odsianie par oligo:gen perfect ze zbioru noperfect
# dolaczenie ids
awk '{print $1":"$5}' o2v3_perfect50 | tr -d '>' | cut -f1 -d"_" > xperf50id
awk '{print $1":"$5}' o2v3_noperfect50 | tr -d '>' | cut -f1 -d"_" > xnoperf50id
paste -d" " o2v3_perfect50 xperf50id > o2v3_perfect50_combid
paste -d" " o2v3_noperfect50 xnoperf50id > o2v3_noperfect50_combid

# usuniecie z noperfect dodatkowych trafien dla par perfect
grep -Fwvf xperf50id o2v3_noperfect50_combid > o2v3_noperfect50_combid_noperfectid
# Czy mapowanie perfect sondy tylko dla jednego genu?
sort -u xperf50id > xperf50id_u
cut -f1 -d":" xperf50id_u | uniq -d > unmapped50id
# Odsianie multimammping perfect
grep -Fwvf unmapped50id o2v3_perfect50_combid > o2v3_perfect50_combid_1hit
# te oligo usuwam tez z noperfect
grep -Fwvf unmapped50id o2v3_noperfect50_combid_noperfectid > o2v3_noperfect50_combid_noperfectid_nounmpapped
# ids unikalnych sond z perfect trafieniami
cut -f1 -d" " o2v3_perfect50_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# odsianie trafien suboptymalnych dla sond z perfect trafieniami
grep -Fwvf ids_perf_1hit o2v3_noperfect50_combid_noperfectid_nounmpapped > o2v3_noperfect50_no1hit

# są to sondy niezmapowane w zbiorze perfect

# Sekwencyjne usuwanie coraz gorszych dopasowan
# filtr, musi byc 49 sparowanych zasad
awk '$12-$13==49' o2v3_noperfect50_no1hit > x
cut -f14 -d" " x | sort -u > o2gen49
# tak samo dobre dla >1 oligo
cut -f1 -d":" o2gen49 | uniq -d > unmapped49id

# nie ma takich, ale mogą być <49
# najłatwiej jest kontynuować procedurę jak zawsze

grep -Fwvf unmapped49id x > mapped49
grep -Fwvf unmapped49id o2v3_noperfect50_no1hit > x3
# ids zmapowanych 49
cut -f1 -d" " mapped49 | sort -u | tr -d '>' > xmap49id
grep -Fwvf xmap49id x3 > xno49

# skrypt70.sh i komendy_skryptu50

# usunięcie pustych plików
find . -type f -size 0b -delete

cat o2v3_perfect50_combid_1hit mapped* > alluniqbest50


#*********************************************************************************************************************
#*********************** To samo dla sond 40nt ********************************
#*********************************************************************************************************************
# Podobnie dla sond 40nt
# dla porzadku w innym katalogu
export LC_ALL=C
mkdir oligo40
cd oligo40
mv ../o2v3_hits40nt .
# wybor doskonalych dopasowan
awk '$11==40 && $12==40 && $13==0' o2v3_hits40nt > o2v3_perfect40
# wybor niedoskonalych dopasowan
awk '$11<40 || $12<40 || $13>0' o2v3_hits40nt > o2v3_noperfect40
# Odsianie par oligo:gen perfect ze zbioru noperfect
# dolaczenie ids
awk '{print $1":"$5}' o2v3_perfect40 | tr -d '>' | cut -f1 -d"_" > xperf40id
awk '{print $1":"$5}' o2v3_noperfect40 | tr -d '>' | cut -f1 -d"_" > xnoperf40id
paste -d" " o2v3_perfect40 xperf40id > o2v3_perfect40_combid
paste -d" " o2v3_noperfect40 xnoperf40id > o2v3_noperfect40_combid

# usuniecie z noperfect dodatkowych trafien dla par perfect
grep -Fwvf xperf40id o2v3_noperfect40_combid > o2v3_noperfect40_combid_noperfectid
# Czy mapowanie perfect sondy tylko dla jednego genu?
sort -u xperf40id > xperf40id_u
cut -f1 -d":" xperf40id_u | uniq -d > unmapped40id
# Odsianie multimammping perfect
grep -Fwvf unmapped40id o2v3_perfect40_combid > o2v3_perfect40_combid_1hit
# te oligo usuwam tez z noperfect
grep -Fwvf unmapped40id o2v3_noperfect40_combid_noperfectid > o2v3_noperfect40_combid_noperfectid_nounmpapped
# ids unikalnych sond z perfect trafieniami
cut -f1 -d" " o2v3_perfect40_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# odsianie trafien suboptymalnych dla sond z perfect trafieniami
grep -Fwvf ids_perf_1hit o2v3_noperfect40_combid_noperfectid_nounmpapped > o2v3_noperfect40_no1hit

# zostaly sondy niezmapowane w zbiorze perfect

# Sekwencyjne usuwanie coraz gorszych dopasowan
# filtr, musi byc 39 sparowanych zasad
awk '$12-$13==39' o2v3_noperfect40_no1hit > x

# nie ma takich

cut -f14 -d" " x | sort -u > o2gen39
# tak samo dobre dla >1 oligo
cut -f1 -d":" o2gen39 | uniq -d > unmapped39id
grep -Fwvf unmapped39id x > mapped39
grep -Fwvf unmapped39id o2v3_noperfect40_no1hit > x3
# ids zmapowanych 39
cut -f1 -d" " mapped39 | sort -u | tr -d '>' > xmap39id
grep -Fwvf xmap39id x3 > xno39

# skrypt70.sh i komendy_skryptu40

cat o2v3_perfect40_combid_1hit mapped* > alluniqbest40

#***************** Połączenie wszystkiego razem ***********************
mkdir bbest
cd bbest
cat ../oligo40/alluniqbest40 ../alluniqbest70 ../oligo50/alluniqbest50 | sort -k1,1 -t" " > allalluniqbest
# wybór MZ - GRMZ
cut -f1,5 -d" " allalluniqbest | tr -d '>' | sed 's/FGT/FG/;s/_T[0-9][0-9]//' | sort -k1,1 -t" " | sort -u > allall_ids

#********************** Połączenie trafień mz do v3 i NAM (dla których było >1 v3) ********************
# poziom /media/mj/ANTIX-LIVE/anno_fun_v45/map-multihit
join -j1 -t" " ../../map_probes/bbest_cdna/alluniq_best_ids bbest/allall_ids > mz2NAMv3
# unikalne przypisanie NAM do v3
cut -f2-3 -d" " mz2NAMv3 | sort -u > NAMv3
# zmiana separatora w przypisaniu NAM - v3 z maizeGDB
tr '\t' ' ' < NAM-v3-multihit > x
# wydobycie przypisań z maizeGDB zgodnych z mapowaniem MZ, cały wiersz jako wzorzec
grep -Fxf NAMv3 x > zgodne-mz-maizegdb

# Do niczego, i tak są wielokrotne NAM - v3
