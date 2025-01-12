#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root!"
  exit 1
fi

# Check if airbase-ng is installed
if ! command -v airbase-ng &> /dev/null; then
  echo "airbase-ng is not installed. Please install it and try again."
  exit 1
fi

# Get the wireless interface to use
read -p "Enter the wireless interface (e.g., wlan0): " interface

# Put the interface into monitor mode
echo "Setting up $interface in monitor mode..."
airmon-ng start $interface

# Ask for the input file containing Wi-Fi names
read -p "Enter the path to the text file with fake Wi-Fi names: " file_path

# Check if the file exists
if [[ ! -f $file_path ]]; then
  echo "File not found: $file_path"
  airmon-ng stop "${interface}mon"
  exit 1
fi

# Read Wi-Fi names from the file
ssids=()
while IFS= read -r line || [[ -n "$line" ]]; do
  ssids+=("$line")
done < "$file_path"

# Start creating fake Wi-Fi networks
echo "Starting fake Wi-Fi networks..."
for ssid in "${ssids[@]}"; do
  echo "Creating fake Wi-Fi: $ssid"
  airbase-ng --essid "$ssid" -c 6 "${interface}mon" &
  sleep 1
done

echo "Fake Wi-Fi networks are now broadcasting. Press Ctrl+C to stop."

# Wait for the user to stop the script
trap 'echo "Stopping..."; killall airbase-ng; airmon-ng stop "${interface}mon"; exit 0' SIGINT
wait
