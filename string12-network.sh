# Uniprot - NAM list
# /media/mj/ANTIX-LIVE/anno_fun_v45 directory
# Starting point: file Zm-B73-REFERENCE-NAM.UniProt.proteins.tab
grep 'Zm00001eb' Zm-B73-REFERENCE-NAM.UniProt.proteins.tab | cut -f1,6 -d" " | sort -k1,1 -t"      " > uniprot2nam
# There is multiple UniProt IDs for one NAM
# Unique NAM - 10492, there is 39756 genes in NAM (list in file genes_ids_v5)
#***************************************************************************************8

# I've found better mapping file.
# The idea is to merge mappings, and select best NAMv5 for each UniProt ID mapped to v4
https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-57/plants/tsv/zea_mays/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz
# sort by UniProt ID
zcat Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz | sort -k4,4 -t"  " > x
# 32796 NAM and 134901 UniProt IDS mapped -> there are multimappers

# UniProt - v4 list from STRING12
# /media/mj/ANTIX-LIVE/siec-ala-string directory
zgrep 'Zm00001d' 4577.protein.aliases.v12.0.txt.gz | cut -f1,2 -d"      " | cut -f2 -d"." | tr '_' '\t' | cut -f1,3 -d"       " | sort -k1,1 -t"      " > uniprot2v4
# There is 38140 unique UniProt IDs and 38515 unique v4 IDs

# Joining
join -1 4 -2 1 -t" " x ../siec-ala-string/uniprot2v4 > x2
# For network NAM protein IDs are not needed so they are filtered out to see if NAM - UniProt mapping is unique
cut -f1,2,10 -d"   " x2 | sort -u > x3
cut -f1 -d"        " x2 | sort | uniq -c | sed 's/ *//' | awk -v FS=" " '$1=="1"' | wc -l
# 29398 UniProt uniquelly mapped
cut -f1 -d"        " x2 | sort | uniq -c | sed 's/ *//' | awk -v FS=" " '$1>"1"' | wc -l
# 4194 UniProt multimmaped

# After discarding v4 IDs (they were only used for narrowing number of UniProt IDs) reamains 35414 rows
cut -f1,2 -d"      " x3 | sort -u | wc -l
# And 31858 unique and 1734 multimapping UniProts

# Now two things are possible:
# 1. select the best NAM for each UniProt based on alignment data
# 2. select NAM differentially expressed ina a given dataset and if needed 1. for them
