#!/bin/bash

# If get error then exit
set -euo pipefail

# Add Obsidian repos
mkdir ~/ObsidianWorkSpace/Obsidian -p
cd ~/ObsidianWorkSpace/Obsidian
rm -rf ./*
git clone git@github.com:aragami3070/MyObsidianWorks.git ./
cd

# Setup project repos
mkdir -p ~/.projects/rust/cli-s
git clone git@github.com:aragami3070/github-cli.git ~/.projects/rust/cli-s/github-cli
git clone git@github.com:aragami3070/hyprpaper-picker.git ~/.projects/rust/cli-s/hyprpaper-picker
git clone git@github.com:aragami3070/anytype-notify.git ~/.projects/rust/cli-s/anytype-notify

mkdir -p ~/.projects/rust/web

mkdir -p ~/.projects/rust/codeforces
git clone git@github.com:aragami3070/codeforces-solutions.git ~/.projects/rust/codeforces

mkdir -p ~/.projects/templates
git clone git@github.com:AXECAC/Template-Back-End-C-Sharp.git ~/.projects/templates/template-back-end-c-sharp

mkdir -p ~/.projects/git-hub-README
git clone git@github.com:aragami3070/aragami3070.git ~/.projects/git-hub-README

mkdir -p ~/.projects/course-works
git clone git@github.com:aragami3070HWSSU/Course-Work-Voluntary-Working-Back-End.git ~/.projects/course-works/voluntary-working-back-end-tex
git clone git@github.com:aragami3070HWSSU/Course-Work-Voluntary-Working-Back-End-Presentation.git ~/.projects/course-works/voluntary-working-back-end-presentation

mkdir -p ~/.projects/hackatons
mkdir -p ~/.projects/ctf

# Setup config repos
mkdir -p ~/.config/nvim
git clone git@github.com:aragami3070/nvim.git ~/.config/nvim
mkdir -p ~/.config/one-nvim
git clone git@github.com:aragami3070/one-nvim.git ~/.config/one-nvim
mkdir -p ~/.config/kitty
git clone git@github.com:aragami3070/kitty.git ~/.config/kitty
mkdir -p ~/zsh
git clone git@github.com:aragami3070/zsh.git ~/zsh
