# Jedna z bibliotek wymagała usunięcia adapterów. Zrobione ręcznie.
~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
../noewLinie/trimmed/11_1P.fastq.gz \
../noewLinie/trimmed/11_2P.fastq.gz \
-o afex11.sam


# próba mapowania z przypisaniem read group
~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:hds1a\tLB:s68911\tPL:illumina\tSM:s68911\tPU:C4266ACXX.7.ATGTCA" \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140903_SND104_A_L007_HDS-1_R1.fastq.gz\
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140903_SND104_A_L007_HDS-1_R2.fastq.gz\
 | ~/bin/samtools-1.17/samtools view -bo hds1a.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:hds1b\tLB:s68911\tPL:illumina\tSM:s68911\tPU:C5FFRACXX.2.ATGTCA" \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140926_SND104_B_L002_HDS-1_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140926_SND104_B_L002_HDS-1_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo hds1b.bam

#************************ Dopiero po bamqc ************************************************************
# Poziom map-pl/q30
# Połączenie dwóch bam-ów z jednoczesnym sortowaniem wg name (żeby MarkDuplicates lepiej działało)
java -Xmx50g -jar ~/bin/picard.jar MergeSamFiles \
-I hds1a-q30.bam \
-I hds1b-q30.bam \
-O hds1-q30.bam \
--SORT_ORDER queryname \
--USE_THREADING true
#************************************************************************************

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:hds2a\tLB:s50676\tPL:illumina\tSM:s50676\tPU:C4266ACXX.8.CCGTCC" \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140903_SND104_A_L008_HDS-2_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140903_SND104_A_L008_HDS-2_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo hds2a.bam


~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:hds2b\tLB:s50676\tPL:illumina\tSM:s50676\tPU:C5FFRACXX.3.CCGTCC" \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140926_SND104_B_L003_HDS-2_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/HDS-1-2/raw_data/140926_SND104_B_L003_HDS-2_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo hds2b.bam

#************************ Dopiero po bamqc ************************************************************
java -Xmx50g -jar ~/bin/picard.jar MergeSamFiles \
-I hds2a-q30.bam \
-I hds2b-q30.bam \
-O hds2-q30.bam \
--SORT_ORDER queryname \
--USE_THREADING true
#************************************************************************************

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:hds3\tLB:s160\tPL:illumina\tSM:s160\tPU:C6U61ANXX.1.ACTTGA" \
/media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/data.fasteris.com/HDS-3/raw_data/150807_SND405_A_L001_HDS-3_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/z-mybook/dane_old/data.fasteris.com/HDS-3/raw_data/150807_SND405_A_L001_HDS-3_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo hds3.bam

# dla poniższego chyba lepiej dodać read groups picardem
for i in 1 2 3 5 6 9 13; do \
~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-${i}_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-${i}_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex${i}.bam ; done

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex1\tLB:s018693\tPL:illumina\tSM:s018693\tPU:HCK3LBBXY.5.NCGCGGTT+NTAGCGCT" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-1_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-1_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex1.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex2\tLB:s336a\tPL:illumina\tSM:s336a\tPU:HCK3LBBXY.5.NTATAACC+NCGATATC" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-2_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-2_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex2.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex3\tLB:s84854\tPL:illumina\tSM:s84854\tPU:HCK3LBBXY.5.NGACTTGG+NGTCTGCG" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-3_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-3_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex3.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex5\tLB:s245\tPL:illumina\tSM:s245\tPU:HCK3LBBXY.5.NAGTCCAA+NACTCATA" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-5_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-5_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex5.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex6\tLB:s03198\tPL:illumina\tSM:s03198\tPU:HCK3LBBXY.5.NTCCACTG+NCGCACCT" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-6_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-6_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex6.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex9\tLB:s61328\tPL:illumina\tSM:s61328\tPU:HCK3LBBXY.5.NCTTGTCA+NTATGTTC" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-9_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-9_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex9.bam

~/bin/bwa-mem2-2.2.1_x64-linux/bwa-mem2 mem -t24 -T30 \
-R "@RG\tID:afex13\tLB:s311\tPL:illumina\tSM:s311\tPU:HCK3LBBXY.5.NGGATCGA+NATCGCAC" \
 /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-13_R1.fastq.gz \
