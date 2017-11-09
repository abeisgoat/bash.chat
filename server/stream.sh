#!/usr/bin/env bash
stdbuf -oL ./curl.sh | awk -f stream.awk