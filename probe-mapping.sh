# This file (based on my local file "procedura_v2.sh") descibes steps to map oligo probes to cDNAs
# exonerate is used, downloaded as binary file from ensemble site. It is also available in Ubuntu sotware repository.
# The starting point uses two files:
# i. oligo.fa - fasta file with oligo sequences
# ii. Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa - CDNAs in fasta format

export LC_ALL=C

# 1. Mapping
# Remove duplicates from fasta, some control sequences are given ultiple times
# using seqkit, installed from Ubuntu repo
seqkit rmdup -n oligo.fa -o oligo_uniq.fa

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
grep '^>' o2cdna > o2cdna_hits

# 2. Filtering
# selecting hits for short probes
grep -Fwf oligo40nt o2cdna_hits > o2cdna_hits40nt
grep -Fwf oligo50nt o2cdna_hits > o2cdna_hits50nt
# selecting hits for 70nt probes
grep -Fwvf oligo40nt o2cdna_hits > x
grep -Fwvf oligo50nt x > o2cdna_hits70nt

# moving hits to separate directories according to probe length
mv o2cdna_hits40nt oligo40
mv o2cdna_hits50nt oligo50
mv o2cdna_hits70nt oligo70

# change dir
cd oligo70

#*************************************************** Filtering for long probes (70nt) ************************************************
# selecting perfect hits
awk '$11==70 && $12==70 && $13==0' o2cdna_hits70nt | sort > o2cdna_perfect70
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
# Using shell script skrypt_v2.sh and list of commands using it - komendy_skryptu (pasting them in terminal).
# As system don't allow to run scripts from removable media it is most convenient to move/copy skrypt_v2.sh to home directory.
# File komendy_skryptu uses such setting.
cp -a skrypt_v2.sh ~
chmod a+rwx ~/skrypt_v2.sh
#*************************************************************************************************

# removing files for alignment below 19nt
rm mapped1[0-8] mapped[0-9]

# Combining data for mapped probes
cat o2cdna_perfect70_combid_1hit mapped[0-9]* > alluniqbest70

#*********************************************** Similar procedure for 50nt probes ********************************************************
export LC_ALL=C
# Selecting perfect matches
awk '$11==50 && $12==50 && $13==0' o2cdna_hits50nt > o2cdna_perfect50
# selecting non-perfect matches
awk '$11<50 || $12<50 || $13>0' o2cdna_hits50nt > o2cdna_noperfect50
# Removing probe:gene pairs with perfect match from set noperfect
# adding IDs
awk '{print $1":"$5}' o2cdna_perfect50 | tr -d '>' | cut -f1 -d"_" > xperf50id
awk '{print $1":"$5}' o2cdna_noperfect50 | tr -d '>' | cut -f1 -d"_" > xnoperf50id
paste -d" " o2cdna_perfect50 xperf50id > o2cdna_perfect50_combid
paste -d" " o2cdna_noperfect50 xnoperf50id > o2cdna_noperfect50_combid
# removing from noperfect additional hits for perfect pairs
grep -Fwvf xperf50id o2cdna_noperfect50_combid > o2cdna_noperfect50_combid_noperfectid
# Are there only one gene with perfect match to a given?
sort -u xperf50id > xperf50id_u
cut -f1 -d":" xperf50id_u | uniq -d > unmapped50id
# filtering-out multimammping perfect
grep -Fwvf unmapped50id o2cdna_perfect50_combid > o2cdna_perfect50_combid_1hit
# removing this probes also from noperfect set
grep -Fwvf unmapped50id o2cdna_noperfect50_combid_noperfectid > o2cdna_noperfect50_combid_noperfectid_nounmpapped
# IDs of unique probes with perfect match
cut -f1 -d" " o2cdna_perfect50_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# filtering-out suboptimal hits for probes with perfect match
grep -Fwvf ids_perf_1hit o2cdna_noperfect50_combid_noperfectid_nounmpapped > o2cdna_noperfect50_no1hit
# Sequential removing increasingly bad alignments
# first filter there must be 49 paired bases
awk '$12-$13>=49' o2cdna_noperfect50_no1hit > x
cut -f14 -d" " x | sort -u > o2gen49
# equally good for >1 probe
cut -f1 -d":" o2gen49 | uniq -c | sed 's/^ *//' > o2gen49_num
awk -v FS=" " '$1>1' o2gen49_num  > unmapped49_num
# removing from dataset
cut -f2 -d" " unmapped49_num > unmapped49id
grep -Fwvf unmapped49id x > mapped49
# IDs mapped 49
cut -f1 -d" " mapped49 | sort -u | sed 's/>//' > xmap49id
grep -Fwvf xmap49id x3 > xno49