/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/noewLinie/190822_SNK268_A_L5-7_AFEX-13_R2.fastq.gz \
| ~/bin/samtools-1.17/samtools view -bo afex13.bam

# QC

for i in 1 2; do \
for j in a b; do \
~/bin/BamQC-master/bin/bamqc \
hds${i}${j}.bam \
--threads 24 \
-f /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf \
-o bamqc-raw; done ; done

# bez 11 bo ręcznie zrobiony
for i in 1 2 3 5 6 9 13; do \
~/bin/BamQC-master/bin/bamqc \
afex${i}.bam \
--threads 24 \
-f /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf \
-o bamqc-raw; done

~/bin/BamQC-master/bin/bamqc \
hds3.bam \
--threads 24 \
-f /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf \
-o bamqc-raw

# filtrowanie na MAPQ >30

# dla afex 11, 1, 2, 3, 5 zrobione ręcznie
for i in 6 9 13; do \
samtools view -@22 -bq30 \
afex${i}.bam \
-o q30/afex${i}-q30.bam; done

for i in 1 2; do \
for j in a b; do \
samtools view -@24 -bq30 \
hds${i}${j}.bam \
-o q30/hds${i}${j}-q30.bam; done; done

samtools view -@24 -bq30 hds3.bam -o q30/hds3-q30.bam

# O read groups
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4243306/
# ręczne dodanie read groups i jednocześnie przerobienie na BAM
java -jar ~/bin/picard.jar AddOrReplaceReadGroups I=11.sam O=afex11.bam RGID=afex11 RGLB=s25 RGPL=illumina RGPU=HCK3LBBXY.5.NAAGCTAG+NGCTATGT RGSM=s25

# sortowanie wg name, w picard bo hds sortuję w nim przy okazji łączenia
for i in 1 2 3 5 6 9 13; do \
java -Xmx100g -jar ~/bin/picard.jar SortSam \
-I q30/afex${i}-q30.bam \
-O name-srt/afex${i}-q30-name.bam \
--SORT_ORDER queryname; done

# Tylko 3, bo 1 i 2 posortowane przy łączeniu
java -Xmx100g -jar ~/bin/picard.jar SortSam \
-I q30/hds3-q30.bam \
-O name-srt/hds3-q30-name.bam \
--SORT_ORDER queryname


# deduplikacja
for i in 1 2 3 5 6 9 13; do \
java -Xmx100g -jar ~/bin/picard.jar MarkDuplicates \
-I name-srt/afex${i}-q30-name.bam \
-O dedup/afex${i}-dedup.bam \
-M dedup/metrics-afex${i}-dedup \
--READ_NAME_REGEX '([a-zA-Z0-9]+):([0-9]+):([a-zA-Z0-9]+):([0-9]+):([0-9]+):([0-9]+):([0-9]+)' \
--REMOVE_DUPLICATES true \
--ASSUME_SORT_ORDER queryname \
--OPTICAL_DUPLICATE_PIXEL_DISTANCE 100 \
--TAGGING_POLICY All ; done

for i in 3; do \
java -Xmx100g -jar ~/bin/picard.jar MarkDuplicates \
-I name-srt/hds${i}-q30-name.bam \
-O dedup/hds${i}-dedup.bam \
-M dedup/metrics-hds${i}-dedup \
--READ_NAME_REGEX '([a-zA-Z0-9]+):([0-9]+):([a-zA-Z0-9]+):([0-9]+):([0-9]+):([0-9]+):([0-9]+)' \
--REMOVE_DUPLICATES true \
--ASSUME_SORT_ORDER queryname \
--OPTICAL_DUPLICATE_PIXEL_DISTANCE 100 \
--TAGGING_POLICY All ; done

