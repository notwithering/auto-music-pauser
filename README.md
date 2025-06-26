# auto-music-pauser

automatically pauses your music when another application starts playing audio than the given pid

optional first argument specifying the pid of the music player, if omitted, it will try to find the music player automatically

def works with elisa on pipewire havent tried with anything else

## prerequisites

- `bash` - command-line interpreter
- `pactl` - command-line interface for pulseaudio or pipewire with pulse compatibility
- `playerctl` - command-line interface for media players
- media player must support mpris and be controllable by `playerctl`
- if using auto detection:
	- audio system should expose sink inputs with `media.role = "music"` in `pactl list sink-inputs`
	- media player have the same mpris player name as the application name normalized
