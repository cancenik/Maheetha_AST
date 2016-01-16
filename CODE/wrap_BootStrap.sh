#!/usr/bin/bash


<<COMMENTS 

The purpose of this script is to create a maternal and paternal position file for each position that contains the previous 30 (if it's a Ribo file) and 75 (if it's an RNA file)
THus, we go into all of our sample directories, and execute BootStrap.pl which will create a maternal and paternal file for each position that is in the ".BOTH" file for that particular sample. Thus in each sample directory, after the execution of this script, we should have a bunch of ".maternalRIBO/RNA" and ".paternalRIBO/RNA". Each positions will have a paired .maternalRIB/RNA and .paternalRIBO/RNA file.

$1 is the directory of BootStrap.pl script

COMMENTS

files=GM*_Ribo_reconcile
echo $files
for f in $files
	do
	cd ./$f
	qsub -cwd -o $f.out -e $f.err $1/BootStrap.pl  --count=30 --filename=$f --directory=$1 --name='RIBO'
	cd ..
	done

files=GM*_RNAseq*_reconcile
echo $files
for f in $files
	do
        cd ./$f
        qsub -cwd -o $f.out -e $f.err $1/BootStrap.pl  --count=75 --filename=$f --directory=$1 --name='RNA'
        cd ..
        done
 