# Tu pliki wejściowe to te po połączeniu z jednoczesnym sortowaniem
# Uwaga - inny read regex
for i in 1 2; do \
java -Xmx100g -jar ~/bin/picard.jar MarkDuplicates \
-I q30/hds${i}-q30.bam \
-O dedup/hds${i}-dedup.bam \
-M dedup/metrics-hds${i}-dedup \
--READ_NAME_REGEX '([a-zA-Z0-9]+)-([a-zA-Z0-9]+):([0-9]+):([a-zA-Z0-9]+):([0-9]+):([0-9]+):([0-9]+):([0-9]+)' \
--REMOVE_DUPLICATES true \
--ASSUME_SORT_ORDER queryname \
--OPTICAL_DUPLICATE_PIXEL_DISTANCE 100 \
--TAGGING_POLICY All ; done

# sprawdzanie poprawności read regex
#samtools view name-srt/afex11-q30-name.bam | head | grep -E '([a-zA-Z0-9]+):([0-9]+):([a-zA-Z0-9]+):([0-9]+):([0-9]+):([0-9]+):([0-9]+)'

# **************** Skrypt do sortowania wg koordynat (wymagane przez freebayes) ******************************
# Uwaga, nazwa jest tworzona na podstawie wartości FILES (nie moze być tu ścieżki)
#!/bin/bash
FILES=*.bam

for f in $FILES
do
  samtools sort -@24 ${f} -o /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/sort4varcall/srt-${f}
done
#*************************************************************************************************************

# variant-calling
# W wersji 24.04 lubuntu -> sciągnąć freebayes-1.3.6-linux-amd64-static.gz  z
https://github.com/freebayes/freebayes/releases
# i wystarczy rozpakować
# w skrypcie 'freebayes-parallel' zamienić 'freebayes' na całą ścieżkę do freebayes
'/home/mj/bin/freebayes-1.3.6-linux-amd64-static'
plik wykonywalny pobrany z git freebayes

# Do free-bayes-parallel potrzebne vcflib - instalacja
apt-get install libvcflib-tools libvcflib-dev
# z
https://github.com/vcflib/vcflib

# Potrzebne też GNUparallel
https://www.gnu.org/software/parallel/
# instalacja z repozytorium
sudo apt-get install parallel

# freebayes, jeden procesor i bez filtrowania
# poziom /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/sort4varcall
freebayes -f /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa srt-afex11-dedup.bam srt-afex13-dedup.bam srt-afex1-dedup.bam srt-afex2-dedup.bam \ 
srt-afex3-dedup.bam srt-afex5-dedup.bam srt-afex6-dedup.bam srt-afex9-dedup.bam srt-hds1-dedup.bam srt-hds2-dedup.bam srt-hds3-dedup.bam \ 
> /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall/pl-NAM.vcf 2>/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall/info

# freebayes multicore
# ściągnięcie programów do katalogu ~/bin/freebayes-scripts
# stąd
https://github.com/freebayes/freebayes/tree/master/scripts

bgziptabix              fasta_generate_regions.py  generate_freebayes_region_scripts.sh  sam_add_rg.pl                 update_version.sh
coverage_to_regions.py  freebayes-parallel         GenerateFreebayesRegions.R            split_ref_by_bai_datasize.py  vcffirstheader

# ustawienie wykonywalności
chmod a+rwx *
# najpierw modyfikacja ścieżek do programów w freebayes-parallel
# Zmiana  w wierszach (dodanie /usr/bin/vcflib przed poleceniami): 
36  #$command | head -100 | grep "^#" # generate header
37  # iterate over regions using gnu parallel to dispatch jobs
38  cat "$regionsfile" | parallel -k -j "$ncpus" "${command[@]}" --region {}
39  ) | /usr/bin/vcflib vcffirstheader \
40      | /usr/bin/vcflib vcfstreamsort -w 1000 | /usr/bin/vcflib vcfuniq # remove duplicates at region edges

# indeksowanie bam-ów
#******************** skrypt index-bam.sh *****************
#!/bin/bash
FILES=*.bam

for f in $FILES
do
  samtools index -@24 ${f}
