#!/bin/bash
date
cat ./server.txt |  while read output
do
    ping -c 3 "$output" > /dev/null
    if [ $? -eq 0 ]; then
    echo "target $output is up" 
    else
    echo "target $output is down"
    fi
done
