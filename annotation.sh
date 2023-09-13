export LC_ALL=C
# 1. NAM annotations, both files are TAB-delimited
# file 1.
cut -f1,11,12 -d"	" fulldownload.txt | awk -v FS="\t" -v OFS="\t" '{print $1,$2"|"$3}' | grep -Fv " | " > NAM-funct
tail -n +2 NAM-funct > x

# file 2.
zcat Zm-B73-REFERENCE-NAM.UniProt.proteins.tab.gz | tr -d '\r' | cut -f1,6-9 -d"	" > UP-NAM-funct
awk -v FS="\t" -v OFS="\t" '$2~"Zm"{print $2,$5}' UP-NAM-funct | sort -u > UP-NAM-funct-noup
cat x UP-NAM-funct-noup | sort -uf | grep -Fwv 'Uncharacterized' > NAM-funct-all

# 2. NAM - V4 mapping (retrieved from web Gramene BioMart using NAMs for protein-coding genes <list retrieved from gff>)
cat genes_part0[0-9]v5* | grep -Fv 'input' > x
awk '{for(i=2;i<=NF;i++) print $1,$i}' x > NAM2v4-redund
# change delimiter to TAB
sort -k2,2 -t" " NAM2v4-redund | tr ' ' '\t' > x
mv x NAM2v4-redund

# 3. V4 annotations, again - both files TAB-delimited
## file 1.
zcat Zm-B73-REFERENCE-GRAMENE-4.0_Zm00001d.2.full_gene_data.txt.gz  | tr -s " " | awk -v FS="\t" -v OFS="\t" '$14!=" "||$15!=" " {print $1,$14"|"$15}' | sort -u > x6
tail -n +2 x6 > x7
## file 2.
cut -f1,2 -d"	" B73v4.gene_function.txt | sort -u | grep -Fvw 'Expressed protein;  protein' > x
cat x x7 | sort -uf > V4-funct
join -1 2 -2 1 -t"	" NAM2v4-redund V4-funct > V4-NAM-funct
# V4-NAM-funct is TAB-delimited
cut -f2,3 -d"	" V4-NAM-funct | sed 's/\t /\t/g' | sort -uf > V4-NAM-funct-nov4

# 4. Combining annotations from both genomes 
cat NAM-funct-all V4-NAM-funct-nov4 | sed 's/ $//;s/|$//;s/ |$//' | sort -uf > anno-all
awk -v FS="\t" -v OFS="\t" '{a[$1]=a[$1] FS $2} END{for(i in a) print i a[i]}' anno-all | sort -k1,1 -t"	" | sed 's/\t/|/2g' > anno-all-wide