#*************************** Use of external file ************************************************
# Sequentially selecting the best unique mapping for probes. Increasingly worse alignment.
# Using shell script skrypt_v2.sh (the same as for 70nt probes) and list of commands using it - komendy_skryptu50 (pasting them in terminal).
# As system don't allow to run scripts from removable media it is most convenient to move/copy skrypt_v2.sh to home directory.
# File komendy_skryptu50 uses such setting.
cp -a skrypt_v2.sh ~
chmod a+rwx ~/skrypt_v2.sh
#*************************************************************************************************

ls -lSr mapped[0-9]*
# the shortest match is 20nt long, so >19 filter is not needed
# removing empty files
find . -type f -size 0c -delete

# Combining mapped probes
cat o2cdna_perfect50_combid_1hit mapped[0-9]* > alluniqbest50

#*********************************************** Similar procedure for 40nt probes ********************************************************
export LC_ALL=C
# Selecting perfect hits
awk '$11==40 && $12==40 && $13==0' o2cdna_hits40nt > o2cdna_perfect40
# selecting non-perfect hits
awk '$11<40 || $12<40 || $13>0' o2cdna_hits40nt > o2cdna_noperfect40
# filtering-out perfect oligo:gen pairs from noperfect set
# adding IDs
awk '{print $1":"$5}' o2cdna_perfect40 | tr -d '>' | cut -f1 -d"_" > xperf40id
awk '{print $1":"$5}' o2cdna_noperfect40 | tr -d '>' | cut -f1 -d"_" > xnoperf40id
paste -d" " o2cdna_perfect40 xperf40id > o2cdna_perfect40_combid
paste -d" " o2cdna_noperfect40 xnoperf40id > o2cdna_noperfect40_combid
# removing from noperfect extra hits for perfect pairs
grep -Fwvf xperf40id o2cdna_noperfect40_combid > o2cdna_noperfect40_combid_noperfectid
# Does a given probe maps perfectly to one gene only?
sort -u xperf40id > xperf40id_u
cut -f1 -d":" xperf40id_u | uniq -c | sed 's/^ *//' > xperf40id_num
awk '$1>1' xperf40id_num  > unmapped40id_num
cut -f2 -d" " unmapped40id_num > unmapped40id
# Filtering-out multimammping perfect
grep -Fwvf unmapped40id o2cdna_perfect40_combid > o2cdna_perfect40_combid_1hit
# these probes are also removed from noperfect set
grep -Fwvf unmapped40id o2cdna_noperfect40_combid_noperfectid > o2cdna_noperfect40_combid_noperfectid_nounmpapped
# IDs of unique probes with perfect match
cut -f1 -d" " o2cdna_perfect40_combid_1hit | tr -d '>' | sort -u > ids_perf_1hit
# filtering-out suboptimal hits for probes having perfect hits
grep -Fwvf ids_perf_1hit o2cdna_noperfect40_combid_noperfectid_nounmpapped > o2cdna_noperfect40_no1hit
# Sequentially removing increasingly bad alignments
# filter for 39 paired bases
awk '$12-$13>=39' o2cdna_noperfect40_no1hit > x
cut -f14 -d" " x | sort -u > o2gen39
# equally good for >1 probe
cut -f1 -d":" o2gen39 | uniq -c | sed 's/^ *//' > o2gen39_num
awk '$1>1' o2gen39_num  > unmapped39_num
# removing from dataset
cut -f2 -d" " unmapped39_num > unmapped39id
grep -Fwvf unmapped39id x > mapped39
grep -Fwvf unmapped39id o2cdna_noperfect40_no1hit > x3
# IDs of mapped 39
cut -f1 -d" " mapped39 | sort -u | tr -d '>' > xmap39id
grep -Fwvf xmap39id x3 > xno39

#*************************** Use of external file ************************************************
# Sequentially selecting the best unique mapping for probes. Increasingly worse alignment.
# Using shell script skrypt_v2.sh (the same as for 70nt probes) and list of commands using it - komendy_skryptu40 (pasting them in terminal).
# As system don't allow to run scripts from removable media it is most convenient to move/copy skrypt_v2.sh to home directory.
# File komendy_skryptu40 uses such setting.
cp -a skrypt_v2.sh ~
chmod a+rwx ~/skrypt_v2.sh
#*************************************************************************************************

ls -lSr mapped[0-9]*
# the shortest match is 20nt long, so >19 filter is not needed
# removing empty files
find . -type f -size 0c -delete

# concatenating mapped probes
cat o2cdna_perfect40_combid_1hit mapped[0-9]* > alluniqbest40

#************************* Combining all unique alignments of probes *******************************
cd ../bbest_cdna
cat ../oligo*/alluniqbest* > alluniqbest
# retriewing only ID info
cut -f14 -d" " alluniqbest | tr ':' ' ' | sort -u > alluniq_best_ids
