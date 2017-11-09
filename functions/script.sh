#!/usr/bin/env bash
clear

NAME="Abe"
COLOR=32

BC_INPUTFILE="/tmp/bc.inputfile.$RANDOM"

# Render loop
( while true; do
    clear
    tput cup 0 0
    printf "%s\n" "$(tail -n 10 /tmp/bc.messagesfile)"
    echo "--------"
    printf "%s" "$(cat $BC_INPUTFILE)"
    sleep 0.1
    #echo $! > /tmp/sleepfile
done ) 2> /tmp/bc.log.render &

RENDERPID=$!

# Data loop

( while true; do
    stdbuf -oL ./stream.sh >  /tmp/bc.messagesfile
done ) 2> /tmp/bc.log.data &

# DATAPID=$!

# Message send loop
while true; do
    unset message
    echo "" > $BC_INPUTFILE

    # Keyboard input loop
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
        echo "$message" > $BC_INPUTFILE

        killall sleep 2> /dev/null
    done

    curl -sG "localhost:5000/say" \
        --data-urlencode "name=$NAME" \
        --data-urlencode "text=$message" \
        --data-urlencode "color=$COLOR" > /tmp/bc.log.send
done

kill $RENDERPID
# kill $DATAPID

rm $BC_INPUTFILE