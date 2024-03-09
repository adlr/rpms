#!/bin/bash

cd "$(dirname "$0")/../libinput-fedora"
CC="ccache gcc" CXX="ccache g++" fedpkg local
