# 0. NAM to V4 mapping
# concatenating files (retrieved from BiomaRt in five parts due to server limits)
cat genes_part0[0-9]v5* | grep -Fv 'input' > x
# how many fields? Test for 100 rows
head -n100 x | awk -v FS="\t" '{print NF}'
# wide to long format, based on https://stackoverflow.com/a/32850929/1040763
awk '{for(i=2;i<=NF;i++) print $1,$i}' x > NAM2v4-redund
## sorting by V4 (for joining with V4 annotation) and change separator
sort -k2,2 -t" " NAM2v4-redund | tr ' ' '\t' > x
# redund = long format
mv x NAM2v4-redund

# 1. combining direct annotations for NAM
# first file
Zm-B73-REFERENCE-NAM.UniProt.proteins.tab from MaizeGDB, quite old (02 mar 22)
https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/
# selecting rows with UP, regardless of presence of NAM (from old pipeline, now UPs are not used)
zcat Zm-B73-REFERENCE-NAM.UniProt.proteins.tab.gz | tr -d '\r' | cut -f1,6-9 -d"   " > UP-NAM-funct
# selecting only rows with NAM
awk -v FS="\t" -v OFS="\t" '$2~"Zm"{print $2,$5}' UP-NAM-funct | sort -u > UP-NAM-funct-noup
# how many unique IDs
cut -f1 -d"        " UP-NAM-funct-noup | sort -u | wc -l
10492

# second file
fulldownload.txt
https://download.maizegdb.org/GeneFunction_and_Expression/
# selecting rows with annotation
cut -f1,11,12 -d"  " fulldownload.txt | awk -v FS="\t" -v OFS="\t" '{print $1,$2"|"$3}' | grep -Fv " | " > NAM-funct

# Concatenating two annotation files using only NAMs
tail -n +2 NAM-funct > x
# at the same time sorting uniquelly ignoring case and remove noninformatie annotations
cat x UP-NAM-funct-noup | sort -uf | grep -Fwv 'Uncharacterized' > NAM-funct-all
# is that lessen number of annotated IDs?
cat x UP-NAM-funct-noup | sort -u | grep -Fwv 'Uncharacterized' | cut -f1 -d"      " | sort -u | wc -l
14469
cat x UP-NAM-funct-noup | sort -u | cut -f1 -d"    " | sort -u | wc -l
15807
# Yes

# 2. Concatenation of annotations for V4
# first file, extracting only V4 and annotation (with some filtering)
cut -f1,2 -d"      " B73v4.gene_function.txt | sort -u | grep -Fvw 'Expressed protein;  protein' > x
# 29793 unique IDs annotated

# second file
zcat Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.full_gene_data.txt.gz  | tr -s " " | awk -v FS="\t" -v OFS="\t" '$14!=" "||$15!=" " {print $1,$14"|"$15}' | sort -u > x6
tail -n +2 x6 > x7
# combining and uniquely sort
cat x x7 | sort -uf > V4-funct

# Translate to NAM Using NAM2v4-redund
join -1 2 -2 1 -t" " NAM2v4-redund V4-funct > V4-NAM-funct
# leaving only NAM and annotation
cut -f2,3 -d"      " V4-NAM-funct | sed 's/\t /\t/g' | sort -uf > V4-NAM-funct-nov4

# 3. Combining all annotations (with some tidying-up)
cat NAM-funct-all V4-NAM-funct-nov4 | sed 's/ $//;s/|$//;s/ |$//' | sort -uf > anno-all
# long to wide format
awk -v FS="\t" -v OFS="\t" '{a[$1]=a[$1] FS $2} END{for(i in a) print i a[i]}' anno-all | sort -k1,1 -t"   " | sed 's/\t/|/2g' > anno-all-wide
