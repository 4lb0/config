Config
======

This repository contains my set up. I use Ubuntu on a daily basis
but this setup used to work on iOS.

![Neovim in GNOME Terminal screenshot](https://github.com/4lb0/config/assets/142173/ea2def51-309c-4258-8d28-6a6b2d6f3e62)

Apps
----

* **Terminal:** [GNOME Terminal](https://help.gnome.org/users/gnome-terminal/stable/)
  or [iTerm2](https://iterm2.com/) with [tmux](https://github.com/tmux/tmux/wiki)
* **Shell:** [zsh](https://www.zsh.org/), with [Oh My Zsh](https://ohmyz.sh/)
  and [fzf](https://github.com/junegunn/fzf)
* **Editor:** [Neovim](https://neovim.io/)
* **Version control:** [git](https://git-scm.com/)

The rest of the apps I used but the configuration is not saved in this repository.

* **Browser:** [Firefox](https://firefox.com/)
* **Email client:** [Thunderbird](https://www.thunderbird.net/)
* **Note-taking:** [Standard Notes](https://standardnotes.com/)
* **Spell checker:** [LanguageTool](https://languagetool.org/)
* **Time tracking:** [Toggl](https://toggl.com/)
* **Calendar:** [Reclaim](https://reclaim.ai)

Theme
-----

The color palette is provided by [Dracula PRO](https://draculatheme.com).

My prefered monospaced font is [Cascadia Code PL Regular](https://github.com/microsoft/cascadia-code).

Install
-------

First install the used apps follow the set up provided in their links, then run

```bash
git clone git@github.com:4lb0/config.git ~/.config/profile
cd ~/.config/profile
./install.sh
```
