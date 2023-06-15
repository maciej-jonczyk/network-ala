# Alignment i variant-calling

# bwa-mem2, często stosowany
# mnimalna jakość = 30
# z połączeniem plików dla tych samych bibliotek wg NIE robię tak - bo to zamaże fakt sekwencjonowania osobno
https://bioinformatics.stackexchange.com/a/10744/2481
# Uwaga - trzeba dodać read groups - wg
https://informatics.fas.harvard.edu/short-introduction-to-bwa.html
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4243306/
# Objasnienie skrotow, typu ID, SM
https://gatk.broadinstitute.org/hc/en-us/articles/360035890671-Read-groups
# Tu też jest o schemacie z Illuminy
https://knowledge.illumina.com/software/general/software-general-reference_material-list/000002211
https://help.basespace.illumina.com/files-used-by-basespace/fastq-files

# Uwaga bwa-mem tworzy format SAM, trzeba samtools przerbić na BAM!!!
bwa-mem2 mem -t 24 -T30 index-file <(cat readA-1 readB-1) <(cat readA-2 readB-2) -o output.sam

#################### Z mejla od Fasteris, biblioteki HDS-1-2 ###################
>> Regarding the replication of HDS-1-2 sequencing:
>>
>> Two libraries were prepared, one from each of your samples (HDS-1
> and
>> HDS-2).
>>
>> Each library was sequenced in 2 HiSeq lanes, in order to obtain a
>> minimum of 60 Gbases per library (>20x coverage)
>> As the sequencing was done in paired-reads runs, you have for each
>> sequencing run: the reads coming from the first read (R1) and from
>> its
>> paired read (second read, R2).
>>
>> Therefore, there are two sequencing replicates per library, e.g. for
>> HDS-1:
>> 140903_SND104_A_L007_HDS-1_R1.fastq.gz and
>> 140903_SND104_A_L007_HDS-1_R2.fastq.gz (first run)
>> and
>> 140926_SND104_B_L002_HDS-1_R1.fastq.gz and
>> 140926_SND104_B_L002_HDS-1_R2.fastq.gz ("replicate run").
>>
>> And 4 pairs of reads in total for the project.
>>
>> For the bioinformatics analysis, after the mapping, we will merge
> the
>> duplicates for the subsequent processes.

#################################################################################################


# tylko unikalne uliniowania, przy okazji przerobienie na BAM
samtools view -S -b -@24 output.sam -e '!([XA] | [SA])' -o unique_mapped.bam && rm output.sam
# nie robić?
https://www.biostars.org/p/59281/#59303

# sortowanie, wg name bo lepiej picard usuwa duplikaty
samtools sort -@24 -n unique_mapped.bam -o unique_mapped_name.bam

# sprawdzić potok ze wszystkimi poleceniami samtools

# wg
https://bioinformatics.stackexchange.com/a/519
# o tych tag'ach
https://www.biostars.org/p/150063/
# specyfikacja SAM
https://samtools.github.io/hts-specs/SAMv1.pdf
https://samtools.github.io/hts-specs/SAMtags.pdf

# Usunięcie duplikatów Picard tools
# wg
https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates
# plik wykonywalny tu
https://github.com/broadinstitute/picard/releases/tag/3.0.0

# lista poleceń
java -jar picard.jar
# pomoc do konkretnego polecenia
java -jar picard.jar MarkDuplicates

# sortowanie wg koordynat, konieczne do freebayes

samtools sort -@24 deduped.bam -o deduped_srt.bam

# variant-calling
# freebayes, instalacja z menedżera programów ubuntu, wersja 1.3.6 (najowsza w github to 1.3.7 ale nie ma pliku wykonywalnego a kompilacja skomplikowana)

https://github.com/freebayes/freebayes

# Alternatywnie bcftools mpileup
https://samtools.github.io/bcftools/howtos/variant-calling.html
# podobno dobry
https://www.nature.com/articles/s41598-022-15563-2
