README

CODE FLOW: These are scripts you submit to the commandline in the order given

Submit_Script.sh (utilizes Parse_Bam_Create_Pileup.sh and Parse_Pileup.pl)
Merge.R
Merge.sh (utilizes createBoth.R and RiboRnaSamples) 
wrap_BootStrap.sh  (utilizes BootStrap.pl)
wrap_MergingAcrossPositions (utilizes  mergingAcrossPositions and combine.R)
wrap_BootstrapR.sh (utilizes Bootstrap.R)

1) Submit_Script:

After this script, you will have a directory for each sample replicate, and inside it will be the pileup files and the list of heterozygous positions in the mat.output and pat.output files. 

Commandline execution: 

bash Submit_Script4.sh /directory/to/bam/files /directory/to/where/you/want/outputs/to/go /directory/to/Parse_Pileup.pl /directory/to/Parse_Bam_Create_Pileup.sh /absolute/path/to/the/vcf/file

2) Merge.R

After this your directory should have three files: RIBO_MERGED, RNA_MERGED, and MERGED. You don't need any arguments for this, but look at the globrx patterns within the script to make sure that they match what it needs to be. The script will run some code twice, one for RIBO, and one for RNA, so you want to make sure that the first time, ti's getting all the RIBO replicates, and the second time it's getting only the RNA replicates

Commandline execution:

Rscript Merge.R

3) Merge.sh

After this script, your directory should have a bunch of '.BOTH' files, one for each sample. THis .BOTH file will have all of the heterozygous positions with maternal and paternal RIBO and RNA reads, all that passed the maternal + paternal >= 20 cutoff.  
However, this script uses a file that the user has to create. For all of the samples that the user wants to create a .BOTH for, they have to provide how many RIBO and RNA replicates it has in this form:

Sample1:RiboReplicates:RNAReplicates
Sample2:RiboReplicates:RNAReplicates
....

We will call this file RiboRnaSamples

Commandline Execution:

bash Merge.sh /absolute/path/to/RiboRnaSamples absolute/path/to/the/MERGED/file/from/previous/step /directory/where/createBoth/is mutation_count_cutoff (default 20)

4) wrap_BootStrap.sh

After this script, all of your replicates should have positions files of all the positions in the .BOTH file. For example for Sample1Ribo_replicate1, should have files that say ENST...11230.543.maternalRIBO and ENST....11230.543.paternalRIBO, etc, etc, for multiple gene position coordinates that are in the sample's .BOTH file. These position files will have the position itself as well as read counts for the 30 positions prior to it (for RNA is 75 prior). Remember, that the read counts are not the total number of reads at that position, but ONLY of the number of reads that are at the beginning of a transcript at that position. 

Commandline Execution:
bash wrap_BootStrap.sh /directory/of/the/BootStrap.pl/script

5) wrap_MergingAcrossPositions

After this script, you should have a directory that is named just the sample_id. For example if you have GM10847 Rep1, Rep2, RNA1, RNA2, you will just now have one directory called GM10847. we will call this the sample directory and others replicate directories. This will contain files that are named the same as in the replicates, but instead their counts are the merged counts of all the replicates (RIBO and RNA separately)

Commandline Execution:
bash wrap_MergingAcrossPositions /directory/of/your/.BOTH/files

6) wrap_BootstrapR.sh
After this, all of your sample directories (not replicates, just the sample), you should have a file titled sampleID_Final_1000_Table that contains the bootstrap.R results for each position. 

Commandline Execution:

bash wrap_BootstrapR.sh 


OTHER SCRIPTS

1) Parse_Bam_Create_Pileup.sh

Parses Bam and Creates the Pileup. Separates the incoming bam file into maternal and paternal bams 

Execution:

bash Parse_Bam_Create_Pileup.sh /absolute/path/to/bam/file /directory/for/output /directory/of/Parse_Pileup.pl /absolute/path/for/vcf/file

2) Parse_Pileup.pl

Parses the pileup file to create a file that has the following:
Gene	Start	TotalReadCount	A	T	C	G	Ref	Alt	Heterozygous

This file will be called mat.output or pat.output depending on which parent pileup has been fed. It also filters for heterozygous files. 

Commandline Execution:

perl Parse_Pileup.pl -filename=SampleWithReplicateName -vcf_file=/absolute/path/to/vcf/file -pileup_file=/current/directory/mat.pileup


3) createBoth.R

Creates the .BOTH file, given the MERGED file, and sample ID

Execution:

Rscript createBoth.R /absolute/path/to/MERGED/file sampleID numRiboReplicates numRNAReplicates

4) BootStrap.pl
Creates the position files for each sample replicate. Count here is how far you want to go back (30 for RIBO, and 75 for RNA).

perl BootStrap.pl  --count=30 --filename=SampleWithReplicateName --directory=/directory/of/BootStrap.pl --name=TheSuffixYouWantToAddToYourPositionFiles

5) mergingAcrossPositions.sh

Does the actual merging across replicates. 

Commandline Execution:

bash mergingAcrossPositions.sh /directory/of/this/script/ sample_ID SomeIdentificationToSeparateTheGroupOfReplicatesYouWantToMerge (so ideally this would be either RIBO or RNA)

6) combine.R

Just does the adding of the read count columns given two position files

Rscript combine.R /current/directory/ firstPosFile secondPosFile

7) Bootstrap.R

Does the Bootstrap calculations and algorithms

Rscript Bootstrap.R /absolute/path/to/the/.BOTH/file sample_ID












