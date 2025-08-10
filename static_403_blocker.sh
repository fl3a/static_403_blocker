#!/bin/bash

#set -x

PATH=/usr/bin:$PATH
WEBROOT="$HOME/florian.latzel.io"
BLOCKLIST="$HOME/repos/static_403_blocker/blocklist.txt"

[ -f "$BLOCKLIST" ] || { echo "Missing blocklist: $BLOCKLIST" >&2; exit 1; }

while IFS= read -r LINE; do

  # Trim leading/trailing whitespace
  LINE="${LINE#"${LINE%%[![:space:]]*}"}"  # trim leading
  LINE="${LINE%"${LINE##*[![:space:]]}"}"  # trim trailing
 
  # Skip comments and empty lines 
  [[ -z "$LINE" || "$LINE" =~ ^# ]] && continue
  
  # Skip if empty file or empty directory already exists
  CLEAN_LINE="${LINE#/}"
  FULL="$WEBROOT/$CLEAN_LINE"
  type=$(LC_ALL=C stat -c "%F" "$FULL" 2>/dev/null)
  [[ "$type" == "directory" || "$type" == "regular empty file" ]] && continue;

  case "$LINE" in 
    */)    
      mkdir -p "$FULL" || { echo "Failed to create directory: $FULL" >&2; continue; }
      chmod 000 "$FULL"
      echo "[403] Directory blocked: $LINE"
      ;;
    *)
      DIR=$(dirname "$FULL")
      [ "$DIR" != "." ] && [ ! -d "$DIR" ] && mkdir -p "$DIR"
      touch "$FULL" || { echo "Failed to create file: $FULL" >&2; continue; }
      chmod 000 "$FULL"
      echo "[403] File blocked: $LINE"
      ;;
  esac
done < "$BLOCKLIST"

