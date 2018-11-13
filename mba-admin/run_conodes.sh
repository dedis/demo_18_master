#!/bin/sh
export GODEBUG=gctrace=0
export DEBUG_TIME=true
DBG_LVL=2
NBR_NODES=5

for node in $(seq $NBR_NODES); do
	./conode -c co$node/private.toml -debug $DBG_LVL server &
done

while sleep 60; do
	date
done
