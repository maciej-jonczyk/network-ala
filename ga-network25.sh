# 31.01.25
# Network for gibberellin-related genes
# Employs natwork file from network-map-string.sh from this repo
# Expression data come from Ala's RT-qPCR experiments - summarized in ga4network file (not included here due to unpublished status)
## expression data with AGPv3 IDs mapped to NAMv5 and anno-all-wide annotation from annotation.sh file

# ala-ga25 level
# Select subnetwork form full network
grep -f x4wyborid ../siec-ala-string/mapped/net-full > x
# Save header
head -n1 ../siec-ala-string/mapped/net-full > x2
# Concatenate
cat x2 x > net-ga

# Check in Cytoscape

# Manually inspect expression data
# GRMZM2G022679 has results from two pairs of primers giving absolutely opposite change - dat excluded (but IDs kept)
# GRMZM2G006964 has results from three pairs of primers - congruent changes so mean is used
# Saved in ga4network-dot-manual.ods file
# Export to csv file and change empty values to zeroes
sed 's/\t\t/\t0\t/g;s/\t$/\t0/g' ga4network-dot-manual.csv > x
# Add heade - important as it identify maize lines
head -1 zest_gib_uzup.csv > xhead
# Concatenating
cat xhead x > x2
# Remove unneded columns
cut -f3,4 -d $'\t' --complement x2 > expr4node
# Manual adjustemnts of names
# Files anno-all-wide and expr4node can be imported to Cytoscape as node tables
