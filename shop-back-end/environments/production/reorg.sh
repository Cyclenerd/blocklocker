#!/bin/sh

#
# Reorganize all current sales (sale_status = 1)
#

curl -u "USERNAME:PASSWORD" -s "http://127.0.0.1:5000/admin/reorg" -o /dev/null