done
#**********************************************************
# wariant calling
#********************* skrypt varcall.sh ******************************
# Z pozimu sort4varcall
ulimit -n 20000 # bez tego wykrzacza się
/home/mj/bin/freebayes-scripts/freebayes-parallel <(/home/mj/bin/freebayes-scripts/fasta_generate_regions.py /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa.fai 100000) 24 \
    -f /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa srt-afex11-dedup.bam srt-afex13-dedup.bam srt-afex1-dedup.bam srt-afex2-dedup.bam srt-afex3-dedup.bam \ 
    srt-afex5-dedup.bam srt-afex6-dedup.bam srt-afex9-dedup.bam srt-hds1-dedup.bam srt-hds2-dedup.bam srt-hds3-dedup.bam \ 
    > /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall-parallel/pl-NAM.vcf 2>/media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall-parallel/info
#**********************************************************************
# Przekieroanie strumienia błędu do pliku pozwala wyłączyć komp po zakończeniu procedury z zachowaniem ifo o ewenualnych problemach.
# Zamiast wypisywać pliki bam można było podać ich listę: -L --bam-list FILE
# Trwało to ok 16 h

# podstawowe filtrowanie (p<0.01)
# poziom varcall-parallel
vcffilter -f "QUAL > 20" pl-NAM.vcf > pl-NAM20.vcf
# trwało ok 3 h
# Po bcftools stats jeszcze filtr na depth > 5 bo wykres "depth distribution" miał dołek
# Żeby było szybciej używam już odfiltrowanego zbioru
vcffilter -f "DP > 5" pl-NAM20.vcf > pl-NAM20dp5.vcf
# trwało ok 2 h

# Potrzebny program do analizy jakościowej vcf
# -F, --fasta-ref ref.fa
#    faidx indexed reference sequence file to determine INDEL context
# samtools faidx ... -> już zrobiony
# Statystyki osobno dla prób -> Trzeba dać bcftools stats -s - <multisample VCF file>
# ALbo bcftools stats -S sample-list.txt file.vcf > stats
~/bin/bcftools-1.17/bcftools stats -s - pl-NAM20dp5.vcf -F /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa > stats20dp5

# wykres, wymaga LaTeXa i klasy memoir.cls
# najlepiej zainstalować je z TeXLive, w razie czego trzeba zrobić source ~/.profile w tym samym terminalu w którym plot
~/bin/bcftools-1.17/misc/plot-vcfstats -p plot -s stats20dp5
# Nic to nie zminiło w wykresie "depth distribution"

# Dalej snpEff
# instalacja z repo ubuntu albo ściągnąć z github i wystarczy rozpakować (robię z github)
# https://pcingola.github.io/SnpEff/se_commandline/
# https://hbctraining.github.io/In-depth-NGS-Data-Analysis-Course/sessionVI/lessons/03_annotation-snpeff.html
# https://genomics.sschmeier.com/ngs-voi/index.html
# opis HGVS http://varnomen.hgvs.org/bg-material/simple/
# Sequence Ontology http://www.sequenceontology.org/

# Sprawdzenie dostępnych genomów dla Zea
java -jar ~/bin/snpEff/snpEff.jar databases | grep 'Zea'

# Dla pewności tworzę swoją bazę żeby była spójna z plikami, których używam
# Wg https://pcingola.github.io/SnpEff/se_build_db/#add-a-genome-to-the-configuration-file
# poziom ~/bin/snpEff
featherpad snpEff.config &
#************* dodaję wpis nowego genomu ***********
# Zea mays, NAMv5
NAMv5.genome : Maize
#*****************************************************
# katalog na genom
mkdir -p data/NAMv5
cd data/NAMv5
# skopiowanie plików
cp -a /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf .
# zmiana nazwy wg dokumentacji
mv Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.gtf genes.gtf
# snpEff obsługuje kompresję więc ją robię
gzip genes.gtf
gzip NAMv5.fa
# CDS do sprawdzenia poprawności bazy
cp /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cds.fa.gz .
# zmiana nazwy wg instrukcji
mv Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.cds.fa.gz cds.fa.gz
# pobranie białek, też do kontroli
wget -nd -np https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.protein.fa.gz -O protein.fa.gz
# Koniecznie trzeba zmienić IDs w pliku proteins inaczej ich nie znajduje i protein check daje error
cp protein.fa.gz beckup-protein.fa.gz
zcat beckup-protein.fa.gz | sed 's/_P/_T/' | gzip > protein.fa.gz
mkdir ../genomes
cd ../genomes
cp -a /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa .
mv Zm-B73-REFERENCE-NAM-5.0.fa NAMv5.fa

