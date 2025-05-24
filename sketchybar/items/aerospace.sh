#!/bin/sh

#Define icons for workspaces
SPACE_ICONS=("1 Ghostty" "2 Chrome" "3 Idea" "4 Chrome Canary" "5" "6" "7" "8" "9" "10")
for sid in $(aerospace list-workspaces --all); do
  # Get the icon for the current workspace
  ICON="${SPACE_ICONS[$((sid - 1))]}"

  sketchybar --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.color=$BACKGROUND_1 \
    background.corner_radius=5 \
    background.height=20 \
    background.drawing=off \
    label="$ICON" \
    padding_left=4 \
    padding_right=4 \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done

# Handle workspace changes
sketchybar --add event aerospace_workspace_change \
  --subscribe space.* aerospace_workspace_change
