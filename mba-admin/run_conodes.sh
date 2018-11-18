#!/bin/sh
export GODEBUG=gctrace=0
export DEBUG_TIME=true
DBG_LVL=2
NBR_NODES=5

mkdir -p log

for node in $(seq $NBR_NODES); do
	( while true; do
		log=log/admin-$node.log
		echo "Starting admin node at $(date)" >> $log
	  ./conode -c co$node/private.toml -debug $DBG_LVL server 2>&1 | tee -a $log
		sleep 1
	done ) &
done

if [ ! -f bc*.cfg ]; then
	echo "Creating byzcoin"
	sleep 2
	./bcadmin --debug 2 -c . create group.toml
fi

while sleep 60; do
	date
done
