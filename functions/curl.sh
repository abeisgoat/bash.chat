#!/usr/bin/env bash

while true; do
    curl -s --raw "localhost:5000/listen?skipWelcome=$SKIP_WELCOME" 2> /dev/null
    SKIP_WELCOME=true;
    sleep 1;
done