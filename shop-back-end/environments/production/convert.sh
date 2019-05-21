#!/bin/sh

#
# Update BTC, ETH and ZEC product prices
#

curl -u "USERNAME:PASSWORD" -s "http://127.0.0.1:5000/admin/reorg" -o /dev/null