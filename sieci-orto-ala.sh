# Pobranie danych dla At. z bazy maentha (integruje dane z 5 baz)
https://www.mentha.uniroma2.it/download.php

# Ortologi At-Zm
# ids wszystkich genów w v5
/media/mj/ANTIX-LIVE/map_probes/genes_ids_v5
wc -l genes_ids_v5
39756
# wydobycie ortologów z BioMart w przeglądarce
/media/mj/ANTIX-LIVE/intact/orto_zm_at
# tylko te, co maja ortologa w at
awk -v FS="\t" -v OFS="\t" '$3!=""' mart_export.txt > orto
# ile genów ma ortologi
cut -f1 -d"    " orto | sort -u | grep -v 'Gene' | wc -l
19760 # czyli połowa

# Proba dla wszystkich roślinnych
# plik all.zip z mentha
# rozpakowanie i wydobycie unikalnych IDs
cut -f3 -d";" 2023-05-29 > x
cut -f6 -d";" 2023-05-29 > x2
cat x x2 | sort -u | grep -v 'Taxon' > xuniqtaxids
# i ręczne usunięcie dwóch pierwszych wierszy
# przerobienie na rozdzialane spacją
tr '\n' ' ' < xuniqtaxids > xuniqtaxids2

# mapowanie IDs bo sieć nie zawiera nazw gatunków
# Pobranie ncbi-taxonomist
pip install ncbi-taxonomist --user

# Wydobycie tabeli
ncbi-taxonomist resolve -t `cat xuniqtaxids2` -r -e MAIL-ADDRESS > xidstax

# Daje to dużo danych, wydobycie roślin zielonych
grep -i 'Viridiplantae' xidstax > xviridiplantae
 
cut -f2 -d"," xviridiplantae | sort -u | wc -l
68 gatunków

# ids gatunków roślin
cut -f2 -d',' xviridiplantae | cut -f2 -d":" | sed 's/"//g' > xplantids

# wydobycie roślin z pełnego zbioru mentha
grep -wf xplantids 2023-05-29 > xplant

# IDs i nazwa gatunku
cut -f2,6 -d"," xviridiplantae | tr ',' ':' | cut -f2,4 -d":" | tr ':' '\t' | sed 's/"//g;s/{//' > id-species

# Wydobycie białek wg ID
# najpierw baiałko i ID
cut -f1,3 -d";" xplant | sort -u > x
cut -f4,6 -d";" xplant | sort -u > x2
cat x x2 | sort -u > prot-id

# z tego wybieranie IDs wg gatunków, ręcznie pojedynczo
# jaki gatunek?
grep -w '4097' id-species

# odfiltrowanie gatunków niebędących w gramene
# plik ze strony 
https://ensembl.gramene.org/species.html
cut -f4 -d"," Species.csv | sed 's/"//g' | sort -u > /media/mj/ANTIX-LIVE/intact/zmentha/species-gramene
grep -wf species-gramene id-species > x
# oprócz tych jest jeszcze Brassica oleracea

# białka, IDs wg pliku x
featherpad x &
grep -w '4097' prot-id | cut -f1 -d";" | sort -u

4577 
# to kukurydza
# dla niej tylko wydobycie mapowania uniprot - gene stable id

# wydobycie w gramene Mart
# nie da się od razu uniprot - ortolog Zm
# query to uniprot
# wydobywanie mapowania uniprot - gene stable id
# osobno gene stable id - Zea mays gene stable ID + %id. target Zea mays gene identical to query gene + %id. query gene identical to target Zea mays gene + Zea mays orthology confidence [0 low, 1 high] 

# Połączenie ortologów, wydaje się, że można "na ślepo" bo przy join i tak bedą pasować do swoich
# Czy to się opłaca? Sprawdzenie liczebności dla gatunków
cat *orto.txt | awk -v FS="\t" -v OFS="\t" '$3!=""' | cut -c1-2 | sort | uniq -c
# osobno dla swiss i trembl
cat tr*orto.txt | awk -v FS="\t" -v OFS="\t" '$3!=""' | cut -c1-2 | sort | uniq -c
cat [^t]*orto.txt | awk -v FS="\t" -v OFS="\t" '$3!=""' | cut -c1-2 | sort | uniq -c

