# Uniprot - NAM list
# /media/mj/ANTIX-LIVE/anno_fun_v45 directory
# Files needed
# 1. NAM - UniProt mapping Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz
# 2. UniProt - v4 mapping from STRING12 4577.protein.aliases.v12.0.txt.gz
# 3. List of differentially expressed NAMs
# The idea is to select NAM IDs matching UniProt IDs from STRING12.
# From this list DE NAMs will be selected and for multimapped the best UniProt will be selected
https://ftp.ebi.ac.uk/ensemblgenomes/pub/release-57/plants/tsv/zea_mays/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz

# list of UniProts in STRING12
# /media/mj/ANTIX-LIVE/siec-ala-string directory
zcat 4577.protein.aliases.v12.0.txt.gz | cut -f1 | tail -n +2 | cut -f2 -d"." | sort -u > uniprot.list
# 39389 unique

zcat Zea_mays.Zm-B73-REFERENCE-NAM-5.0.57.uniprot.tsv.gz | sort -k4,4 -t"  " >x
join -1 1 -2 4 -t" " ../siec-ala-string/uniprot.list x > x2
# Selecting could be done also with grep but it selects also splicing forms, ie. UniProt IDs with subscript -1 or -2

# The next step - selecting NAMs DE in Alas dataset
