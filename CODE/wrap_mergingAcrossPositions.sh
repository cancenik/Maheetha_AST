#!/usr/bin/bash
<<COMMENTS

The purpose of this file is to help merge across replicates

this is the wrapper script

$1 = the directory in which all of the scripts are


COMMENTS

FILES=*.BOTH

for f in $FILES
	do
	IFS='.' read -a array2 <<< "$f"
	qsub -cwd -o output.err -e err.err ./mergingAcrossPositions.sh $1 ${array2[0]} RNAseq*reconcile
	qsub -cwd -o output.err -e err.err ./mergingAcrossPositions.sh $1 ${array2[0]} Ribo_*reconcile
	done
