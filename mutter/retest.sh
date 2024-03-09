#!/bin/bash

. ./debug_flags.sh

VERSION=$(echo '%version' | rpmspec -P mutter.spec --shell | grep -A 1 '^> %version$' | tail -n 1)

fedpkg compile
#(cd mutter-$VERSION && /usr/bin/meson compile -C redhat-linux-build -j 8 --verbose)

export GTK_A11Y=none

(cd mutter-$VERSION/redhat-linux-build &&
     meson test hide-pointer-when-typing) #client-resize-respect-constraints #monitor-unit x11
