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

# how many proteins are in network?
zcat STRG0A98KWY.protein.links.full.v12.0.txt.gz | cut -f1 -d" " | tail -n +2 | sort -u | wc -l
31878

# so 80% of protein-coding genes are included in the network
# network constructed with NAM-UP mapping gave 33629 UPs so slightly higher percent

# 5. Preparing network for Cytoscape and joining with expression values
# deleting not needed strings
zcat STRG0A98KWY.protein.links.full.v12.0.txt.gz | sed 's/STRG0A98KWY\.//g;s/_P00[0-9]//g' > net-full

# 6. Separate network for each maize line - joining with appropriate expression file
# does each ID is present in the 1st column - which become "source node"?
cut -f1 -d" " net-full | tail -n +2 | sort -u > x
cut -f1,2 -d" " net-full | tail -n +2 | tr ' ' '\n' | sort -u > x2
wc -l x x2
comm -3 x x2
# yes
# so "net-full" and expression file can be joined by "source node"
# test for s16
tail -n +2 net-full | sort -k1,1 -t" " > xnet-full
# header
head -n1 net-full > xhead
awk '{print $0,"expr"}' xhead > xhead2
# joining network and expression
join -j1 -t" " xnet-full ../../ist_mm_faire/ala/ok16 > xnet16
cat xhead2 xnet16 > net16
# network too large for visualisation inCytoscape - filtering needed
# as in #7. of string12-network.sh and again no clear cut-off for "combined score"
# Both score and expression filtering can be done in Cytoscape

# networks for other twolines
join -j1 -t" " xnet-full ../../ist_mm_faire/ala/ok50 > xnet50
cat xhead2 xnet50 > net50
head -n2 net50
join -j1 -t" " xnet-full ../../ist_mm_faire/ala/ok68 > xnet68
cat xhead2 xnet68 > net68

# how many IDs with expression changes are in network for each line?
wc -l net[0-9][0-9]
   794607 net16
  1397512 net50
  1327090 net68

# Joining all expression data with network
join -j1 -t" " -a1 -a2 -o0,1.2,2.2 ok16 ok50 > x
join -j1 -t" " -a1 -a2 -o0,1.2,1.3,2.2 x ok68 > x2
sed 's/  / 0.00 /;s/  / 0.00 /;s/ $/ 0.00/' x2 > okall
join -j1 -t" " xnet-full ../../ist_mm_faire/ala/okall > xnetall
# header
cat > x
expr16 expr50 expr68
paste -d" " xhead x > xhead2
# adding header
cat xhead2 xnetall > netall
