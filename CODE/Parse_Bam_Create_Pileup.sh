#!/bin/bash


<< COMMENTS
This script processes the bam file that is passed in, and takes the ID of the bam file and makes a directory out of it.
$1 should be the bam file
$2 should be the output directory where you want your output files to go
$3 should be the directory where Parse_Pileup.pl file is
$4 should be the absolute path to the 'Variant Calling File' 
COMMENTS


echo "Processing $1 file..."

string1=${1##*/} # this grabs the name of the bam file

echo "processing $string1"

str1=${string1%%.*} # this grabs the name of the bam before the *.bam*

echo "Making directory $str1"

module load samtools/1.2 # load the samtools module. Please load the latest version (and feel free to change this) because only the latest version I can tell for a fact that it doesn't double count paired ended reads. For the purposes of this project, it did NOT make a significant difference at all (always a couple of reads here and there). 

mkdir ./$str1 # create a directory with the name of the BAM

cd ./$str1

<< COMMENTS

Then out of the bamfile, we extract paired end reads and separate them into maternal and paternal bam files, by grepping the maternal and paternal reads from the new modified bam file (which contains only paired reads. Then we use samtools to create paired reads. 

COMMENTS

echo "Getting Header"
samtools view -H $1 > maternal.sam 

echo "Copying to File"
cp maternal.sam paternal.sam

echo "Maternal"
samtools view $1 | grep "RG:Z:maternal" >> maternal.sam 

echo "Paternal"
samtools view $1 | grep "RG:Z:paternal" >> paternal.sam

echo "Making The Bam Files"
samtools view -bS maternal.sam > maternal.bam
samtools view -bS paternal.sam > paternal.bam

echo "Making The Pileup Files"
samtools mpileup -AB -C=0 -Q=0 -q=0 maternal.bam > mat.pileup
samtools mpileup -AB -C=0 -Q=0 -q=0 paternal.bam > pat.pileup

currentdir=$(pwd)

<< COMMENTS
These perl scripts will intake the pileup files and the vcf-heterozygote files and create an output file for maternal and paternal reads. 
COMMENTS


$3/Parse_Pileup_Files.pl -filename=$str1 -vcf_file=$4 -pileup_file=$currentdir/mat.pileup

$3/Parse_Pileup_Files.pl -filename=$str1 -vcf_file=$4 -pileup_file=$currentdir/pat.pileup





