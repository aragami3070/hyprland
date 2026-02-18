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
# NOTE: cli
mkdir -p ~/.projects/rust/cli-s
git clone git@github.com:aragami3070/github-cli.git ~/.projects/rust/cli-s/github-cli
git clone git@github.com:aragami3070/hyprpaper-picker.git ~/.projects/rust/cli-s/hyprpaper-picker
git clone git@github.com:aragami3070/anytype-notify.git ~/.projects/rust/cli-s/anytype-notify

# NOTE: web
mkdir -p ~/.projects/rust/web

# NOTE: leetcode + codeforces
git clone git@github.com:aragami3070/codeforces-solutions.git ~/.projects/rust/codeforces
git clone git@github.com:aragami3070/rust-leetcode.git ~/.projects/rust/leetcode

# NOTE: rust to py projects
mkdir -p ~/.projects/rust/rust-to-py
git clone git@github.com:AXECAC/docs-search.git ~/.projects/rust/rust-to-py/docs-search


# NOTE: templates
mkdir -p ~/.projects/templates
git clone git@github.com:AXECAC/Template-Back-End-C-Sharp.git ~/.projects/templates/template-back-end-c-sharp
git clone git@github.com:aragami3070/start-axum-workspace-template.git ~/.projects/templates/rust-fullstack-template

# NOTE: github my page
git clone git@github.com:aragami3070/aragami3070.git ~/.projects/git-hub-README

# NOTE: course-works
mkdir -p ~/.projects/course-works
git clone git@github.com:aragami3070HWSSU/Course-Work-Voluntary-Working-Back-End.git ~/.projects/course-works/voluntary-working-back-end-tex

mkdir -p ~/.projects/hackatons
git clone git@github.com:AXECAC/do_svyazy.git ~/.projects/hackatons/do_svyazy
mkdir -p ~/.projects/ctf

# NOTE: Setup config repos
git clone git@github.com:aragami3070/nvim.git ~/.config/nvim
git clone git@github.com:aragami3070/one-nvim.git ~/.config/one-nvim
git clone git@github.com:aragami3070/kitty.git ~/.config/kitty