# Regulation database
# poziom ~/bin/snpEff/data/NAMv5
cp /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0_Zm00001eb.1.nc.gff3.gz regulation.gff.gz

# Tworzenie bazy
cd ../..
java -jar snpEff.jar build -gtf22 -v NAMv5

# Jeśli regulacyjne / non-coding dodane później
java -Xmx20G -jar snpEff.jar build -v -onlyReg NAMv5

# Anotacja

java -jar snpEff.jar ann
-csvStats <file>                : Create CSV summary file.
-s , -stats, -htmlStats         : Create HTML summary file.  Default is 'snpEff_summary.html'
  -lof                            : Add loss of function (LOF) and Nonsense mediated decay (NMD) tags.
  -c , -config                 : Specify config file
  -v , -verbose                : Verbose mode

Java -Xmx60G -jar ~/bin/snpEff/snpEff.jar ann -csvStats stat.csv -s -lof -c ~/bin/snpEff/snpEff.config NAMv5 -v pl-NAM20dp5.vcf > pl-anno.vcf 2>bledy && shutdown -h +10
# Zajęło niecałą 1 h

# W ten sposób (-s -lof) statystki w html zapisane zostały do pliku -lof a statystyki dla genów w -lof.genes.txt
# po -s trzeba podać nazwę np. stats.html
# -lof i tak jest domyślnie stosowane
# Niżej poprawna komenda
Java -Xmx60G -jar ~/bin/snpEff/snpEff.jar ann -csvStats stat.csv -s stats.html -c ~/bin/snpEff/snpEff.config NAMv5 -v pl-NAM20dp5.vcf > pl-anno.vcf 2>bledy && shutdown -h +10

# Sporo błędów -> robię procedure z wbudowanym genomem v5.1
# "Genome stats" identyczne jak dla genomu który sam zrobilem
java -Xmx60G -jar ~/bin/snpEff/snpEff.jar ann -csvStats stat-def.csv -s stat-def.html -c ~/bin/snpEff/snpEff.config Zea_mays -v pl-NAM20dp5.vcf > pl-anno-def.vcf 2>bledy-def

# Dokładnie te same wyniki, przynajmniej wiem, że dobrze zrobiłem genom
# Zostawiam tylko wynik na genomie wbudowanym
rm pl-anno.vcf
# wynik jest w 17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall-parallel

# Ostrzeżenie, za krótkie transkrypty. To mały problem? -> https://www.biostars.org/p/9551178/#9551187


#******************************************************** VEP ***************************************************************
# Próba z Variant Effect Predictor z Ensembl
# Pobranie z https://grch37.ensembl.org/info/docs/tools/vep/index.html
# Dokumentacja https://grch37.ensembl.org/info/docs/tools/vep/script/index.html
# Instalacja modułów Perla wg README
cpan # i dalej
install perl::module

# Aby DBD::mysql zainstalować
sudo apt-get install libmysqlclient-dev
#i w cpan
install DBD::mysql
install Bio::Root::Version # to też potrzebne
# Treba skompresować bgzip i zindeksować gtf, musi być wcześniej posortowany
# poziom /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5
/home/mj/bin/ensembl-vep-release-109/htslib/bgzip Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf -c > Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf.gz
~/bin/bcftools-1.17/bcftools tabix -p gff Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf.gz
#**************************************************************************************************************************

#**************** VEP z pobranym genomem **********************************************************************************
# wg https://plants.ensembl.org/info/docs/tools/vep/script/vep_options.html#basic
cd ~/.vep/
# pobranie z http://ftp.ensemblgenomes.org/pub/current/plants/variation/indexed_vep_cache/
wget -np -nd http://ftp.ensemblgenomes.org/pub/current/plants/variation/indexed_vep_cache/zea_mays_vep_56_Zm-B73-REFERENCE-NAM-5.0.tar.gz
tar -xzf zea_mays_vep_56_Zm-B73-REFERENCE-NAM-5.0.tar.gz

