#!/usr/bin/env bash

#
# CGI wrapper to open door
#

MY_DOOR_ID=$(echo "$QUERY_STRING" | sed -n 's/^.*door=\([^&]*\).*$/\1/p' | sed "s/%20/ /g")

# echo_http() outputs a HTTP/1.0 text/plain message before exiting the script.
function echo_http() {
    echo "HTTP/1.0 $1"
    echo "Content-type: text/plain"
    echo
    echo "$2"
    exit 0
}

if ! sudo raspi-gpio help &> /dev/null ; then
    echo_http "500 Internal Server Error" "Can not execute the 'raspi-gpio' command. Please read pi/README.md and copy the 099_www-data file."
fi

if [[ ! -x /home/pi/blocklocker/pi/door.sh ]]; then
    echo_http "500 Internal Server Error" "Can not execute the 'door.sh' script. Please check authorization."
fi

if (( MY_DOOR_ID > 0 )); then
    if [[ -f "/tmp/door/$MY_DOOR_ID" ]]; then
        echo_http "429 Too Many Requests" "Door already open. Status file exists."
    else
        if bash /home/pi/blocklocker/pi/door.sh -o "$MY_DOOR_ID" &> /dev/null; then
            echo_http "200 OK" "Door $MY_DOOR_ID open"
        else
            echo_http "500 Internal Server Error" "Can not open door $MY_DOOR_ID"
        fi
    fi
else
    echo_http "200 OK" "This is a text from the Raspberry Pi"
fi
