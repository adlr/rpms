#!/bin/bash

cd "$(dirname "$0")/../vte291-fedora"
CC="ccache gcc" CXX="ccache g++" fedpkg local