# trzeba wskazać wersję cache zgodną ze ściągniętym plikiem
# opcja -e daje max informacji
# -fork daje multithreading
# dwie wersje analizy z gtf i bez niego, nie wiem co on daje
~/bin/ensembl-vep-release-109/vep -i ../varcall-parallel/pl-NAM20dp5.vcf -o pl-vep-gtf.vcf -v -species zea_mays -format vcf --sf stats-vep-gtf.html -e -offline -cache -dir /home/mj/.vep/ -cache_version 56 -fork 24 -fasta /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa -gtf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf.gz -force_overwrite 2>bledy-vep-gtf
~/bin/ensembl-vep-release-109/vep -i ../varcall-parallel/pl-NAM20dp5.vcf -o pl-vep.vcf -v -species zea_mays -format vcf --sf stats-vep.html -e -offline -cache -dir /home/mj/.vep/ -cache_version 56 -fork 24 -fasta /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa -force_overwrite 2>bledy-vep

# Osobno dla każdej linii

~/bin/ensembl-vep-release-109/vep -i ../varcall-parallel/pl-NAM20dp5.vcf -vcf -vcf_info_field ANN -o pl-vep-gtf.vcf -individual all -v -species zea_mays -format vcf --sf stats-vep-gtf.html -e -offline -cache -dir /home/mj/.vep/ -cache_version 56 -fork 24 -buffer_size 10000 -hgvs -check_existing -check_ref -fasta /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa -gtf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf.gz -force_overwrite
~/bin/ensembl-vep-release-109/vep -i ../varcall-parallel/pl-NAM20dp5.vcf -vcf -vcf_info_field ANN -o pl-vep.vcf -individual all -v -species zea_mays -format vcf --sf stats-vep.html -e -offline -cache -dir /home/mj/.vep/ -cache_version 56 -fork 24 -buffer_size 10000 -hgvs -check_existing -check_ref -fasta /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa -force_overwrite

shutdown -h +10

# dodać -hgvs, wymaga -fasta
# -check_ref (sprawdzenie alleli względem sekwencj fasta, wymaga -fasta)
# -buffer_size, domyślny 5000, mozna zwiększyć aby było szybciej
# -vcf, output file format
# -individual all
# -vcf_info_field ANN, format onsequences jak w snpEff, dla porównania
# -check_existing

# Każda z analiz zajęła około miesiąca!!! I powstały gigantyczne pliki 374G i 342G

# ****************************** Powrót do analiz 24.11.23 ********************************

# Wybór wariantów zwiazanych z genami z artykułów
# Najpierw zrobiłem plik bed z koordynatami - /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/geny-chlod/geny-z-snp.bed
# kopia do /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall-parallel/wybor-z-art i działanie na tym poziomie
# dla każdej z analiz anotacji wariantów
java -jar ~/bin/snpEff/SnpSift.jar intIdx ../pl-anno-def.vcf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/geny-chlod/geny-z-snp.bed > geny-z-snp_eff.vcf
java -jar ~/bin/snpEff/SnpSift.jar intIdx ../../call-vep/pl-vep.vcf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/geny-chlod/geny-z-snp.bed > geny-z-snp_vep.vcf
java -jar ~/bin/snpEff/SnpSift.jar intIdx ../../call-vep/pl-vep-gtf.vcf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/geny-chlod/geny-z-snp.bed > geny-z-snp_vep-gtf.vcf
# I dla VCF bez anotacji
java -jar ~/bin/snpEff/SnpSift.jar intIdx ../pl-NAM20dp5.vcf /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/geny-chlod/geny-z-snp.bed > geny-z-snp.vcf

# Oglądanie w IGV
# genom: /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zm-B73-REFERENCE-NAM-5.0.fa
# bam'y użyte do freebayes: /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/sort4varcall
# vcf'y: /media/mj/17d60f37-45c8-4878-8d94-7e95ff7bbddb/map-pl/varcall-parallel/wybor-z-art
# gtf: /media/mj/c8e2ccd2-6313-4092-be34-46144891720f/NAMv5/Zea_mays.Zm-B73-REFERENCE-NAM-5.0.55.chr.sorted.gtf
