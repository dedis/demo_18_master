#!/bin/sh

if [ ! -f private.toml ]; then
    ./conode -c . setup
fi

echo "Starting conode"
IP=$( grep Address public.toml | sed -e "s/.*\/\/\(.*\):.*/\1/" )

while true; do
  echo "Starting conode at $(date)" >> $IP.log
  DEBUG_TIME=true ./conode -c . -debug 2 server 2>&1 | tee -a $IP.log
done
