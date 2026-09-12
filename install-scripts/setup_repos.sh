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
mkdir -p ~/projects/rust/cli-s
git clone git@github.com:aragami3070/github-cli.git ~/projects/rust/cli-s/github-cli

hyprpaper_picker_dir="$HOME/projects/rust/cli-s/hyprpaper-picker"
git clone git@github.com:aragami3070/hyprpaper-picker.git "$hyprpaper_picker_dir"

# Build hyprpaper-picker and expose it at the path used by Hyprland.
echo "Building hyprpaper-picker..."
cargo build --release --locked --manifest-path "$hyprpaper_picker_dir/Cargo.toml"

hyprpaper_picker_bin="$hyprpaper_picker_dir/target/release/hyprpaper-picker"
if [[ ! -x "$hyprpaper_picker_bin" ]]; then
	echo "hyprpaper-picker binary was not created" >&2
	exit 1
fi

# Keep only the release binary instead of retaining Cargo build artifacts.
hyprpaper_picker_target_dir="$hyprpaper_picker_dir/target"
find "$hyprpaper_picker_target_dir" -depth -mindepth 1 \
	! -path "$hyprpaper_picker_target_dir/release" \
	! -path "$hyprpaper_picker_bin" \
	-delete

mkdir -p "$HOME/.bin"
ln -sfn "$hyprpaper_picker_bin" "$HOME/.bin/hyprpaper-picker"

git clone git@github.com:aragami3070/anytype-notify.git ~/projects/rust/cli-s/anytype-notify

# NOTE: web
mkdir -p ~/projects/rust/web

# NOTE: leetcode + codeforces
git clone git@github.com:aragami3070/codeforces-solutions.git ~/projects/rust/codeforces
git clone git@github.com:aragami3070/rust-leetcode.git ~/projects/rust/leetcode

# NOTE: rust to py projects
mkdir -p ~/projects/rust/rust-to-py
git clone git@github.com:AXECAC/docs-search.git ~/projects/rust/rust-to-py/docs-search


# NOTE: templates
mkdir -p ~/projects/templates
git clone git@github.com:AXECAC/Template-Back-End-C-Sharp.git ~/projects/templates/template-back-end-c-sharp
git clone git@github.com:aragami3070/start-axum-workspace-template.git ~/projects/templates/rust-fullstack-template

# NOTE: github my page
git clone git@github.com:aragami3070/aragami3070.git ~/projects/git-hub-README

# NOTE: course-works
mkdir -p ~/projects/course-works
git clone git@github.com:aragami3070HWSSU/Course-Work-Voluntary-Working-Back-End.git ~/projects/course-works/voluntary-working-back-end-tex

# NOTE: hackatons
mkdir -p ~/projects/hackatons
git clone git@github.com:AXECAC/do_svyazy.git ~/projects/hackatons/do_svyazy

# NOTE: Setup config repos
git clone git@github.com:aragami3070/nvim.git ~/.config/nvim
git clone git@github.com:aragami3070/one-nvim.git ~/.config/one-nvim
git clone git@github.com:aragami3070/kitty.git ~/.config/kitty
