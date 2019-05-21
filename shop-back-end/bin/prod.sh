#!/usr/bin/env bash

#
# Start BlockShop
#

# Perlbrew
source ~/perl5/perlbrew/etc/bashrc

# Change dir
cd $( dirname "${BASH_SOURCE[0]}" )
cd ..

cat << EOF

  ██████╗ ██╗      ██████╗  ██████╗██╗  ██╗███████╗██╗  ██╗ ██████╗ ██████╗ 
  ██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██║  ██║██╔═══██╗██╔══██╗
  ██████╔╝██║     ██║   ██║██║     █████╔╝ ███████╗███████║██║   ██║██████╔╝
  ██╔══██╗██║     ██║   ██║██║     ██╔═██╗ ╚════██║██╔══██║██║   ██║██╔═══╝ 
  ██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗███████║██║  ██║╚██████╔╝██║     
  ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     

                                                      Blocklocker Back End

EOF

# Endless loop
while true
do
    echo
    echo "Restart with [Ctrl] + [C] // Exit with [Ctrl] + [C] and then immediately again [Ctrl] + [C]"
    echo
    plackup -E production -s Starman --workers=2 -l 127.0.0.1:5000 -a bin/app.psgi
done