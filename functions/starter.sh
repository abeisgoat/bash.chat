#!/usr/bin/env bash

# We route this to another URL so
# users can load up the base script
# URL and inspect it without any fancy
# redirection logic.

curl "HOST_URL/stream.awk" > /tmp/bc.awk

curl CLIENT_URL > /tmp/bc.client
chmod +x /tmp/bc.client
BC_HOST="HOST_URL" /tmp/bc.client