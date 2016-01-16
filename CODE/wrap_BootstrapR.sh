#!/usr/bin/bash

<< COMMENTS

$1 should be the number of rounds you want each bootstrap to go for. The default is 1000. 
COMMENTS
FILES=*.BOTH

for f in $FILES
	do
		
		IFS='.' read -a array2 <<< "$f"
		echo ${array2[0]}
		cp $f ./${array2[0]}/$f
		cp ./Bootstrap.R ./${array2[0]}/Bootstrap.R
		cd ./${array2[0]}
		qsub -cwd -o $f.out -e $f.err ./Bootstrap.R $f ${array2[0]} $1
		cd ..
	done
