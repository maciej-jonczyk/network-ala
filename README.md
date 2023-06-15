# From microarray results to network

The aim of this repo is create protein interaction network for gene expression data in maize.
The starting point is a mapping between oligo probes (abbreviated MZ) to maize genes (NAM v5 assembly, dubbed NAM).
The code for MZ-NAM mapping is not included here.

I'll use data from STRING v 11.5. The problem is that that release still use v3 gene IDs (abbreviated v3).
So NAM-v3 mapping is needed. It was retrieved from [http:/](https://maizegdb.org/)https://maizegdb.org/.
This file was modified to conatin NAM-v3 in two columns. Some IDs are multimmaped, it happens in both directions (NAM->v3, v3->NAM).

To use 
