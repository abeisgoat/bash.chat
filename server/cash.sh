#!/usr/bin/env bash
(./stream.sh) &

SUBSHELL_PID=$!

while true; do
    read -sre INPUT
    curl -sG "localhost:5000/say"  --data-urlencode "name=$1" --data-urlencode "text=$INPUT" --data-urlencode "color=36" > /dev/null
done

kill $SUBSHELL_PID