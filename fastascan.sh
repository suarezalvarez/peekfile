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


### Report

echo '================================================================'
echo '======================== SUMMARY ==============================='
echo '================================================================'

list_of_fastas=$(find $directory -type f -name "*.fasta" -or -name "*.fa")

echo Total number of .fasta and .fa files in the specified folders and its subfolders: $(echo $list_of_fastas | wc -w) # 12 files but output = 11 ??


echo Number of unique fasta IDs: $(grep ">" $list_of_fastas | awk '{print substr($1 , index($1 , ">"))}' | sort | uniq | wc -l) # grep ">" vs cat | awk?


