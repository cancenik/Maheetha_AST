#!/usr/bin/bash

<<COMMENTS
This script takes all of the samples and runs the script Merge.R on them to merge the read counts across samples within Ribo and RNA

$1 should be file that contains the sample and how many replicates for ribosome and rna there are, in the format "SampleName:RiboReplicates:RnaReplicates

$2 should be the directory where the MERGED file is. Absolute path please.

$3 should be the directory where createBoth script is

$4 should be the mutation count cutoff. The minimum number of reads you want (maternal + paternal). Default is set to 20. 

COMMENTS
file=$1

while read line
	do
	IFS=':' read -a arr <<< "$line"
	echo ${arr[0]}
	echo ${arr[1]}
	echo ${arr[2]}
	qsub -cwd -o ${arr[0]}.Merge.out -e ${arr[0]}.Merge.err $3/createBoth.R $2 ${arr[0]} ${arr[1]} ${arr[2]} $4
	done < $file
