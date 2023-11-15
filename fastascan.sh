#!/usr/bin/env bash

### Defining directory ###

if [[ -z $1 ]]
then
	directory=$PWD
else
	directory=$1
fi


### Defining number of lines ###

if [[ -z $2 ]]
then
	lines=0 
else
	lines=$2
fi


### Report of all the files ###

	# Header 

echo '================================================================'
echo '======================== SUMMARY ==============================='
echo '================================================================'
echo
	# Number of files and IDs
echo Total number of .fasta and .fa files in the specified folders and its subfolders: $(find $directory -name "*.fasta" -or -name "*.fa" | wc -l) 

echo Number of unique fasta IDs: $(grep ">" $(find $directory -name "*.fasta" -or -name "*.fa") | awk '{print substr($1 , index($1 , ">"))}' | sort | uniq | wc -l) # grep ">" vs cat | awk?



### Report of each file ###

	# Header
echo 
echo 	
echo '================================================================'
echo '================== INDIVIDUAL REPORT ==========================='
echo '================================================================'
echo 
	# Report
	
find $directory -name "*.fasta" -or -name "*.fa" | while read file; do
	echo ===== $file ===== 				# header with file name
	echo
	if [[ -h $file ]]; then	 			# is it a symlink?
		echo This file is a symbolic link
	else
		echo This file is not a symbolic link
	fi
	echo
	echo This file contains $(grep -c ">" $file) sequences # number of fasta headers ">"
	echo
	echo The total number of aa / nucleotides is: $(echo $(grep -v ">" $file) | sed 's/ //g' | wc -m)
	echo

	
done


