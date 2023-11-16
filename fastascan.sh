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
	# Warning 
echo	
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo
echo "This script considers a .fasta or .fa file to be a nucleotide (RNA or DNA) sequence if the content of A, C, T, G, U and N in the sequences contained in the file is greater or equal than 90%. If this condition is not fulfilled, the file will automatically be considered a protein sequence file." 

echo 
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
	
	# number of characters in sequences of the file that may be nucleotides -- considering mainly A, C, T, G, U and N as the characters that encode nucleotides that will be mostly present in the sequences
	
	num_A=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c A)
	
	num_C=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c C)
	
	num_T=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c T)
	
	num_G=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c G)
	
	num_N=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c N)
	
	num_U=$(grep -v ">" $file | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -c U)

	# proportion of these characters withrespect to the rest of characters of the sequences of the file
	
	total_chars_sequences=$(grep -v ">" $file | tr -d "\n"" ""\-" | wc -m)
	
	nucleotide_pct=$(( 100*(num_A+num_C+num_T+num_G+num_N+num_U)/$total_chars_sequences  ))
	
	# If nucleotide_pct >= 90%, the fasta is considered a nucleic acid fasta
	if [[ $nucleotide_pct -ge 90 ]]; then
		echo This file contains $(grep -c ">" $file) nucleic acid sequences # number of fasta headers ">"
		echo The total number of nucleotides in the sequences of this file is: $total_chars_sequences
	
	else
		echo This file contains $(grep -c ">" $file) protein sequences # number of fasta headers ">"
		echo The total number of amino acids in the sequences of this file is: $total_chars_sequences
	fi
	echo
done


