#!/usr/bin/env bash
clear

TPUT_COLS=$(tput cols)
TPUT_LINES=$(tput lines)

BC_ID=$RANDOM
BC_INPUT_FILE="/tmp/bc.inputfile.$BC_ID"
BC_MESSAGES_FILE="/tmp/bc.messagesfile.$BC_ID"
BC_LOCK_RENDER_FILE="/tmp/bc.lock.render.$BC_ID"
BC_TERMINAL_FILE="/tmp/bc.terminalfile.$BC_ID"

NAME="User "$BC_ID
COLOR=$(echo "30+($BC_ID%7)" | bc)

echo $TPUT_COLS > $BC_TERMINAL_FILE

# Data loop

function bc_curl {
    while true; do
        curl -s --raw "$BC_HOST/listen?skipWelcome=$SKIP_WELCOME" 2> /dev/null
        SKIP_WELCOME=true;
        sleep 1;
    done
}

function bc_stream {
    stdbuf -o 0 bash -c 'bc_curl' | awk -v TPUT_COLS=$(cat $BC_TERMINAL_FILE) -f /tmp/bc.awk
}
export -f bc_stream
export -f bc_curl
export BC_TERMINAL_FILE

( while true; do
    stdbuf -o 0 bash -c 'bc_stream' > $BC_MESSAGES_FILE
done ) 2> /tmp/bc.log.data &

DATAPID=$!

function line {
    printf "%"$TPUT_COLS"s\n" |tr " " "="
}

# Render loop
( while true; do
    echo "locked" > $BC_LOCK_RENDER_FILE
    #clear
    tput cup 0 0
    line
    printf "%s\n" "$(tail -n 10 $BC_MESSAGES_FILE)"
    line
    printf "%s" "$(cat $BC_INPUT_FILE)"
    sleep 0.1
    echo "unlocked" > $BC_LOCK_RENDER_FILE
done ) 2> /tmp/bc.log.render &

RENDERPID=$!

# Message send loop
while true; do
    unset message
    echo "" > $BC_INPUT_FILE

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


        echo "$message" > $BC_INPUT_FILE
        RENDER_LOCK=$(cat $BC_LOCK_RENDER_FILE)
        if [ "$RENDER_LOCK" != "locked" ]
        then
            printf "\r%s" "$message"
        fi
    done

    curl -sG "$BC_HOST/say" \
        --data-urlencode "name=$NAME" \
        --data-urlencode "text=$message" \
        --data-urlencode "color=$COLOR" > /tmp/bc.log.send
done

kill $RENDERPID $DATAPID
rm $BC_INPUT_FILE $BC_MESSAGES_FILE