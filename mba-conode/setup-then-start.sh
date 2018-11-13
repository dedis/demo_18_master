#!/bin/sh

if [ ! -f /conode_data/private.toml ]; then
    ./conode setup --non-interactive
fi

echo "Starting conode"
cat /conode_data/private.toml

DEBUG_TIME=true ./conode -debug 2 server
