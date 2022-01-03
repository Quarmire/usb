#!/bin/bash

# Load the USB/IP kernel driver
modprobe usbip_host

PID="`pidof usbipd`"

if [[ -n "$PID" ]]
then
  echo -e "USB/IP daemon is already running (pid: $PID)\n"
else
  # Start the USB/IP daemon
  echo "Starting USB/IP daemon"
  /usr/lib/linux-tools/$(uname -r)/usbipd -D
  echo -e "process id: `pidof usbipd`\n"
fi

# List local USB devices
/usr/lib/linux-tools/$(uname -r)/usbip list -l  2>/dev/null

echo -n "Would you like to bind a device? (y/n) "
read x

if [[ $x = yes || $x = y ]]
then
  # Enter device bus ID to bind
  echo -n "Enter device bus ID: "
  read bus_id
  /usr/lib/linux-tools/$(uname -r)/usbip bind -b $bus_id
else
  echo "Exiting without binding any device"
fi
