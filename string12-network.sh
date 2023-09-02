# Uniprot - NAM list
# /media/mj/ANTIX-LIVE/anno_fun_v45 directory
# Files needed
# 1. NAM - UniProt mapping Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz (https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-57/plants/tsv/zea_mays/)
# 2. UniProt - v4 mapping from STRING12 4577.protein.aliases.v12.0.txt.gz
# 3. List of differentially expressed NAMs
# The idea is to select NAM IDs matching UniProt IDs from STRING12.
# From this list DE NAMs will be selected and for multimapped the best UniProt will be selected
https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-57/plants/tsv/zea_mays/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz

# list of UniProts in STRING12
# /media/mj/ANTIX-LIVE/siec-ala-string directory
zcat 4577.protein.aliases.v12.0.txt.gz | cut -f1 | tail -n +2 | cut -f2 -d"." | sort -u > uniprot.list
# 39389 unique

# /media/mj/ANTIX-LIVE/anno_fun_v45/ directory
zcat Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz | sort -k4,4 -t"  " >xnamuniprotsrt
join -1 1 -2 4 -t" " ../siec-ala-string/uniprot.list xnamuniprotsrt | tr '\t' ' '> xnam-string
# changing TAB to space for easier joining with expression values
# in all 40451 rows.
# 36501 unique gene-UniProt rows, in this 34555 unique UniProts and 29808 unique genes - so there is multimapping
# Selecting could be done also with grep but it selects also splicing forms, ie. UniProt IDs with subscript -1 or -2

# Choosing the best UniProt for NAM
# checking column names
zcat Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz | head
# for each NAM selecting hit with the best "source_identity" (column 7)
# if there is no data simply first UniProt is selected
LC_ALL=C sort -k2,2 -k7,7rn -t" " xnam-string | sort -u -k2,2 -t" " > x
mv x xbest-nam-string

# The next step - selecting NAMs DE in Alas dataset
# change to ../siec-ala-string/
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok16 ../anno_fun_v45/xbest-nam-string > xok16uniprot
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok50 ../anno_fun_v45/xbest-nam-string > xok50uniprot
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok68 ../anno_fun_v45/xbest-nam-string > xok68uniprot
wc -l xok*
   3431 xok16uniprot
   5515 xok50uniprot
   5325 xok68uniprot
# number of unique genes
for i in 16 50 68 ; do cut -f1 -d" " xok${i}uniprot | sort -u | wc -l ; done
3431
5515
5325
# number of unique UniProts
for i in 16 50 68 ; do cut -f3 -d" " xok${i}uniprot | sort -u | wc -l ; done 
3420
5489
5308

# Subsetting STRING 12 network to include only interactions for UniProts in xok... files
# joining xok... files and retrieving only IDs
cat xok* | cut -f3 -d" " | sort -u > xup-in-sigs
# removing unnecessary prefix from UniProts in whole network
zcat 4577.protein.links.full.v12.0.txt.gz | sed 's/4577\.//g' > xfull
# Selecting significant UniProts
grep -Fwf xup-in-sigs xfull > xinala
# it seems that there is more UniProts in 4577.protein.aliases.v12.0.txt.gz than in 4577.protein.links.full.v12.0.txt.gz
wc -l uniprot.list 
39389 uniprot.list
cut -f2 -d" " xfull > x2
cut -f1 -d" " xfull > x
cat x x2 | sort -u | wc -l
34011

