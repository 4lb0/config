# sessions-ls

List every terminal coding agent (opencode, claude) running in a tmux pane,
with its session name and status, and jump straight to the pane.

Installed from this repo by `install.sh` as `~/bin/sessions-ls`, plus the short
alias `~/bin/sl`.

## Usage

```
sessions-ls              # interactive picker, refreshes itself every second
sessions-ls | less       # pipeline: plain listing, newest activity first
sessions-ls --plain      # same as above, explicitly
sessions-ls --header     # plain listing with a header row
sessions-ls --json       # machine readable
sl                       # short alias for sessions-ls
```

Interactive keys:

| key            | action                          |
| -------------- | ------------------------------- |
| `↑` `↓` / `j` `k` | move selection               |
| `Enter`        | jump to that pane in tmux       |
| `g` / `G`      | first / last                    |
| `r`            | re-sort by activity             |
| `q` / `Esc`    | quit                            |

Plain output is shaped like `ls -lht`: long-ish, human ages (`now`, `13m`,
`3h`, `2d`), sorted by most recent activity.

```
STATUS    AGENT     TMUX        ACTIVE  NAME
working  opencode albo:7.0   now     sessions-ls tmux session picker  ~/self/sessions-ls
awaiting claude   pausa:4.1  6h      Sincronización de datos del tablero  ~/work/pausa/all
```

## Statuses

| status     | meaning                                                  |
| ---------- | -------------------------------------------------------- |
| `working`  | the agent is busy (tool running / generating)             |
| `awaiting` | last turn finished, it is waiting for your next message   |
| `approval` | a permission prompt is on screen, the agent is blocked    |
| `unknown`  | process found but its session could not be read           |

## How it works

* **Panes**: `tmux list-panes -a` gives pane id, pid, title and cwd.
* **Processes**: `ps` finds interactive `opencode` / `claude` processes and
  maps them to a pane through their parent chain (`TMUX_PANE` as a fallback).
* **opencode sessions**: read-only SQLite on
  `~/.local/share/opencode/opencode.db` (`session_v2`). The pane title is
  `OC | <session title>`, so the title (plus the pane cwd) identifies the
  session; `time_busy` / `time_idle` give its status.
* **claude sessions**: transcripts in `~/.claude/projects/<munged-cwd>/*.jsonl`.
  The last `ai-title` entry matches the pane title; the last real transcript
  entry tells whether the turn ended.
* **approvals**: the bottom lines of the pane are checked for permission
  prompts.

No dependencies beyond the Python 3 standard library.

## tmux binding

Run it as a popup on a key of your choice:

```tmux
bind-key a display-popup -E -w 110 -h 40 -T " sessions-ls " ~/bin/sessions-ls
```

`Enter` switches the client to the selected pane, whether it lives in the
current session or another one.

## Options

```
--plain, -l        print and exit
--json             JSON output
--header           header row in plain mode
--watch SECONDS    plain mode, reprint every N seconds
--interval SECONDS interactive refresh interval (default 1)
```

Environment overrides: `SESSION_LS_OPENCODE_DB`, `SESSION_LS_CLAUDE_DIR`.
