#!/bin/bash
# https://github.com/notwithering/auto-music-pauser

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
		echo "usage: $0 <running_process_pid> (omit to auto detect)"
		exit 1
	fi
fi

if [[ -z "$player_pid" ]]; then
	echo "no valid player PID found"
	exit 1
fi

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
	echo "could not find player name for pid $player_pid"
	exit 1
fi
player_name=$(echo "$player_name" | tr '[:upper:]' '[:lower:]' | tr -d ' ')


paused=false

while true; do
	playing=false

	while IFS='|' read -r pid corked; do
		if [[ "$corked" == "no" && "$pid" != "$player_pid" ]]; then
			playing=true
		fi
	done < <(pactl list sink-inputs | awk '
		BEGIN { RS="Sink Input #" }
		NR>1 {
			if (match($0, /Corked: ([^\n]+)/, m1) &&
				match($0, /application.process.id = "([0-9]+)"/, m2)) {
				print m2[1] "|" m1[1]
			}
		}
	')

	if $playing; then
		if playerctl --player="$player_name" status | grep -q Playing; then
			playerctl --player="$player_name" pause
			paused=true
		fi
	elif $paused; then
		if playerctl --player="$player_name" status | grep -q Paused; then
			playerctl --player="$player_name" play
			paused=false
		fi
	fi

	sleep 0.1
done
