#!/usr/bin/env bash

#
# SSH tunnel to the shop back end
#

cat << EOF

███████╗███████╗██╗  ██╗    ████████╗██╗   ██╗███╗   ██╗███╗   ██╗███████╗██╗
██╔════╝██╔════╝██║  ██║    ╚══██╔══╝██║   ██║████╗  ██║████╗  ██║██╔════╝██║
███████╗███████╗███████║       ██║   ██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██║
╚════██║╚════██║██╔══██║       ██║   ██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██║
███████║███████║██║  ██║       ██║   ╚██████╔╝██║ ╚████║██║ ╚████║███████╗███████╗
╚══════╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚══════╝

                                                  TO THE SHOP BACK END

                       Local port 80 to remote port 8000

EOF

# Endless loop
while true
do
    echo
    echo "Restart with [Ctrl] + [C] // Exit with [Ctrl] + [C] and then immediately again [Ctrl] + [C]"
    sleep 1
    echo
    echo "New connection"
    date
    autossh -M 2000 -o "ServerAliveInterval 5" -o "ServerAliveCountMax 3" -N -R 8000:127.0.0.1:80 shop-back-end
    echo "Connection lost"
done