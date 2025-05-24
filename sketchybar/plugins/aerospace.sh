#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME label.color=$BOG_GREEN
else
  sketchybar --set $NAME label.color=$DEATHLY_GRAY
fi

sketchybar --set $NAME order=3
