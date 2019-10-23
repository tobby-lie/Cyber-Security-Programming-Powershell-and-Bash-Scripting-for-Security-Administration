#!/bin/bash

# initialize start time
start_time="$(date -u +%s)"
while true
do
	# get all open ports and put in log file
	nmap -vv 192.168.10.*/24 | grep -E "Discovered open port" > initial_output.txt		

	# put each line of log file into array
	init_arr=()
	if [ -s initial_output.txt ]
	then
		mapfile -t myArray < initial_output.txt
		while IFS= read -r line; 
		do 
			init_arr+=("$line"); 
		done < initial_output.txt
	fi
	
	# get elapsed time and print out
	curr_time="$(date -u +%s)"
	elapsed="$((curr_time - $start_time))"
	echo "Current time: $elapsed seconds"
	sleep 300
	
	# get all discovered ports in second log file
	nmap -vv 192.168.10.*/24 | grep -E "Discovered open port" > new_output.txt	

	# get each line of log file into array
	fin_arr=()
	if [ -s new_output.txt ]
	then
		mapfile -t myArray < new_output.txt
		while IFS= read -r line; 
		do 
			fin_arr+=("$line"); 
		done < new_output.txt
	fi

	# for every element in second array
	# check if that element exists in the first array
	# if it does not then notate a new open port in third log file
	# else note that no open ports are discovered
	for i in "${fin_arr[@]}"
	do
		if [[ " ${init_arr[*]} " != *" $i "* ]]; then
			curr_time="$(date -u +%s)"
			elapsed="$(($curr_time-$start_time))"			
			echo "Time stamp: $elapsed seconds - $i" >> logfile.txt
		else
			curr_time="$(date -u +%s)"
			elapsed="$(($curr_time-$start_time))"			
			echo "Time stamp: $elapsed seconds - no open ports open since last execution" >> logfile.txt
		fi
	done

done

