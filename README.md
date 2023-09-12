# From microarray results to network

The aim of this repo is create protein interaction network for gene expression data in maize.
The starting point is a mapping between oligo probes (abbreviated *MZ*) to maize genes (NAM v5 assembly, dubbed *NAM*).
The code for MZ-NAM mapping is not included here.

The primary ID type in STRING v 12 is UniProt (abbreviated *UP* here) and mapping to AGPv4 is included.
There is UniProt - NAM mapping in file Zm-B73-REFERENCE-NAM.UniProt.proteins.tab from https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/
So I'll use UniProt.

## List of files

### Outdated

*bestNAMforV3.sh* - selecting best mapping of oligo-probe to NAMv5 genome, deprecated

*sieci-orto-ala.sh* - network construction based on orthology data

### Current

#### Probe mapping

*spojne-mz-ala.sh* - selecting best oligo-probe - NAMv5 mapping. Uses *duplik030223.r*

*duplik030223.r* - some commands to compute averages for probes with multiple values

#### Variant detection and further analyses

*map-pl.sh* - mapping of resequencing data. Here also variant-calling is described.

*notatki.sh* - some notes and links concerning analysis

- [ ] selection of interesting variants

#### Network construction

*annotation.sh* - functional annotation of genes, direct from NAM and translated from AGPv4

**new** *network-map-string.sh* - network based on mapping of proteins in STRING 12

*string12-network.sh* - network based on STRING 12 release and UniProt IDs

*score-hist.r* - histogram for "Combined score"

*average-UPs.r* - R script for expression averaging (averaging for different NAMs mapped to one UP)

- [ ] construction of STRING network for all mapped probes
