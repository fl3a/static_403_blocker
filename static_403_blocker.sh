#!/bin/bash

# https://github.com/fl3a/static_403_blocker

# Block unwanted scanner and crawler traffic on static websites 
# by pre-creating forbidden files and directories with restrictive permissions.

set -x

PATH=/usr/bin:$PATH
BLOCKLIST="$HOME/repos/static_403_blocker/blocklist.txt"

[ -f "$BLOCKLIST" ] || { echo "Missing blocklist: $BLOCKLIST" >&2; exit 1; }
[ -n "$1" ] && WEBROOT="$1" || { echo "Missing Argument WEBROOT" >&2; exit 1; }
[ -d "$WEBROOT" ] || { echo "WEBROOT is not a directory" >&2; exit 1; }

while IFS= read -r LINE; do

  # Trim leading and trailing whitespace
  LINE="${LINE#"${LINE%%[![:space:]]*}"}" # leading
  LINE="${LINE%"${LINE##*[![:space:]]}"}" # trailing

  # Skip comments and empty lines 
  [[ -z "$LINE" || "$LINE" =~ ^# ]] && continue

  # Trim trailing and leading slash 
  CLEAN_LINE="${LINE#/}"                  # leading  		
  FULL="${WEBROOT}/${CLEAN_LINE%/}"       # trailing 

  # Skip if file or directory already exists
  [ -e "$FULL" ] && continue;

  case "$LINE" in 
    */)    
      mkdir -p "$FULL" || continue
      chmod 000 "$FULL"
      echo "[403] Directory blocked: $LINE"
      ;;
    *)
      DIR=$(dirname "$FULL")
      [ "$DIR" != "." ] && [ ! -d "$DIR" ] && { mkdir -p "$DIR" || continue; }
      touch "$FULL" || continue
      chmod 000 "$FULL"
      echo "[403] File blocked: $LINE"
      ;;
  esac
done < "$BLOCKLIST"

