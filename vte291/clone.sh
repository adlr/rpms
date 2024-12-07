#!/bin/bash

cd "$(dirname "$0")/.."

git clone git@github.com:adlr/vte.git vte291-src
cd vte291-src
git remote add upstream https://gitlab.gnome.org/GNOME/vte.git
git fetch upstream
cd ..

git clone git@github.com:adlr/vte291-fedora.git vte291-rpm
cd vte291-rpm
git remote add upstream https://src.fedoraproject.org/rpms/vte291.git
git fetch upstream

