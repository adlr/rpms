#!/bin/bash

cd "$(dirname "$0")/.."

git clone git@github.com:adlr/libinput.git libinput-src
cd libinput-src
git remote add upstream https://gitlab.freedesktop.org/libinput/libinput.git
git fetch upstream
cd ..

git clone git@github.com:adlr/libinput-fedora.git libinput-rpm
cd libinput-rpm
git remote add upstream https://src.fedoraproject.org/rpms/libinput.git
git fetch upstream
