#!/usr/bin/env bash

#
# Monitor SSH tunnel and kill PID with port 8000
#

if ! curl --silent --max-time 5 "http://127.0.0.1:8000/index.sh" -o /dev/null; then
    MY_TUNNEL_SSH_PID=$(lsof -ti tcp:8000 | head -n 1)
    if (( MY_TUNNEL_SSH_PID > 0 )); then
        echo "Kill tunnel. Kill PID: $MY_TUNNEL_SSH_PID"
        kill "$MY_TUNNEL_SSH_PID"
    else
        echo "No SSH tunnel. No PID."
    fi
fi
