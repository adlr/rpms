#!/bin/bash

git clone git@github.com:adlr/mutter.git mutter-src
cd mutter-src
git remote add upstream git@ssh.gitlab.gnome.org:GNOME/mutter.git
git fetch upstream
cd ..

git clone https://src.fedoraproject.org/rpms/mutter.git mutter-rpm
cd mutter-rpm
git remote add adlr git@github.com:adlr/mutter-rpm.git
git fetch adlr
cd ..
