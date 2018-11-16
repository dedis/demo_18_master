#!/bin/sh
export GODEBUG=gctrace=0
export DEBUG_TIME=true
DBG_LVL=2
NBR_NODES=5

for node in $(seq $NBR_NODES); do
	( while true; do
		echo "Starting admin node at $(date)" >> /conode_data/admin-$node.log
	  ./conode -c co$node/private.toml -debug $DBG_LVL server | tee -a /conode_data/admin-$node.log
	done ) &
done

if [ ! -f /conode_data/bc*.cfg ]; then
	echo "Creating byzcoin"
	sleep 5
	./bcadmin --debug 2 -c /conode_data create public.toml
fi

while sleep 60; do
	date
done
