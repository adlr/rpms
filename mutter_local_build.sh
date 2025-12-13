#!/bin/bash

if [ $(whoami) != root ]; then
    echo run me with sudo
    exit 1
fi
set -ex
cd rebuild-work/pkg
sudo -u adlr CC="ccache gcc" CXX="ccache g++" fedpkg --release f42 local
rpm -e --nodeps mutter-debugsource mutter-debuginfo mutter mutter-common || true
dnf install -y \
    */mutter-debugsource-48*.adlr.*.rpm \
    */mutter-debuginfo-48*.adlr.*.rpm \
    */mutter-48*.adlr.*.rpm \
    */mutter-common-48*.adlr.*.rpm