# Połączenie IDs, można zrobić dla całości bo ta sama kolejność w trembl i swiss
# sprawdzenie
head -n1 *ids.txt
# Niektóre są odwrotnie, zamiana kolumn
awk -v FS="\t" -v OFS="\t" '{print $2,$1}' solanum_tuberosum_ids.txt > x
mv x solanum_tuberosum_ids.txt
awk -v FS="\t" -v OFS="\t" '{print $2,$1}' hordeum_vulgare_ids.txt > x
mv x hordeum_vulgare_ids.txt

# połączenie
cat *ids.txt | sort -u | sort -k1,1 -t"    " | grep -v 'Gene' > allids

# Połączenie plików z orto
# sprawdzenie kolejności kolumn
head -n1 tr_vitis_orto.txt | tr '\t' '\n' | cat -n # dla każdego pliku osobno i poprawienie kolejności - polecenia cut albo awk
cat *orto.txt | awk -v FS="\t" -v OFS="\t" '$2!=""' | grep -v 'Gene' | sort -u | sort -k1,1 -t"    " > allorto

# Połączenie mapowania IDs i ortologów
join -j1 -t"       " allids allorto > allidsorto

#******************************************************************************************************
# Wybór najlepszych ortologów
# zamiana tab-ów na spacje, żeby łatwiej awk robić
tr '\t' ' ' < allidsorto > x
mv x allidsorto

# 1. geny Zm dla których są oddziaływania kukurydzy
# poziom /media/mj/ANTIX-LIVE/intact/zmentha/orto-z-biomart/zea
cat * |cut -f1 -d"     " | grep -v "Gene"|sort -u>siec-ids-zea

# 2. odfiltrowanie ich z listy istotnych w ala
grep -Fvwf siec-ids-zea ../../../../ist_mm_faire/ala/ok_alluniq_ids > xids_nozea

# 3. Opcja 1. najlepsze nzal od gatunku
# Wybór najlepszych hi-conf, wszystkie gat traktowane równorzędnie
# poziom /media/mj/ANTIX-LIVE/intact/zmentha/orto-z-biomart 
# dołączenie IDS uniprot do zbioru ortologóœ
sort -k1,1 -t"     " allids > x
mv x allids
sort -k1,1 -t"     " allorto > x
mv x allorto
join -j1 -t"       " allids allorto | sort -u > allidsorto
# średni % ident
awk -v FS="\t" '{print $2,$3,($4+$5)/2,$6}' allidsorto > xsrperc
# Najlepszy ortolog dla danego Zm, uwzględniając hi-confidence
# Może jeden uniprot pasować do >1 Zm !!!
sort -k2,2 -k4,4nr -k3,3nr xsrperc | sort -k2,2 -u > best-srperc

# 4. wydobycie info dla Zm istotnych w ala
grep -Fwf zea/xids_nozea best-srperc > xorto-istala

# %. Połączenie istotnych w trzech liniach i xorto-istala
# poziom /media/mj/ANTIX-LIVE/ist_mm_faire/ala
join -j1 -t" " -a1 -a2 -o0,1.2,2.2 ok16 ok50 > x
join -j1 -t" " -a1 -a2 -o0,1.2,1.3,2.2 x ok68 > x2
sed 's/  / 0.00 /;s/  / 0.00 /;s/ $/ 0.00/' x2 > okall
# odcięcie tych Zm dla których jest sieć w mentha
grep -Fwf ../../intact/zmentha/orto-z-biomart/zea/xids_nozea okall > xokall-nozea

sort -k1,1 -t" " xokall-nozea > x
mv x xokall-nozea
sort -k2,2 -t" " xorto-istala > x
mv x xorto-istala

