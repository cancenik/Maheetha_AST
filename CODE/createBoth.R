#!/srv/gs1/software/R/3.2.0/bin/Rscript

#The purpose of this script is to take MERGED file and give back a list of positions whos maternal and paternal RIBO and RNA counts add up to greater
#than or equal to 20, and report the initial overall read counts across heterozygous positions that pass the 20 read count cutoffs. 



args = commandArgs(trailingOnly = TRUE)

MERGED = read.table(args[1], header = T, stringsAsFactors = F)



columnextract = args[2]
numRibo = as.numeric(as.character(args[3]))
numRNA = as.numeric(as.character(args[4]))
columns = grep(columnextract, names(MERGED))

if (args[5] == NULL){
mutation_count = 20

} else {
mutation_count = as.numeric(as.character(args[5]))

}
#Get the columns out of merged that represent the counts for the Ribo and the RNA maternal and paternal (all samples)
# for example if our sample name was GM17889, we would get all of the columns from MERGED with sample header GM17889 in it
# let's say that GM17889 had one ribo and two rna replicates the new SAMPLE dataframe would have column names in this order

# GM17889_Maternal GM17889_CountsTotalMaternalRIBO GM17889_Paternal GM17889_CountsTotalPaternalRIbo GM17889_MaternalRNA_rep1 GM17889_CountsTotalMaternalRNA_rep1 etc. etc. etc. "
# all of the ribo replicates would be first and then the RNA replicates

SAMPLE = MERGED[,columns]

# when we add up the counts across the replicates we need to store them somewhere. This is where we store them
TotalMatRibo = rep(0, length(SAMPLE[,1]))
TotalPatRibo = rep(0, length(SAMPLE[,1]))
TotalMatRna = rep(0, length(SAMPLE[,1]))
TotalPatRna = rep(0, length(SAMPLE[,1]))

#Once you get the SAMPLE columns, the maternal starts at the 2nd column, and paternal starts at the 4th column
startmat = 2
startpat = 4

# This for loop adds across ribo replicates
for (x in 1:numRibo){
	TotalMatRibo = TotalMatRibo + SAMPLE[,startmat]
	TotalPatRibo = TotalPatRibo + SAMPLE[,startpat]
	startmat = startmat + 4
	startpat = startpat + 4
}

# This for loop adds across rna replications
for (y in 1:numRNA){
	TotalMatRna = TotalMatRna + SAMPLE[,startmat]
	TotalPatRna = TotalPatRna + SAMPLE[,startpat]
	startmat = startmat + 4
	startpat = startpat + 4
}

# after we've merged everything we bind them together, add the gene and position names, and then filter for maternal + paternal >= 20 across ribo and rna replicates

temp = cbind(TotalMatRibo, TotalPatRibo, TotalMatRna, TotalPatRna)
names(temp) = c("TotalMatRibo", "TotalPatRibo", "TotalMatRna", "TotalPatRna")
final = cbind(MERGED$Gene, MERGED$Start_Position, temp)
final = data.frame(final, stringsAsFactors = F)
final = subset(final, as.numeric(final[,3]) + as.numeric(final[,4]) >= mutation_count)
final = subset(final, as.numeric(final[,5]) + as.numeric(final[,6]) >= mutation_count)

#We are naming this "SampleName.BOTH"
string = paste(columnextract, "BOTH", sep = ".")
write.table(final, string, row.names = F, sep = "\t", quote = F)


