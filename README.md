# From microarray results to network

The aim of this repo is create protein interaction network for gene expression data in maize.
The starting point is a mapping between oligo probes (abbreviated MZ) to maize genes (NAM v5 assembly, dubbed NAM).
The code for MZ-NAM mapping is not included here.

The primary ID type in STRING v 12 is UniProt and mapping to AGPv4 is included.
There is UniProt - NAM mapping in file Zm-B73-REFERENCE-NAM.UniProt.proteins.tab from https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/
So I'll use UniProt.
