#!/srv/gs1/software/R/R-3.1.1/bin/Rscript
#The purposose of this script is to combine the columns of two seemingly bed files that are actually positions files 


args = commandArgs(trailingOnly = TRUE)
firstfile =  args[2]
secondfile = args[3]
table1 = read.table(secondfile, header = F, stringsAsFactor = F)
table2 = read.table(firstfile, header = F, stringsAsFactor = F)

new_vector = as.numeric(table1[,3]) + as.numeric(table2[,3])

table2 = paste(table1[,1], table1[,2], new_vector)

write.table(table2 , args[2], row.names = F, col.names = F, quote = F)

