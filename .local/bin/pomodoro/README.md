# Pomodoro

Timer driven by dmenu, shown in dwmblocks.

## Setup

1. `cd ~/.config/suckless/dwmblocks && sudo make clean install`, restart dwmblocks.
2. Add `~/.local/bin/pomodoro` to `PATH` (done in `~/.env`).

## Commands

| Command | Does |
|---|---|
| `pomodoro-start` | Ask title (dmenu), ask to start music, start work phase |
| `pomodoro-stop` | Stop timer and music, log as aborted |
| `pomodoro-config` | Set work/break minutes, long-break interval, sound, alert URL, music path |
| `pomodoro-stats` | Open HTML report (today, 7 days, per day) |

## Bar (`sb-pomodoro`, signal 28)

`(work) 24:10 title` / `(break) 04:58 short break` / `(pause) ...`

- Left click: pause/resume
- Right click: stop

## Flow

work -> short break -> work → ... -> long break (every `LONG_EVERY`).
Work rolls into its break automatically. After a break the timer stops.

Alerts: notification, sound, optional URL via `xdg-open`.

Music: `MUSIC_PATH` (file, dir or URL) plays via mpd (`mpc`) on repeat during work: a path relative to the mpd music dir, a stream URL, or a playlist name.
Stops when the work phase ends or the timer is stopped.

## Files (`~/.cache/pomodoro/`)

- `state`: running timer
- `session`: log, tab-separated `epoch phase seconds done|aborted title`
- `config`: settings
- `report.html`: generated report
