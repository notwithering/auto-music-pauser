#!/bin/bash

get_player_pid() {
	player_pid=$1

	if [[ -z "$player_pid" ]]; then
		player_pid=$(pactl list sink-inputs | awk '
			BEGIN { RS="Sink Input #" }
			NR>1 {
				if ($0 ~ /media.role = "music"/ &&
					match($0, /application.process.id = "([0-9]+)"/, m)) {
					print m[1]
					exit
				}
			}
		')
	else
		if [[ ! "$player_pid" =~ ^[0-9]+$ || ! -e /proc/$player_pid ]]; then
			echo "usage: $0 <running_process_pid> (omit to auto detect)" >&2
			exit 1
		fi
	fi

	if [[ -z "$player_pid" ]]; then
		echo "no valid player PID found" >&2
		exit 1
	fi

	echo "$player_pid"
}

get_player_name() {
	player_pid=$1

	player_name=$(pactl list sink-inputs | awk -v pid="$player_pid" '
		BEGIN { RS="Sink Input #" }
		NR>1 {
			if (match($0, "application.process.id = \"" pid "\"")) {
				if (match($0, /application.name = "([^"]+)"/, m)) {
					print m[1]
					exit
				}
			}
		}
	')

	if [[ -z "$player_name" ]]; then
			echo "could not find player name for pid $player_pid" >&2
			exit 1
	fi
	player_name=$(echo "$player_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

	echo "$player_name"
}

player_playing() {
	player_name=$1
	playerctl --player="$player_name" status | grep -q Playing
}

player_paused() {
	player_name=$1
	playerctl --player="$player_name" status | grep -q Paused
}

pause_player() {
	player_name=$1
	playerctl --player="$player_name" pause
}

play_player() {
	player_name=$1
	playerctl --player="$player_name" play
}
