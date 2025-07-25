#!/bin/bash

set -x

WEBROOT="$HOME/florian.latzel.io"
BLOCKLIST="$HOME/repos/block_static_paths/blocklist.txt"

while IFS= read -r PATH; do

  PATH="${PATH#"${PATH%%[![:space:]]*}"}"  # trim leading
  PATH="${PATH%"${PATH##*[![:space:]]}"}"  # trim trailing
  
  [[ -z "$PATH" || "$PATH" =~ ^# ]] && continue

  FULL="$WEBROOT/$PATH"
  [ -z "$FULL" ] && continue

  if [[ "$PATH" == */ ]]; then    
    if [ ! -e "$FULL/.blocked" ]; then
      /usr/bin/mkdir -p "$FULL"
      /usr/bin/touch "$FULL/.blocked"
      /usr/bin/chmod 000 "$FULL" "$FULL/.blocked"
      echo "[403] Directory blocked: $PATH"
    fi
  else
    if [ ! -f "$FULL" ]; then
      /usr/bin/mkdir -p "$(/usr/bin/dirname "$FULL")"
      /usr/bin/touch "$FULL"
      /usr/bin/chmod 000 "$FULL"
      echo "[403] File blocked: $PATH"
    fi
  fi
done < "$BLOCKLIST"

