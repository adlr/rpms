#!/bin/bash

set -ex

if [ "$(whoami)" != "root" ] ; then
   echo usage: sudo ./rebuild.sh
   exit 1
fi

sudo -u adlr CC="ccache gcc" CXX="ccache g++" fedpkg local | tee build.log

if grep warning: build.log | grep -qv whitespace | grep -vE 'clutter-stage.c:3879:24: warning: unused variable ‘priv’'; then
   echo "Bad warnings in log. exiting"
   exit 1
fi

if grep -q error: build.log ; then
   echo "Error in log. exiting"
   exit 1
fi

set +x

RELEASE=$(echo '%version-%release' | rpmspec -P mutter.spec --shell 2>/dev/null | grep -v '^>')
#RELEASE=$(rpm -qa mutter | sed 's/mutter-\(.*\)\.x86_64$/\1/')
PREFIX="*/"
SUFFIX="-${RELEASE}.*.rpm"
PKGS="mutter-debugsource mutter-debuginfo mutter mutter-common"
FULLPKGS="$PREFIX${PKGS// /$SUFFIX $PREFIX}$SUFFIX"

echo Do this to uninstall and then install:
echo rpm -e --nodeps $PKGS || true
echo dnf install -y --disableexcludes=all $FULLPKGS
