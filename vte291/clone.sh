#!/bin/bash

cd "$(dirname "$0")/.."

git clone git@github.com:adlr/vte291-fedora.git
cd vte291-fedora
git remote add upstream https://src.fedoraproject.org/rpms/vte291.git
git fetch upstream
