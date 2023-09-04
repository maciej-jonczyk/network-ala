# Histogram for "Combined score" from STRING network
# source ile made in string12-network.sh file
punkt=read.table("x6", sep=" ", header=T)
head(punkt)
str(punkt)
hist(punkt$combined_score)
hist(punkt$combined_score, breaks=100)
hist(punkt$combined_score, breaks=200)
hist(punkt$combined_score, breaks=300)
# Plots don't show any obvious cut-off point
# 400 cutof will be used as previously
