#!/bin/bash

# The first time, do 'fedpkg prep' first

. ./debug_flags.sh

  cd mutter-43.5
    /usr/bin/meson setup --buildtype=plain --prefix=/usr --libdir=/usr/lib64 --libexecdir=/usr/libexec --bindir=/usr/bin --sbindir=/usr/sbin --includedir=/usr/include --datadir=/usr/share --mandir=/usr/share/man --infodir=/usr/share/info --localedir=/usr/share/locale --sysconfdir=/etc --localstatedir=/var --sharedstatedir=/var/lib --wrap-mode=nodownload --auto-features=enabled . redhat-linux-build -Degl_device=true -Dwayland_eglstream=true
