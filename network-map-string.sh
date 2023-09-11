# Mapping NAM (maize NAMv5) to STRING12 network using web interface
# As manual mapping NAM IDs to UP (UniProt) IDs generate many problems (many to many mapping, mapping not congruent with this in files from maize databases).

# Mapping require only one protein form per gene
# NAMv5 directory (on pendrive)
# 1. list of all proteins
export LC_ALL=C
awk -v FS="\t" -v OFS="\t" '$3=="transcript"{print $5-$4,$9}' Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf > x
# 2. selecting the longest form
tr '\t' ' ' < x | cut -f1,3,5 -d" " | tr -d '";' > x2
sort -k2,2 -k1,1nr -k3,3 -t" " x2 | sort -k2,2 -u > x3
wc -l x3
44303 x3
# IDs in all
expr 39756 + 4547
# it entails protein-conding + non-coding genes (congruent with info at gramene)
# cut only column with transcript IDs and translating to protein IDs
cut -f3 -d" " x3 | tr 'T' 'P' > prot-ids

# 3. selecting proteins from fasta (using scripts from exonerate bundle)
# indexing protein fasta
fastaindex -f Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.protein.fa -i Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.protein.in
# retrieving sequences, according to list of the longest protein for each gene
fastafetch -f Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.protein.fa -i Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.protein.in -q prot-ids -F > longest-prot.fa

# 4. Mapping in on-line STRING122 tool
