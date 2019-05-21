#!/usr/bin/env bash

#
# This Bash script automatically closes the doors of the Locker after N seconds
#

# Close lock after N seconds
MY_LOCK_SEC=15

# Create folder for status files
mkdir -p "/tmp/door"
sudo chmod 777 "/tmp/door"

# Change dir
cd $( dirname "${BASH_SOURCE[0]}" )

# Set GPIOs as output
MY_DOOR_ID=1
while [ $MY_DOOR_ID -le 8 ]
do
    bash door.sh -s "$MY_DOOR_ID"
    sleep 1;
    MY_DOOR_ID=$(( MY_DOOR_ID + 1 ))
done

echo
echo "Exit with [Ctrl] + [C]"
echo
# Endless loop
while true
do
    MY_DATE=$(date)
    MY_TIMESTAMP=$(date +%s)
    echo -n "🤖  $MY_DATE  ⏰  $MY_TIMESTAMP"
    echo
    MY_DOOR_ID=1
    while [ $MY_DOOR_ID -le 8 ]  
    do
        if [ -f "/tmp/door/$MY_DOOR_ID" ]; then
            MY_OPEN_TIMESTAMP=$(cat "/tmp/door/$MY_DOOR_ID")
            MY_LOCK_TIMESTAMP=$(( MY_OPEN_TIMESTAMP + MY_LOCK_SEC ))
            printf "🚪  Door %1s |  🔓  %10s |  🔐  %10s" "$MY_DOOR_ID" "$MY_OPEN_TIMESTAMP" "$MY_LOCK_TIMESTAMP"
            if (( MY_TIMESTAMP > MY_LOCK_TIMESTAMP )); then
                echo "  🔑  is locked"
                bash door.sh -c "$MY_DOOR_ID"
            else
                echo
            fi
            
        fi
        MY_DOOR_ID=$(( MY_DOOR_ID + 1 ))
    done
    # Sleep for N seconds
    sleep 5;
done