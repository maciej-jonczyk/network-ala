# Wczytanie danych
s16=read.table("x16dousr_dane", header=F, sep=" ")
# Średnia
mean16=aggregate(s16$V2, list(s16$V1), FUN=mean)
write.table(mean16, "sr16", quote=F, row.names=F, sep=" ")
# zaokrąglenie już w bashu

s50=read.table("x50dousr_dane", header=F, sep=" ")
mean50=aggregate(s50$V2, list(s50$V1), FUN=mean)
write.table(mean50, "sr50", quote=F, row.names=F, sep=" ")

s68=read.table("x68dousr_dane", header=F, sep=" ")
mean68=aggregate(s68$V2, list(s68$V1), FUN=mean)
write.table(mean68, "sr68", quote=F, row.names=F, sep=" ")
