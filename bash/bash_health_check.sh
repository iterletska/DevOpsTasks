#!/bin/bash

# Prompt the user for the name of the file containing the list of hosts
echo "Enter the name of the file containing the list of hosts:"
read host_list

# Prompt the user for the number of ping packets to send
while true; do
  echo "Enter the number of ping packets to send:"
  read packets
  if [[ $packets =~ ^[1-9][0-9]*$ ]]; then
    break
  else
    echo "Invalid input. Please enter a valid number."
  fi
done

# Prompt the user for the time interval between ping packets
while true; do
  echo "Enter the time interval between ping packets (in seconds):"
  read interval
  if [[ $interval =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    break
  else
    echo "Invalid input. Please enter a valid number."
  fi
done

# Create a timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Loop through the list of hosts and ping each one
while IFS=$',\r' read -r host; do
  # Ping the host and save the output to a variable
  output=$(ping -c "$packets" -i "$interval" "$host")

  # Extract the packet loss percentage from the output
  loss=$(echo "$output" | awk '/packet loss/ {print $6}' | cut -d'%' -f1)
  echo "$loss - packets are lost"

  # Determine whether the ping was successful or not
  if [ "$loss" -eq 0 ]; then
    result="SUCCESS"
  else
    result="FAILURE"
  fi

  # Log the results to a file
  echo "$timestamp $host - $packets packets sent, $(expr $packets - $loss) packets received, $loss% packets are lost, $result" >> ping_log.txt

  # Output a message for the user
  echo "$host ping result: $result"

done < "$host_list"