#!/bin/bash
#

NOTE_DIR=$HOME/.local/share/note

if [ ! -d $NOTE_DIR  ]; then
    mkdir $NOTE_DIR
fi

NOTE_DATE=$(date +'%m_%d_%Y')
NOTE_FILE="$NOTE_DIR/note_$NOTE_DATE.md"

if [ ! -f $NOTE_FILE ]; then
   touch $NOTE_FILE 
fi

NOTE_TIME=$(date +'%T')
echo '' >> $NOTE_FILE
echo "=== $NOTE_TIME === " >> $NOTE_FILE


kitty nvim $NOTE_FILE
