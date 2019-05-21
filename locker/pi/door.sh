#!/usr/bin/env bash

#
# Bash Script to turn on and off GPIO pins from Raspberry Pi.
# This will open and close the doors of the locker.
#

################################################################################
# Usage
################################################################################

me=$(basename "$0")

function usage {
    returnCode="$1"
    echo "Usage: $me [-s -o -c] <door 1-8>"
    echo -e "\\t -s : Setup door - set GPIO as output"
    echo -e "\\t -o : Open door  - set GPIO to drive to high"
    echo -e "\\t -c : Slose door - set GPIO to drive to drive low"
    exit "$returnCode"
}

################################################################################
# Helper
################################################################################

# command_exists() tells if a given command exists.
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# check_command() check if command exists and exit if not exists
function check_command() {
    if ! command_exists "$1"; then
        exit_with_failure "Command '$1' not found"
    fi
}

# exit_with_failure() outputs a message before exiting the script.
function exit_with_failure() {
    echo
    echo "☠️  FAILURE: $1"
    echo
    exit 9
}

################################################################################
# MAIN
################################################################################

MY_SETUP=0
MY_OPEN_DOOR=0

while getopts "s:o:c:" OPTION
do
   case $OPTION in
       s) MY_SETUP=1; MY_DOOR_ID="$OPTARG" ;;
       o) MY_OPEN_DOOR=1; MY_DOOR_ID="$OPTARG" ;;
       c) MY_DOOR_ID="$OPTARG" ;;
       *) usage 1 ;;
   esac
done

case "$MY_DOOR_ID" in
"")
    # called without arguments
    usage 1
    ;;
"1")
    # Pin 3
    MY_GPIO="2"
    ;;
"2")
    # Pin 5
    MY_GPIO="3"
    ;;
"3")
    # Pin 7
    MY_GPIO="4"
    ;;
"4")
    # Pin 11
    MY_GPIO="17"
    ;;
"5")
    # Pin 13
    MY_GPIO="27"
    ;;
"6")
    # Pin 15
    MY_GPIO="22"
    ;;
"7")
    # Pin 19
    MY_GPIO="10"
    ;;
"8")
    # Pin 21
    MY_GPIO="9"
    ;;
*)
    usage 1
    ;;
esac


check_command "raspi-gpio"

if (( MY_SETUP > 0 )); then
    echo -n "🚪  SETUP DOOR $MY_DOOR_ID"
    # Set GPIO as output and drive to high (1)
    if sudo raspi-gpio set "$MY_GPIO" op dh; then
        echo "  ✅"
    else
        exit_with_failure "Can not set GPIO $MY_GPIO as output"
    fi
    exit 0
fi

if (( MY_OPEN_DOOR > 0 )); then
    mkdir -p "/tmp/door"
    echo -n "🔓 🚪  OPEN DOOR $MY_DOOR_ID"
    # Set GPIO to drive to drive low (0)
    if sudo raspi-gpio set "$MY_GPIO" dl; then
        # Save status file
        date +%s > "/tmp/door/$MY_DOOR_ID"
        echo "  ✅  Door $MY_DOOR_ID open"
    else
        exit_with_failure "Can not set GPIO $MY_GPIO to drive to high (1) level"
    fi
else
    echo -n "🔒 🚪  LOCK DOOR $MY_DOOR_ID"
    # Set GPIO to drive to high (1)
    if sudo raspi-gpio set "$MY_GPIO" dh; then
        echo -n "  ✅  Door $MY_DOOR_ID locked"
        # Remove status file
        if sudo rm "/tmp/door/$MY_DOOR_ID"; then
            echo "  🗑️  Status file removed"
        else
            echo "  ⚠️  Status file not removed"
        fi
    else
        exit_with_failure "Can not set GPIO $MY_GPIO to drive low (0) level"
    fi
fi
