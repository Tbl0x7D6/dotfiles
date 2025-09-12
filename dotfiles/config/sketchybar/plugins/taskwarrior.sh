#!/bin/sh

# PENDING_TASK=$(task +PENDING count)
# OVERDUE_TASK=$(task +OVERDUE count)

# if [[ $PENDING_TASK == 0 ]]; then
#   sketchybar --set $NAME label.drawing=off    \
#                          icon.padding_left=4  \
#                          icon.padding_right=6
# else
#   if [[ $OVERDUE_TASK == 0 ]]; then
#     LABEL=$PENDING_TASK
#   else
#     LABEL="!$OVERDUE_TASK/$PENDING_TASK"
#   fi

#   sketchybar --set $NAME label="${LABEL}"     \
#                          label.drawing=on     \
#                          icon.padding_left=6  \
#                          icon.padding_right=4
# fi

#!/bin/bash

# Function to list due tasks and update sketchybar
list_tasks() {
	source "$HOME/.config/sketchybar/colors.sh"
	local -a args=()
	local task_count=0
	local current_date=$(date "+%Y%m%dT%H%M%SZ")

	# Remove previous task list
	args+=(--remove '/task.pending.*/')

	# Get pending tasks and sort them by urgency
	local pending_tasks=$(task +PENDING export | jq -c 'sort_by(.urgency) | reverse | .[]')

	# Iterate over each task
	while IFS= read -r task_json; do
		((task_count++))
		local description=$(echo "$task_json" | jq -r '.description')
		local due=$(echo "$task_json" | jq -r '.due // "no_due_date"')
		local due_date=""

		# Format the due date for display as "Day.Month", or leave it empty if not present
		if [[ $due != "no_due_date" ]]; then
			due_date=$(date -jf "%Y%m%dT%H%M%SZ" "$due" "+%d. %b" 2>/dev/null)
		fi
		# Set the color to red if the task is overdue
		if [[ "$due" > "$current_date" ]]; then
			label_color=$YELLOW
		else
			label_color=$RED
		fi

		args+=(
			"--clone" "task.pending.$task_count" "task.template"
			"--set" "task.pending.$task_count"
			"icon=$due_date"
			"label=$description"
			"label.color=$label_color"
			"position=popup.taskwarrior"
			"drawing=on"
		)
	done <<<"$pending_tasks"

	# Update sketchybar with the pending tasks
	sketchybar -m "${args[@]}"
}

# Function to toggle task popup in sketchybar
popup() {
	sketchybar --set "$NAME" popup.drawing="$1"
}

# Function to update sketchybar based on task counts
update() {
	# task sync # Sync your data with your taskserver

	local pending_task_count=$(task +PENDING count)
	local overdue_task_count=$(task +OVERDUE count)

	if [[ $pending_task_count == 0 ]]; then
		sketchybar --set $NAME label.drawing=off
	else
		local label
		if [[ $overdue_task_count == 0 ]]; then
			label="$pending_task_count"
		else
			label="!$overdue_task_count/$pending_task_count"
		fi

		sketchybar --set $NAME label="$label" \
			label.drawing=on
	fi
}

# Main event handler
case "$SENDER" in
"routine" | "forced")
	update
	;;
"mouse.clicked")
	update
	list_tasks
	popup toggle
	;;
# "mouse.exited")
# 	popup off
# 	;;
esac
