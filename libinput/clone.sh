#!/bin/bash

cd "$(dirname "$0")/.."

git clone git@github.com:adlr/libinput-fedora.git libinput-rpm
cd libinput-rpm
git remote add upstream https://src.fedoraproject.org/rpms/libinput.git
git fetch upstream
