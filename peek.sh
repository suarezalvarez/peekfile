#! /usr/bin/env bash

# Checking if there was input for the number of lines

if [[ -z $2 ]]
then
	lines=3	
else 
	lines=$2
fi



if [[ $(cat $1 | wc -l) -le $((2*$lines)) ]]
then
	cat $1		# if number of lines of file <= 2*input number of lines, then print the whole input file

elif [[ $(cat $1 | wc -l) -gt $((2*$lines)) ]]
then
	echo WARNING: Only the first and last $lines lines are printed
	head -n $lines $1
	echo "..."
	tail -n $lines $1   # if number of lines of file > 2*input number of lines, then print $lines first and last lines
fi		
