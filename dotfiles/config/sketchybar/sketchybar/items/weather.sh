#!/bin/bash

weather=(
  script="$PLUGIN_DIR/weather.sh"
  icon.font="FiraCode Nerd Font:Regular:18.0"
  icon=
  label.drawing=on
  label.font="FiraCode Nerd Font:Bold:14.0"
  label.padding_right=0
  update_freq=900
)

weather_moon=(
  icon.padding_left=0
  icon.font="FiraCode Nerd Font:Regular:18.0"
  label.drawing=off
)

sketchybar --add item weather.moon right \
  --set weather.moon "${weather_moon[@]}" \
  --subscribe weather.moon mouse.clicked

sketchybar --add item weather right \
  --set weather "${weather[@]}" \
  --subscribe weather system_woke mouse.clicked