# Są zwielokrotonine uniprot, pasujące do różnych Zm (o różnej ekspresji). Dochodzi sprawa różnych istotnych w różnych liniach
join -1 2 -2 1 -t" " xorto-istala ../../../ist_mm_faire/ala/xokall-nozea | sort -k2,2 -k4,4nr -k3,3nr > xorto-istala-nozea

# Ortologi Zm-At (najważniejsze, bo utworzą największą sieć)
# Dalej
# wyszukanie poprzedniego sposobu filtrowania ortologów
# mz zgodna/niezgodna ekspresja
# hi confidence?

# Dokopanie się do sposobu wyboru jak tylko dla At ortologi robiłem

#***************** ids4sed ***********************
cat ../oligo*/alluniqbest* > alluniqbest # połączenie plików z najlepszym mapowaniem mz do genów NAMv5
cut -f14 -d" " alluniqbest | sort -u | tr ':' ' ' > alluniq_best_ids
sed 's:^:\s/:;s: :\/:;s:$:\/:' alluniq_best_ids > ids4sed
#****************************************

#******************** ala_mz_ist_diff (a raczej poprawiona wersja) ***************************
# Ustawienie locale dla sesji terminala (nie permanentne)
export LC_ALL=C

# sigalaimp2_27.txt to wynik z JMP
# nazwy kolumn wpisywane ręcznie
cut -f1,19-36,65-67,74-76 -d"	"  sigalaimp2_27.txt > x # (separator to tabulator)
awk -v FS="\t" -v OFS="\t" '{print $1,($2+$3+$4)/3,($5+$6+$7)/3,($8+$9+$10)/3,($11+$12+$13)/3,($14+$15+$16)/3,($17+$18+$19)/3,$20,$21,$22,$23,$24,$25}' \
x > sr-wariant
awk -v FS="\t" -v OFS="\t" '{print $1,$2-$5,$3-$6,$4-$7,$8,$9,$10,$11,$12,$13}' sr-wariant > srroznica-wariant
awk -v FS="\t" -v OFS="\t" '$8!=0 || $9!=0 || $10!=0' srroznica-wariant > srroznica-ist-wariant
awk -v FS="\t" '{printf "%s\t%.2f\t%.2f\t%.2f\n", $1,$2*$8,$3*$9,$4*$10}' srroznica-ist-wariant | sed 's/-0.00/0.00/g' > sr-ist-ost 
#****************************************

# Ustawienie locale dla sesji terminala (nie permanentne)
export LC_ALL=C

# dodatkowo jednak zamiana taba na spację
sed -f ../../map_probes/bbest_cdna/ids4sed sr-ist-ost > ala_NAM_ist_diff
# ile zmapowanych
cut -c1-2 ala_NAM_ist_diff | sort | uniq -c
      1 ID
   1426 MZ
  11416 Zm
# czyli > 10% jest niezmapowanych

# Od ala_NAM_ist_diff zaczyna się poprawianie wyboru genów do sieci
# S16
# geny i nie 0 dla linii s16
awk '$1~"Zm" && $2!=0.00{print $1,$2}' ala_NAM_ist_diff > x16all
# separatorem jest spacja - zeby nie zmieniac ciagle w awk
# wybór zduplikowanych Zm (czyli >1 MZ pasował do tego samego Zm)
cut -f1 -d" " x16all | sort | uniq -c | sed 's/^ *//' | awk '$1>1{print $2}' > x16zdup
# dane dla zduplikowanych
grep -Fwf x16zdup x16all | sort -k1,1 > x16zdup_dane
# skrajne wartości
sort -k1,1 -k2,2nr x16zdup_dane | sort -k1,1 -u > x16max
sort -k1,1 -k2,2n x16zdup_dane | sort -k1,1 -u > x16min
join -j1 -t" " x16min x16max > x16minmax
# wybor niespojnych
awk '$2<0 && $3>0' x16minmax > x16niesp
# ids niespojnych
cut -f1 -d" " x16niesp > x16_niesp_id
# wybor spojnych do usrednienia
grep -Fvwf x16_niesp_id x16minmax | cut -f1 -d" " > x16dousr_id
grep -Fwf x16dousr_id x16zdup_dane > x16dousr_dane


