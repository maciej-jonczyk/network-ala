# Network according to STRING 12
# network according to orthologues would enforce to many arbitraly choices.
# Bestides STRING integrates multiple databases

# The first step is converting MZ - expression to NAM - expression.
# Filtering-out NAMs for which MZs have ambiguous expression (both up- and downregulated). Averaging values for NAMs with congruent expression.

#***************** ids4sed ***********************
# level /media/mj/ANTIX-LIVE/map_probes/bbest_cdna
cat ../oligo*/alluniqbest* > alluniqbest # concatenating files with best MZ - NAM mpping
cut -f14 -d" " alluniqbest | sort -u | tr ':' ' ' > alluniq_best_ids
sed 's:^:\s/:;s: :\/:;s:$:\/:' alluniq_best_ids > ids4sed
#****************************************

#******************** significant genes from Alas dataset created orginally in JMP Genomics ***************************
# Set locale for terminal session (temporary)
export LC_ALL=C

# sigalaimp2_27.txt - result from JMP Genomics
# colun names typed-in manually
cut -f1,19-36,65-67,74-76 -d"	"  sigalaimp2_27.txt > x # (TAB-separated)
awk -v FS="\t" -v OFS="\t" '{print $1,($2+$3+$4)/3,($5+$6+$7)/3,($8+$9+$10)/3,($11+$12+$13)/3,($14+$15+$16)/3,($17+$18+$19)/3,$20,$21,$22,$23,$24,$25}' \
x > sr-wariant
awk -v FS="\t" -v OFS="\t" '{print $1,$2-$5,$3-$6,$4-$7,$8,$9,$10,$11,$12,$13}' sr-wariant > srroznica-wariant
awk -v FS="\t" -v OFS="\t" '$8!=0 || $9!=0 || $10!=0' srroznica-wariant > srroznica-ist-wariant
awk -v FS="\t" '{printf "%s\t%.2f\t%.2f\t%.2f\n", $1,$2*$8,$3*$9,$4*$10}' srroznica-ist-wariant | sed 's/-0.00/0.00/g' > sr-ist-ost 
#****************************************

# changing TAB to space - more convenient for awk
sed -f ../../map_probes/bbest_cdna/ids4sed sr-ist-ost > ala_NAM_ist_diff
# how much mapped
cut -c1-2 ala_NAM_ist_diff | sort | uniq -c
      1 ID
   1426 MZ
  11416 Zm
# > 10% mapped

# /media/mj/ANTIX-LIVE/ist_mm_faire/ala level
# ala_NAM_ist_diff is source file for selecting genes for network
# S16 line
# genes with values not equal 0 for s16 line
awk '$1~"Zm" && $2!=0.00{print $1,$2}' ala_NAM_ist_diff > x16all
# space-separated data - avoids specifying separator in awk
# selecting duplicated Zm (>1 MZ matching the same NAM gene)
cut -f1 -d" " x16all | sort | uniq -c | sed 's/^ *//' | awk '$1>1{print $2}' > x16zdup
# data for duplicated MZs
grep -Fwf x16zdup x16all | sort -k1,1 > x16zdup_dane
# extreme values
sort -k1,1 -k2,2nr x16zdup_dane | sort -k1,1 -u > x16max
sort -k1,1 -k2,2n x16zdup_dane | sort -k1,1 -u > x16min
join -j1 -t" " x16min x16max > x16minmax
# selecting amibguous
awk '$2<0 && $3>0' x16minmax > x16niesp
# ids of ambiguous
cut -f1 -d" " x16niesp > x16_niesp_id
# selecting congruent MZs for averaging
grep -Fvwf x16_niesp_id x16minmax | cut -f1 -d" " > x16dousr_id
grep -Fwf x16dousr_id x16zdup_dane > x16dousr_dane


# The same for S50 line
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

#  The same for S68 line
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

# Averaging in R - file duplik030223.r

# Exported files: sr16, sr50, sr68

# S16 line
# Rounding values
awk '{printf "%s %.2f\n", $1,$2}' sr16 | tail -n +2 > x
mv x sr16
# IDs of averaged
cut -f1 -d" " sr16 > x16idsusr
# all IDs for duplicated genes
cat x16_niesp_id x16idsusr > x
# results for all unique
grep -Fvwf x x16all > x16unikalne
# concatenating unique and averaged -> gives final dataset
cat x16unikalne sr16 | sort -k1,1 > ok16

# the same for S50 line
awk '{printf "%s %.2f\n", $1,$2}' sr50 | tail -n +2 > x
mv x sr50
cut -f1 -d" " sr50 > x50idsusr
cat x50_niesp_id x50idsusr > x
grep -Fvwf x x50all > x50unikalne
cat x50unikalne sr50 | sort -k1,1 > ok50

# The same for S68 line
awk '{printf "%s %.2f\n", $1,$2}' sr68 | tail -n +2 > x
mv x sr68
cut -f1 -d" " sr68 > x68idsusr
cat x68_niesp_id x68idsusr > x
grep -Fvwf x x68all > x68unikalne
cat x68unikalne sr68 | sort -k1,1 > ok68

# The final result - lists of unique NAM with expression (log2(cold-control) )
