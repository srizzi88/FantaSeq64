#!/bin/bash

# Adjust these two paths according
# to your system
export ACME_PATH="/Users/srizzi/Documents/Box Sync/myRetroComputing/C64/ACME/acme/bin/acme"
export HATOUCAN_PATH="/Users/srizzi/Documents/Box Sync/myRetroComputing/C64/hatoucan/hatoucan/script/hatoucan"


cmake \
  -B ./build \
  -DACME_EXECUTABLE="$ACME_PATH" \
  -DHATOUCAN_SCRIPT="$HATOUCAN_PATH" \
  .

