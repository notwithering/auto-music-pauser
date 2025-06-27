#!/bin/bash

other_audio_playing() {
	player_pid=$1

	while IFS='|' read -r pid corked; do
		if [[ "$corked" == "no" && "$pid" != "$player_pid" ]]; then
			return 0
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

	return 1
}
