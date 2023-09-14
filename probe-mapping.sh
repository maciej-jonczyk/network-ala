# This file (based on my local file "procedura_v2.sh") descibes steps to map oligo probes to cDNAs
# exonerate is used, downloaded as binary file from ensemble site. It is also available in Ubuntu sotware repository.
# The starting point uses two files:
# i. oligo.fa - fasta file with oligo sequences
# ii. Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa - CDNAs in fasta format

export LC_ALL=C

# 1. Mapping
# HOW fasta_uniq.fa WAS DONE?
# splitting for mapping to genome - NOT USED HERE
fasta-splitter.pl --n-parts 24 --line-length 70 oligo_uniq.fa
# select probes shorter than usual 70nt
grep -B1 '^[ACGT]\{40\}$' oligo_uniq.fa | grep '>' | sed 's/>//' > oligo40nt
grep -B1 '^[ACGT]\{50\}$' oligo_uniq.fa | grep '>' | sed 's/>//' > oligo50nt

~/bin/exonerate-2.2.0-x86_64/bin/exonerate --query oligo_uniq.fa --target Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa --showvulgar FALSE \
--showsugar FALSE --fsmmemory 20000 --ryo ">%S %V %em" --querytype dna --targettype dna > o2cdna
# slightly different size of files after exonerate runs. It is constant for repeated runs using the same version at the same computer
# -> SOLVED - different path to program in recorded command and different user name in the file header

# extracting only hit stats
grep '>' o2cdna > o2cdna_hits

# 2. Filtering
# selecting hits for short probes
grep -Fwf oligo40nt o2cdna_hits > o2cdna_hits40nt
grep -Fwf oligo50nt o2cdna_hits > o2cdna_hits50nt
# selecting hits for 70nt probes
grep -Fwvf oligo40nt o2cdna_hits > x
grep -Fwvf oligo50nt x > o2cdna_hits70nt

# Filtering for long probes (70nt)
# selecting perfect hits
awk '$11==70 && $12==70 && $13==0' o2cdna_hits70nt > o2cdna_perfect70
# selecting non-perfect hits
awk '$11<70 || $12<70 || $13>0' o2cdna_hits70nt > o2cdna_noperfect70

# Removing perfect probe:gene pairs from noperfect set
# adding probe:gene IDs
awk '{print $1":"$5}' o2cdna_perfect70 | tr -d '>' | cut -f1 -d"_" > xperf70id
awk '{print $1":"$5}' o2cdna_noperfect70 | tr -d '>' | cut -f1 -d"_" > xnoperf70id
paste -d" " o2cdna_perfect70 xperf70id > o2cdna_perfect70_combid
paste -d" " o2cdna_noperfect70 xnoperf70id > o2cdna_noperfect70_combid
# tidying-up
sed 's/-- completed exonerate analysis//' o2cdna_noperfect70_combid > x
mv x o2cdna_noperfect70_combid
# removing extra hits for perfect probe:gene pairs from noperfect set
grep -Fwvf xperf70id o2cdna_noperfect70_combid > o2cdna_noperfect70_combid_noperfectid
# is probe mapped perfectly only to one gene?
sort -u xperf70id > xperf70id_u
cut -f1 -d":" xperf70id_u | uniq -d > unmapped70id

# filtering-out multimapping perfect
grep -Fwvf unmapped70id o2cdna_perfect70_combid > o2cdna_perfect70_combid_1hit
# removing this probes also from noperfect
grep -Fwvf unmapped70id o2cdna_noperfect70_combid_noperfectid > o2cdna_noperfect70_combid_noperfectid_nounmpapped
# IDs of unique probes with perfect hits
cut -f1 -d" " o2cdna_perfect70_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# filtering-out suboptimal hits for probes with perfect hits
grep -Fwvf ids_perf_1hit o2cdna_noperfect70_combid_noperfectid_nounmpapped > o2cdna_noperfect70_no1hit
# these are probes not mapped in perfect set

# 3. Sequential removing increasingly worse hits
# first filter - there must be 69 paired bases
awk '$12-$13==69' o2cdna_noperfect70_no1hit > x # alignment length minus number of mismatches
cut -f14 -d" " x | sort -u > o2gen69 # retrieve probe:gene column
# equally good hits for >1 probe, so not mapped uniquelly
cut -f1 -d":" o2gen69 | uniq -d > unmapped69id
# removing non-unique IDs from set
grep -Fwvf unmapped69id x > mapped69 # from set 69
grep -Fwvf unmapped69id o2cdna_noperfect70_no1hit > x3 # from whole set
# IDs of mapped 69
cut -f1 -d" " mapped69 | sort -u | tr -d '>' > xmap69id
# removing mapped probes from suboptimal set
grep -Fwvf xmap69id x3 > xno69

#*************************** Use of external file ************************************************
# 4. Sequentially selecting the best unique mapping for probes. Increasingly worse alignment.
# using shell script skrypt_v2.sh and list of commands using it - komendy_skryptu (pasting them in terminal)
#*************************************************************************************************

# manual removing files for alignment below 19nt

# Combining data for mapped probes
cat o2cdna_perfect70_combid_1hit mapped* > alluniqbest70
