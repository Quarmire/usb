#!/bin/bash
busids=""
capture_next=0

for OUTPUT in $(/usr/lib/linux-tools/$(uname -r)/usbip list -l 2>/dev/null)
do
  if [[ $capture_next == 1 ]]
  then
    busids="$busids $OUTPUT"
    capture_next=0
  fi

  if [[ $OUTPUT == busid ]]
  then
    capture_next=1
  fi
done

if [[ $busids != "" ]]
then
  declare -A bound_devices
  echo "Currently bound devices:"
  INDEX=0
  for ID in $busids
  do
    if [[ -n $(usbip list -r 0.0.0.0 2>/dev/null | grep $ID) ]]
    then
      arg=`echo "$ID" | tr - :`
      echo "($INDEX) `lsusb -s $arg`"
      bound_devices[$INDEX]=$ID
      INDEX=$((INDEX+1))
    fi
  done
  bound_devices[$INDEX]="all"

  if [[ ${bound_devices[0]} != all ]]
  then
    echo "($INDEX) unbind all"
    echo -n "Select a device to unbind: "
    read dev
    if [[ $dev == $INDEX ]]
    then
      for (( i=0; i<$INDEX; i++ ))
      do
        arg=`echo "${bound_devices[$i]}" | tr - :`
        echo "Unbinding `lsusb -s $arg -v 2>/dev/null | grep iProduct`"
        /usr/lib/linux-tools/$(uname -r)/usbip unbind -b ${bound_devices[$i]}
      done
    else
      /usr/lib/linux-tools/$(uname -r)/usbip unbind -b ${bound_devices[$dev]}
    fi
  else
    echo "Exiting: no devices to unbind"
  fi
else
  echo "Exiting: no devices to unbind"
fi

PID=`pidof usbipd`
if [[ -n $PID ]]
then
  echo -n "USB/IP daemon is running (pid: $PID). Would you like to terminate it? (y/n) "
  read x

  if [[ $x = yes || $x = y ]]
  then
    kill -15 $PID
    echo "USB/IP daemon terminated"
  fi
fi
