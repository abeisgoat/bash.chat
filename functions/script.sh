#!/usr/bin/env bash
clear

# Render loop
( while true; do
    clear
    tput cup 0 0
    printf "%s\n" "$(tail -n 10 /tmp/bc.messagesfile)"
    echo "--------"
    printf "%s" "$(cat /tmp/bc.inputfile)"
    sleep 0.1
    #echo $! > /tmp/sleepfile
done ) 2> /tmp/bc.log.render &

RENDERPID=$!

# Data loop

( while true; do
    echo -ne "$RANDOM\n" >> /tmp/bc.messagesfile
    sleep 1
done ) 2> /tmp/bc.log.data &

DATAPID=$!

# Keyboard input loop
while true; do
    unset message
    echo "" > /tmp/bc.inputfile

    while IFS= read -rs -n 1 char 
    do
        if [[ $char == $'\0' ]]; then
            break
        fi
        if [[ $char == $'\177' ]]; then
            message="${message%?}"
        else
            message+="$char"
        fi
        echo "$message" > /tmp/bc.inputfile
        killall sleep 2> /dev/null
    done
    echo "$message" >> /tmp/bc.messagesfile
done

kill $RENDERPID
kill $DATAPID