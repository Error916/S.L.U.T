#!/usr/bin/env bash

# Modify the parameters below.
interval=300
# Action to take when we finish waiting
action="$2"


help() {
    echo "Syntax: waitfor [pid]"
}

if [ $# == 0 ]; then help; exit; fi
s=$(ps --pid $1 | grep $1)
if [ "$s" == "" ]; then echo "pid $1 currently not running!"; exit; fi

echo "Action: '$action'"
echo "Waiting for..."
ps --pid $1
while true; do
    sleep $interval
    s=$(ps --pid $1 | grep $1)
    if [ "$s" == "" ]; then break; fi
done
echo "Taking action..."
$action
