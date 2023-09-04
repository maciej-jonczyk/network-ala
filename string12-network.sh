# Uniprot - NAM list
# /media/mj/ANTIX-LIVE/anno_fun_v45 directory
# Files needed
# I. NAM - UniProt mapping Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz
https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-57/plants/tsv/zea_mays/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz
# II. Full STRING 12 network for maize (4577.protein.links.full.v12.0.txt.gz)
# III. List of differentially expressed NAMs
# The idea is to select NAM IDs matching UniProt IDs from STRING12.
# From this list DE NAMs will be selected and for multimapped the best UniProt will be selected

# 1. only UniProts (UPs) from network file itself
# checking network file
zcat 4577.protein.links.full.v12.0.txt.gz | head -2
zcat 4577.protein.links.full.v12.0.txt.gz | head -2 | cat -A
# file is space-separated
zcat 4577.protein.links.full.v12.0.txt.gz | wc -l
23274375
# retrieving only UPs
cut -f1,2 -d" " <(zcat 4577.protein.links.full.v12.0.txt.gz) > x
tr ' ' '\n' < x > x2
# checking file
wc -l x2
46548750 x2
expr 23274375 \* 2
46548750
# selecting unique UPs
sort -u x2 > x3
wc -l x3
34011 x3
# tidying-up file
grep -v 'protein' x3 | sed 's/4577\.//' > x4
wc -l x4
# 34009 UPs in full network

# 2. Selecting UPs present in network from file mapping UP-NAM
# checking the mapping file
head -n1 ../anno_fun_v45/xnamuniprotsrt | cat -A
# file is TAB-separated
join -1 1 -2 4 -t"	" x4 ../anno_fun_v45/xnamuniprotsrt | tr '\t' ' '> xnam-string
# Selecting could be done also with grep but it selects also splicing forms, ie. UniProt IDs with subscript -1 or -2

# 3. Choosing the best UP for each NAM
# checking column numbers
head -n1 xnam-string | tr ' ' '\n' | cat -n
# setting locale to ensure proper sorting
LC_ALL=C sort -k2,2 -k7,7rn -t" " xnam-string | sort -u -k2,2 -t" " > x5
# checking file
cut -f2 -d" " x5 | sort -u | wc -l
33629
mv x5 xbest-nam-string

# 4. The next step - selecting NAMs DE in Ala's dataset
# checking files
head -n2 xbest-nam-string
head -n2 ../ist_mm_faire/ala/ok16
head -n2 ../ist_mm_faire/ala/ok50
head -n2 ../ist_mm_faire/ala/ok68
# joining expression valies and network data - only shared UPs remain
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok16 xbest-nam-string > xok16uniprot
less xok16uniprot
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok50 xbest-nam-string > xok50uniprot
less xok50uniprot
join -1 1 -2 2 -t" " ../ist_mm_faire/ala/ok68 xbest-nam-string > xok68uniprot
less xok68uniprot
# checkin files
wc -l xok16uniprot
3330 xok16uniprot
wc -l xok50uniprot
5352 xok50uniprot
wc -l xok68uniprot
5169 xok68uniprot

# 5. Subsetting STRING 12 network to include only interactions for UniProts in xok... files
# joining xok... files and retrieving only UPs
cat xok* | cut -f3 -d" " | sort -u > xup-in-sigs
# removing unnecessary prefix from UniProts in whole network
zcat 4577.protein.links.full.v12.0.txt.gz | sed 's/4577\.//g' > xfull

# 6. selecting UPs with expression data from full hetwork
grep -Fwf xup-in-sigs xfull > xfull-ala
# adding header
head -n1 xfull > xnagl
cat xnagl xfull-ala > x5
mv x5 xfull-ala
wc -l xfull-ala   
11560375 xfull-ala
# how much unique UPs in selected subnetwork?
cut -f1,2 -d" " xfull-ala | tr ' ' '\n' | grep -v 'protein' | sort -u > x5
wc -l x5
33629 x5
# are all UPs from Ala's file in subnetwork?
grep -Fwf xup-in-sigs x5 | wc -l
wc -l xup-in-sigs
# yes

# Loading network (xfull-ala) to Cytoscape
# if program returns error and not launch run:
export EXTRA_JAVA_OPTS="-Djdk.util.zip.disableZip64ExtraFieldValidation=true"
# Network is too huge to be loaded - filtering on "Combined score" is needed

# 7. Retrieving "Combined score" for histogram plotting in R
# checking column numbers
head -n1 xfull-ala | tr ' ' '\n' | cat -n
cut -f16 -d" " xfull-ala > x6

# histogram construction in R - in file score-hist.r
# No obvious cut-off visible from histograms - standard (ie. previously used) value of 400 will be used
# settig locale to ensure that awk will work correctly
export LC_ALL=C
echo $LC_ALL
C
awk '$16>=400' xfull-ala > xfull-ala400
# checking file
wc -l xfull-ala400
1957023 xfull-ala400
cut -f16 -d" " xfull-ala400 | sort -k1,1n | head
