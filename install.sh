#!/usr/bin/env bash

# Source: https://stackoverflow.com/a/246128
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$SCRIPT_DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
#echo "Script dir: $SCRIPT_DIR"
# ==========================================

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
  mkdir -p $DEST_DIR
fi

if [ -d "$DEST_DIR/Vimix-cursors" ]; then
  rm -rf "$DEST_DIR/Vimix-cursors"
fi

if [ -d "$DEST_DIR/Vimix-white-cursors" ]; then
  rm -rf "$DEST_DIR/Vimix-white-cursors"
fi

cp -r $SCRIPT_DIR/dist/ $DEST_DIR/Vimix-cursors
cp -r $SCRIPT_DIR/dist-white/ $DEST_DIR/Vimix-white-cursors

echo "Finished..."
