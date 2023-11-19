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
echo "This program considers a .fasta or .fa file to be a nucleotide (RNA or DNA) sequence if the content of A, C, T, G, U and N in the sequences contained in the file is greater or equal than 90%. If this condition is not fulfilled, the file will automatically be considered a protein sequence file." 
echo 
echo 'This program considers the first word (delimited by spaces) after the ">" symbol in a fasta header as the identifier of the sequence.'
echo

	# Header 

echo '================================================================'
echo '======================== SUMMARY ==============================='
echo '================================================================'
echo

	# Number of files and IDs
	
echo Total number of .fasta and .fa files in the specified folders and its subfolders: $(find $directory -name "*.fasta" -or -name "*.fa" | wc -l) 

if [[ $(find $directory -name "*.fasta" -or -name "*.fa" | wc -l) -eq 0 ]]; then exit 1; fi      # exit program if there are no fasta files in the directory

echo Number of unique fasta IDs: $(grep ">" $(find $directory -name "*.fasta" -or -name "*.fa") | awk '{print substr($1 , index($1 , ">"))}' | sort | uniq | wc -l) 



### Report of each file ###

	# Header
	
echo 
echo 	
echo '================================================================'
echo '================== INDIVIDUAL REPORT ==========================='
echo '================================================================'
echo 


find $directory -name "*.fasta" -or -name "*.fa" | while read file; do 			# loop over each file name

	if ! grep -q ">" "$file"; then 							# go to next file if there are no fasta headers in the current file (to avoid reading binary files)
	echo ========== "$file" ==========
	echo
	echo This is file does not contain sequences in fasta format
	continue
	 
	fi 

	# number of characters in sequences of the file that may be nucleotides -- considering mainly A/a, C/c, T/t, G/g, U/u and N/n as the characters that encode nucleotides that will be mostly present in the sequences
		
	num_nucleotides=$(grep -v ">" "$file" | tr -d "\n""\-"" " | awk -F '' '{for (i=1; i<=length($0); i++) { print $i }}' | grep -ic [ACTGUN])
	

	# proportion of these characters withrespect to the rest of characters of the sequences of the file
	
	total_chars_sequences=$(grep -v ">" "$file" | tr -d "\n"" ""\-" | wc -m)
	
	nucleotide_pct=$(( 100*(num_nucleotides)/$total_chars_sequences ))
	
	
	
	
	# Report
	
	
	
	if [[ $nucleotide_pct -ge 90 ]]; then 						# If nucleotide_pct >= 90%, the fasta is considered a nucleic acid fasta
	
	
		echo
		echo ========== "$file" [NUCLEIC ACID FASTA FILE] ========== 			# header with file name for nucleic acids
		echo
	
	
		echo This file contains $(grep -c ">" "$file") nucleic acid 'sequence(s)' 		# number of fasta headers ">"
		echo
		echo The total number of nucleotides in the sequences of this file is: $total_chars_sequences
	
	
	
	
	else
		echo
		echo ========== "$file" [PROTEIN FASTA FILE] ==========  		 	# header with file name for proteins
		echo	
		
		
		echo This file contains $(grep -c ">" "$file") protein 'sequence(s)' 		# number of fasta headers ">"
		echo
		echo The total number of amino acids in the sequences of this file is: $total_chars_sequences
	fi
	echo
	
	
	
	
	if [[ -h "$file" ]]; then	 							# is it a symlink?
		echo This file is a symbolic link
	else
		echo This file is not a symbolic link
	fi
	echo
	
	
	
	
	
	
	if [[ $lines -eq 0 ]]; then								# if $lines == 0 go to the next file
		continue
		
	elif [[ $(cat "$file" | wc -l) -le $((2*$lines)) ]]; then
	
	echo '-- previsualization of the file content--'
	echo 
	cat "$file"										# if number of lines of file <= 2*input number of lines, then print the whole input file


	else
	echo '-- previsualization of the file content --'
	echo
	echo "[!!!]WARNING: Only the first and last $lines lines are printed[!!!]"
	echo
	head -n $lines "$file"
	echo "..."
	tail -n $lines "$file"   								# if number of lines of file > 2*$lines, then print "$lines" first and last lines
fi		
	
done


