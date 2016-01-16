#!/bin/bash


<< COMMENTS
The purpose of this script is to merge across all positions given a particular sample and whether it's RNA or RIbosome

$1 the directory you passed in to wrap_mergeAcrossAllPositions.sh
$2 the sample name
$3 whether it's RNA or RIBO samples

General Code FLow:
For this script, we will be passed in a directory, a sample_id, and RIBO or RNA, to make this merging process very simplified. 
HEre are the steps of the code flow

If we are on our first replicate
	we copy all of the contents of that replicated into a newly made directory that is named just the sample id
	*Note** we will be doing this separately for RIBO and RNA

If we are in our subsequent replications
	we go into the sample id directory (which should have ENST***maternalRIBO/RNA and ENST***paternalRIBO/RNA files right now )
	We find the matching positions files. For example, if the sample Id directory has ENST0001.456.maternalRIBO, we try to find the same file in the now replicate directory
	We then use combine.R to simply merge the counts across those files. We know that they have the same psitions so it's just a matter of adding the 3rd columns

COMMENTS


# grab all the samples that belong to a certain RNA type and sample
FILES=$2*$3


#intialize a string that will keep track of which sample we're on
old_string="nothing"

for f in $FILES
do
	
	IFS='_' read -a array <<< "$f"
	new_string=${array[0]} # also initiazlie a new_String that will keep track of the current sample

	# if we are on our ifrst sample
	if [ "$old_string" != "$new_string" ]
	then 
		echo "Checkpoint 1"
	# we are going to make a directory and just copy all of the maternal and paternal RNA/RIBO files from the first sample's directory. 
		mkdir ${array[0]}
		files=$1/$f/*
		for d in $files
		do
			cp $d ./${array[0]}
		done
	
	fi
	

	# if this isn't our first sample, then we have to merge. And we use the "combine.R" to do that
	if [ "$old_string" == "$new_string" ]
	then
	files=$1/$f/*
		for g in $files
			do
			IFS='/' read -a array2 <<< "$g"
		# we get the length of the "array" which is just breaking down the file name to get the ENST* file 
			len=${#array2[@]}
			len=$((len-1))
			other_file=$1/${array[0]}/${array2[$len]}
			cd ./${array[0]}

		# now you have the files you use combine.R to combine them 
			$1/combine.R $f $other_file $1/$f/${array2[$len]}
			cd ..

			done
	fi

	# we always updated our current and old samples
	old_string=$new_string
done

