#!/usr/bin/env bash


### Defining number of lines ###

if [[ -z $2 ]]
then
	lines=0 
elif echo $2 | grep -q "\."; then
	lines=$(echo $2 | awk '{print substr($0 , 1 , index($0 , ".")-1)}') # if $2 is a floating point number, remove point 

elif ! echo $2 | grep -qE '^[0-9]+$' && [[ -n $2 ]]; then
	echo
	echo Please, introduce a valid number of lines
	echo
	exit 3

else
	lines=$2
fi


### Defining directory ###

if [[ -z $1 ]]
then
	directory=$PWD
	
elif echo $1 | grep -qE '^[0-9]+$' && [[ -z $2 ]]; then 	# if the 1st argument is an integer, and there is not 2nd argument, interpret the 1st as the number of lines
	lines=$1
	directory=$PWD

else
	directory=$1
fi





### Report of all the files ###

	# Warning 

echo	
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!IMPORTANT INFORMATION!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "This program uses 2 arguments: the directory and the number of lines of each file to show." 
echo "If you only specify one of them, it will be interpreted as the number of lines if this argument is an integer, and as the directory if it is a text string."
echo
echo "This program considers a .fasta or .fa file to be a nucleotide (RNA or DNA) sequence if the content of A, C, T, G, U and N (upper or lower case) in the sequences contained in the file is greater or equal than 90%. If this condition is not fulfilled, the file will automatically be considered a protein sequence file." 
echo 
echo 'This program considers the first word (delimited by spaces) after the ">" symbol in a fasta header as the identifier of the sequence.'
echo

	# Header 

echo '================================================================'
echo '======================== SUMMARY ==============================='
echo '================================================================'
echo

	# Number of files and IDs

if [[ ! -d $directory ]]; then echo The directory $(echo \'$directory\') does not exist; echo ; exit 2; fi # if the directory doesn't exist, exit


echo Total number of .fasta and .fa files in the specified folders and its subfolders: $(find $directory \( -name "*.fasta" -or -name "*.fa" \) \( -type f -or -type l \) | wc -l) 

if [[ $(find $directory \( -name "*.fasta" -or -name "*.fa" \) \( -type f -or -type l \) | wc -l) -eq 0 ]]; then exit 1; fi      # exit program if there are no fasta files in the directory


echo Number of unique fasta IDs: $(grep ">" $(find $directory \( -name "*.fasta" -or -name "*.fa" \) \( -type f -or -type l \) ) | awk '{print substr($1 , index($1 , ">"))}' | sort | uniq | wc -l) 



### Report of each file ###

	# Header
	
echo 
echo 	
echo '================================================================'
echo '================== INDIVIDUAL REPORT ==========================='
echo '================================================================'
echo 


find $directory \( -name "*.fasta" -or -name "*.fa" \) \( -type f -or -type l \) | while read file; do 			# loop over each file name

	if ! awk -F '' 'NR==1{print $1}' "$file" | grep -q ">" ; then 							# go to next file if the first line is not a fasta header (to avoid reading binary files)
	echo ========== "$file" ==========
	echo
	echo This file does not contain sequences in fasta format
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
	
	
		echo $(grep -c ">" "$file") nucleic acid 'sequence(s)' 		# number of fasta headers ">"
		echo
		echo $total_chars_sequences nucleotides in the sequences of this file
	
	
	
	
	else
		echo
		echo ========== "$file" [PROTEIN FASTA FILE] ==========  		 	# header with file name for proteins
		echo	
		
		
		echo $(grep -c ">" "$file") protein 'sequence(s)' 		# number of fasta headers ">"
		echo
		echo $total_chars_sequences amino acids in the sequences of this file
	fi
	echo
	
	
	
	
	if [[ -h "$file" ]]; then	 							# is it a symlink?
		echo Symbolic link
	else
		echo Not a symbolic link
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
