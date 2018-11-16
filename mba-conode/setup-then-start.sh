#!/bin/sh

if [ ! -f /conode_data/private.toml ]; then
    ./conode setup
fi

echo "Starting conode"
IP=$( grep Address /conode_data/public.toml | sed -e "s/.*\/\/\(.*\):.*/\1/" )

while true; do
  echo "Starting conode at $(date)" >> /conode_data/$IP.log
  DEBUG_TIME=true ./conode -debug 2 server | tee -a /conode_data/$IP.log
done
