#!/srv/gs1/software/R/R-3.1.1/bin/Rscript


# The purpose of this script is to merge across all samples, and develop one gigantic file with all of the positions and counts for all ribo and rna samples
# the "glob2rx" string can be modified, but the point is that we merge all ribosome files first and then all rna seq files, and then merge those two files. It's important to have
# separate RIBO and RNA merged files. for analysis and confirmation
# nothing needs to be passed in for this script. 




#Get all of the directories that have the bam pileups
myDirecs = list.files("./", pattern=glob2rx("GM*Ribo_*reconcile"))
print(myDirecs)
table = 0 #this is the table that will contained the merged elements. 

for (i in 1:length(myDirecs)){

	#Go into the directory that has the mat.output and pat.output for the ribo bam of interest
	string = getwd()
	directory = paste(string, "/", myDirecs[i], sep="")
	setwd(directory)
	
	print ("Getting mat.output")
	print ("Getting pat.output")

	mat = read.table("mat.output", header = T)
	pat = read.table("pat.output", header = T)
	
	#The only thing we're interested in merging are the total read counts of maternal and paternal
	matshrunk = mat[,1:4]
	patshrunk = pat[,1:4]

	#Merge the maternal and paternal TOTAL read counts by "Gene" and "Start Position"
	new_merged = merge(matshrunk, patshrunk, by=c("Gene", "Start_Position"), all = TRUE, suffixes = " ")

	print("Merged mat.output and pat.output")

	write.table(new_merged, "new_merged", row.names = FALSE)

	print("Written merged file to new_merged")

	# The idea is that we first merge the maternal and paternal read counts of each sample,a nd then merge that file (titled 'new_merged') to the bigger table that we are using to keep track of all merged elements thus far by sample. So we want to keep merging until there are no more to merge 

	#thus in the folowing for loop we are merging the new_merged to table for each sample
	if (i == 1){

	print ("First Sample")
	table = read.table("new_merged", header = T)

	} else {

	newtable = read.table("new_merged", header = T)
	table = merge(table, newtable, by=c("Gene", "Start_Position"), all = TRUE, suffixes = " ")
	
	}

	setwd(string)
}

#Write this table as RIBO_MERGED, and get rid of all the NAs
table[is.na(table)] =  0

ribotable = table

write.table(table, "RIBO_MERGED", row.names = FALSE, sep = "\t", quote = F)


#Repeat the same process for RNA. 
myDirecs = list.files("./", pattern=glob2rx("GM*RNAseq*reconcile"))
print(myDirecs)


for (i in 1:length(myDirecs)){
        string = getwd()
        directory = paste(string, "/", myDirecs[i], sep="")
        setwd(directory)
        
        print ("mat.output")
        print ("pat.output")

        mat = read.table("mat.output", header = T)
        pat = read.table("pat.output", header = T)
        matshrunk = mat[,1:4]
        patshrunk = pat[,1:4]
        new_merged = merge(matshrunk, patshrunk, by=c("Gene", "Start_Position"), all = TRUE, suffixes = " ")
        

	print ("Merged mat.output and pat.output")
        write.table(new_merged, "new_merged", row.names = FALSE)
        print ("Wrote file to new_merged")

        if (i == 1){
        print ("First RNA sample")
        table = read.table("new_merged", header = T)
        } else {
        newtable = read.table("new_merged", header = T)
        table = merge(table, newtable, by=c("Gene", "Start_Position"), all = TRUE, suffixes = " ")
        
        }
        setwd(string)
}

#Write this table as RNA_MERGED and get rid of NAs
table[is.na(table)] = 0
rnatable = table
write.table(table, "RNA_MERGED", row.names = FALSE, sep = "\t", quote = F)


#Merge both of the RIBO and RNA and called it MERGED
bothmergedtable = merge(ribotable, rnatable, by = c("Gene", "Start_Position"), all = TRUE, suffixes = " ")
bothmergedtable[is.na(bothmergedtable)] = 0
write.table(bothmergedtable, "MERGED", row.names = FALSE, sep = "\t", quote = F)
