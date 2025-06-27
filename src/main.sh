#!/bin/bash
# https://github.com/notwithering/auto-music-pauser
set -e

source ./player.sh
source ./audio.sh

player_pid=$(get_player_pid $1)
player_name=$(get_player_name $player_pid)

paused=false

while true; do
	if other_audio_playing $player_pid; then
		if player_playing $player_name; then
			pause_player $player_name
			paused=true
		fi
	elif $paused; then
		if player_paused $player_name; then
			play_player $player_name
			paused=false
		fi
	fi

	sleep 0.1
done
