# This file (based on my local file "procedura_v2.sh") descibes steps to map oligo probes to cDNAs
# exonerate is used, downloaded as binary file from ensemble site. It is also available in Ubuntu sotware repository.
# The starting point uses two files:
# i. oligo.fa - fasta file with oligo sequences
# ii. Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa - CDNAs in fasta format

# 1. Mapping
- [ ] How fasta_uniq.fa was done?
# splitting for mapping to genome - NOT USED HERE
fasta-splitter.pl --n-parts 24 --line-length 70 oligo_uniq.fa

~/bin/exonerate-2.2.0-x86_64/bin/exonerate --query oligo_uniq.fa --target Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cdna.fa --showvulgar FALSE \
--showsugar FALSE --fsmmemory 20000 --ryo ">%S %V %em" --querytype dna --targettype dna > o2cdna
# slightly different size of files after exonerate runs. It is constant for repeated runs using the same version at the same computer -> SOLVED - different path to program and user name
