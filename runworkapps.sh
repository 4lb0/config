#!/bin/bash

cd $HOME

/snap/bin/firefox&
gnome-terminal --full-screen -- tmux attach&
slack&
thunderbird&
/snap/bin/standard-notes&
