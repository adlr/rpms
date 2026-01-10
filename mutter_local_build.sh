#!/bin/bash

if [ $(whoami) != root ]; then
    echo run me with sudo
    exit 1
fi
set -ex
cd rebuild-work/pkg
sudo -u adlr CC="ccache gcc" CXX="ccache g++" fedpkg --release f43 local
rpm -e --nodeps mutter-debugsource mutter-debuginfo mutter mutter-common || true
dnf install -y \
    */mutter-debugsource-49*.adlr.*.rpm \
    */mutter-debuginfo-49*.adlr.*.rpm \
    */mutter-49*.adlr.*.rpm \
    */mutter-common-49*.adlr.*.rpm
