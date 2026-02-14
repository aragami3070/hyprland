#!/bin/bash

ssh-keygen -t ed25519 -C "smirnov17612@gmail.com"

ssh-add ~/.ssh/id_ed25519

cat ~/.ssh/id_ed25519.pub
