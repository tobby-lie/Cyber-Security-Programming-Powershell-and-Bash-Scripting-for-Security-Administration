#!/bin/bash

start_time="$(date -u +%s)"
while true
do
	nmap -vv 192.168.10.*/24 | grep -E "Discovered open port" > initial_output.txt		

	init_arr=()
	if [ -s initial_output.txt ]
	then
		mapfile -t myArray < initial_output.txt
		while IFS= read -r line; 
		do 
			init_arr+=("$line"); 
		done < initial_output.txt
	fi
	
	curr_time="$(date -u +%s)"
	elapsed="$((curr_time - $start_time))"
	echo "Current time: $elapsed seconds"
	sleep 300
	
	nmap -vv 192.168.10.*/24 | grep -E "Discovered open port" > new_output.txt	

	fin_arr=()
	if [ -s new_output.txt ]
	then
		mapfile -t myArray < new_output.txt
		while IFS= read -r line; 
		do 
			fin_arr+=("$line"); 
		done < new_output.txt
	fi

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

