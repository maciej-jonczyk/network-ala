# Sieć wg STRING 12
# sieć wg ortologów wymuszałaby zbyt dużo arbitralnych wyborów.
# Poza tym string integruje wiele baz i pozwala sprawdzić

# Pierwszy krok to przekodowanie MZ - ekspresja na NAM - ekspresja.
# Odfiltrowanie NAM z MZ z niespójną ekspresją i uśrednienie tych ze spójną

#***************** ids4sed ***********************
# poziom /media/mj/ANTIX-LIVE/map_probes/bbest_cdna
cat ../oligo*/alluniqbest* > alluniqbest # połączenie plików z najlepszym mapowaniem mz do genów NAMv5
cut -f14 -d" " alluniqbest | sort -u | tr ':' ' ' > alluniq_best_ids
sed 's:^:\s/:;s: :\/:;s:$:\/:' alluniq_best_ids > ids4sed
#****************************************

#******************** istotne dla ali z pliku JMP ***************************
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

# dodatkowo zamiana taba na spację - wygodniej awk używać
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
# połązenie unikalnych i uśrednionych -> daje końcowy zbiór
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

# Końcowy wynik - lista unikalnych NAM z ekspresją
