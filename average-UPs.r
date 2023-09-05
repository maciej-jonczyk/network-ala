# Works on output of string12-network.sh #9.
# R code for averaging congruent (the same sign) values for UPs with multiple NAMs
# reading data
s16=read.table("x10", header=F, sep=" ")
head(s16)
# averaging values
sred=aggregate(s16$V2, list(s16$V3), FUN=mean)
# concatenating repeated NAMs for one UP
library(dplyr)
s16con <- s16 %>%
  dplyr::group_by(V3) %>%
  dplyr::summarise(V1 = paste(V1, collapse = ","))
# Exporting. joining will be done in bash
write.table(s16con, "x10con", quote=F, row.names=F, sep=" ")
write.table(sred, "x10sr", quote=F, row.names=F, sep=" ")