# S50
awk '$1~"Zm" && $3!=0.00{print $1,$3}' ala_NAM_ist_diff > x50all
cut -f1 -d" " x50all | sort | uniq -c | sed 's/^ *//' | awk '$1>1{print $2}' > x50zdup
grep -Fwf x50zdup x50all | sort -k1,1 > x50zdup_dane
sort -k1,1 -k2,2nr x50zdup_dane | sort -k1,1 -u > x50max
sort -k1,1 -k2,2n x50zdup_dane | sort -k1,1 -u > x50min
join -j1 -t" " x50min x50max > x50minmax
awk '$2<0 && $3>0' x50minmax > x50niesp
cut -f1 -d" " x50niesp > x50_niesp_id
grep -Fvwf x50_niesp_id x50minmax | cut -f1 -d" " > x50dousr_id
grep -Fwf x50dousr_id x50zdup_dane > x50dousr_dane

#  S68
awk '$1~"Zm" && $4!=0.00{print $1,$4}' ala_NAM_ist_diff > x68all
cut -f1 -d" " x68all | sort | uniq -c | sed 's/^ *//' | awk '$1>1{print $2}' > x68zdup
grep -Fwf x68zdup x68all | sort -k1,1 > x68zdup_dane
sort -k1,1 -k2,2nr x68zdup_dane | sort -k1,1 -u > x68max
sort -k1,1 -k2,2n x68zdup_dane | sort -k1,1 -u > x68min
join -j1 -t" " x68min x68max > x68minmax
awk '$2<0 && $3>0' x68minmax > x68niesp
cut -f1 -d" " x68niesp > x68_niesp_id
grep -Fvwf x68_niesp_id x68minmax | cut -f1 -d" " > x68dousr_id
grep -Fwf x68dousr_id x68zdup_dane > x68dousr_dane

# Plik duplik030223.r

# Wyeksportowane pliki: sr16, sr50, sr68

# S16
# Zaokrąglenie
awk '{printf "%s %.2f\n", $1,$2}' sr16 | tail -n +2 > x
mv x sr16
# ids usrednionych
cut -f1 -d" " sr16 > x16idsusr
# wszystkie IDs genów zduplikowanych
cat x16_niesp_id x16idsusr > x
# wyniki dla wszystkich unikalnych
grep -Fvwf x x16all > x16unikalne
# połązenie unikalnychi uśrednionych -> daje końcowy zbiór
cat x16unikalne sr16 | sort -k1,1 > ok16

# S50
awk '{printf "%s %.2f\n", $1,$2}' sr50 | tail -n +2 > x
mv x sr50
cut -f1 -d" " sr50 > x50idsusr
cat x50_niesp_id x50idsusr > x
grep -Fvwf x x50all > x50unikalne
cat x50unikalne sr50 | sort -k1,1 > ok50

# S68
awk '{printf "%s %.2f\n", $1,$2}' sr68 | tail -n +2 > x
mv x sr68
cut -f1 -d" " sr68 > x68idsusr
cat x68_niesp_id x68idsusr > x
grep -Fvwf x x68all > x68unikalne
cat x68unikalne sr68 | sort -k1,1 > ok68


# Lista IDs
cat ok[0-9][0-9] | cut -f1 -d" " | sort -u > ok_alluniq_ids

#*********************** ostatecznie niepotrzebny i tak ręcznie musiałem zrobić ***************************
# Zbiór wszystkich ortologów z ftp
https://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-56/tsv/ensembl-compara/homologies/
# wydobycie kukurydzianych
zgrep -i 'zea_mays' Compara.109.protein_default.homologies.tsv.gz > compara-zm
wc -l compara-zm
5013966
#**********************************************************************************************************

