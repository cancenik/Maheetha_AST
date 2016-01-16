#!/bin/bash

<<COMMENTS
This script takes all the bam files in a certain directory, 
and submits them as a qsub job. The job of script 4 is to analyze the 
bam files.

$1 should be the directory with the bam files
$2 should be the directory where you want the outputs to go
$3 should be the directory where your Parse_Pileup.pl file is  
$4 should be the directory where your Parse_Bam_Create_Pileup.sh file is
$5 should be the absolute path to the 'Variant Calling File'

This script takes all of the bam files in a particular directory and runs the Parse_Bam_Create_Pileup.sh script on all of the bam files.
COMMENTS



FILES=$1/*.bam #$1 is the diretory of the bam files passed in

for bam in $FILES
do
qsub -cwd -l h_vmem=10G -l h_rt=90:00:00 $4/Parse_Bam_Create_Pileup.sh $bam $2 $3 $5
done



