# wifiawake

Keep the Mac awake only while it makes sense: **Wi-Fi connected + battery above
the floor**, and it keeps working with the **lid closed** (`pmset disablesleep`).

Rule, evaluated every `POLL` seconds:

| Wi-Fi with IP | Battery             | Result                          |
| ------------- | ------------------- | ------------------------------- |
| yes           | > 15% (or on AC)    | hold sleep prevention           |
| no            | any                 | wait `GRACE`s, then allow sleep |
| yes           | <= 15% (on battery) | wait `GRACE`s, then allow sleep |

The `GRACE` wait (90s by default) is what makes "se desconecta y no se
autoconecta a ninguna otra red" work: switching networks or replugging the
charger does not drop the hold.

## Install

```sh
ln -sf "$PWD/macos/wifiawake" ~/.local/bin/wifiawake
wifiawake install     # LaunchAgent + watchdog, starts at login (asks for the sudo rule once)
wifiawake status
```

`install.sh` already links the script into `~/.local/bin`; the agents are only
installed when you ask for them.

**Run it as your user, never with `sudo`.** The agents are per-user LaunchAgents;
only the `pmset` call needs root, and `allow-pmset` (called by `install` when it
has a terminal) asks for the password itself.

## Why `pmset` and not `caffeinate`

`caffeinate` releases the hold when the lid closes, so it does not fit this use
case. The default mode is the literal `sudo pmset -a disablesleep 1`, which
overrides lid-close sleep. Because that is a system setting that would persist
(and drain the battery) if the watcher died, it ships with:

- **restore on stop**: `wifiawake stop`, logout and `SIGTERM` put the previous
  value back (0 unless you had it enabled yourself);
- **stale-lock cleanup**: every poll, if it should not be holding, it clears a
  leftover `disablesleep 1`;
- **watchdog**: a second agent runs every 2 min and drops the lock if the
  daemon is gone or its heartbeat is stale (killed, crashed, hung).

`MODE="caffeinate"` is still available as a root-free fallback (no lid support).

## Commands

```sh
wifiawake status      # network, battery, decision, hold, sudo readiness, agent
wifiawake log 80      # tail the log
wifiawake stop        # stop watching and release the hold
wifiawake start       # resume
wifiawake restart
wifiawake config      # create/print ~/.config/wifiawake/config
wifiawake uninstall
```

## Config

`~/.config/wifiawake/config` is a plain shell source:

```sh
WIFI_IFACE="en0"     # Wi-Fi interface
BATTERY_MIN=15       # floor, on battery only
GRACE=90             # seconds before releasing
POLL=20              # seconds between checks
MODE="pmset"         # or "caffeinate"
```

Log: `~/Library/Logs/wifiawake.log`. `allow-pmset` writes
`/etc/sudoers.d/wifiawake` with only the two `pmset -a disablesleep` commands;
remove it with `sudo rm /etc/sudoers.d/wifiawake`.

## Notes

- "Connected" means the Wi-Fi interface is `active` and has an IPv4 address.
  macOS 15 hides the SSID from scripts without Location permission, so the
  network name is not shown.
- With the lid closed the display stays off but the system keeps running; that
  is the point of `disablesleep`.
- Undo everything by hand if the script is gone:
  `sudo pmset -a disablesleep 0` and `launchctl bootout gui/$UID/com.albo.wifiawake`.

## Troubleshooting

| Symptom | Cause / fix |
| --- | --- |
| `Bootstrap failed: 125 ... Domain does not support specified action` | you ran it with `sudo`; run it as your user |
| `pmset : NOT ready` in `status` | run `wifiawake allow-pmset` (one password) |
| `status` shows `hold: none` while the rule says HOLD | the sudo rule is missing; the log has `needs passwordless sudo` |
| lock stays on after a crash | the watchdog clears it within 2 min; `wifiawake stop` clears it now |
