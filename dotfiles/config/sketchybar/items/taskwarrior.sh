# sketchybar --add item taskwarrior right                                \
#            --set      taskwarrior script="$PLUGIN_DIR/taskwarrior.sh"  \
#                                   update_freq=120                      \
#                                   icon=✓                               \
#                                   label.padding_right=0
           #                                                           \
           # --add item timewarrior left                               \
           # --set      timewarrior script="$PLUGIN_DIR/noti_timew.sh" \
           #                        update_freq=120                    \
           #                        padding_left=2                     \
           #                        padding_right=8                    \
           #                        background.border_width=0          \
           #                        background.height=24               \
           #                        icon=$ICON_CLOCK                   \
           #                        icon.color=$COLOR_YELLOW           \
           #                        label.color=$COLOR_YELLOW

#!/bin/bash

taskwarrior=(
  script="$PLUGIN_DIR/taskwarrior.sh"
  update_freq=120
  icon=󱃔
  icon.color=$ORANGE
  label.color=$ORANGE
  popup.background.border_width=2
  popup.background.corner_radius=3
  popup.background.border_color=0xff9dd274
)
task_template=(
  drawing=off
  background.corner_radius=12
  padding_left=7
  padding_right=7
)
events=(
  mouse.clicked
  mouse.exited
)

sketchybar --add item taskwarrior right \
  --set taskwarrior "${taskwarrior[@]}" \
  --subscribe taskwarrior "${events[@]}" \
  --add item task.template popup.taskwarrior \
  --set task.template "${task_template[@]}"
