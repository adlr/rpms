#!/bin/bash

set -x
REBUILD=no

if [ "$1" = "-r" ]; then
  REBUILD=yes
  shift
fi

PKG="$1"  # package, e.g. 'mutter'
REL="${2:-41}"  # Fedora version, e.g. '40'
PATCH="$(readlink -f "${3:-$PKG-f$REL.patch}")"
PATCH_BASENAME="$(basename "$PATCH")"
ARCH="${ARCH:-x86_64}"

REFRESH="--refresh"

#F_VERSION="$(dnf4 -q --releasever="$REL" --repo updates --showduplicates --available list "$PKG.$ARCH" $REFRESH | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
F_VERSION="$(dnf -q $REFRESH --releasever="$REL" --repo updates list --showduplicates --available "$PKG.$ARCH" | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
REPO="updates"
if [ -z "$F_VERSION" ]; then
  #F_VERSION="$(dnf4 -q --releasever="$REL" --repo fedora --showduplicates --available list "$PKG.$ARCH" $REFRESH | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
  F_VERSION="$(dnf -q $REFRESH --releasever="$REL" --repo fedora list --showduplicates --available "$PKG.$ARCH" | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
  REPO="fedora"
fi
#COPR_VERSION="$(dnf4 -q --releasever="$REL" --repo copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched --showduplicates --available list "$PKG.$ARCH" $REFRESH | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
COPR_VERSION="$(dnf -q $REFRESH --releasever="$REL" --repo copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched list --showduplicates --available "$PKG.$ARCH" | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"

if [ "$F_VERSION" = "$COPR_VERSION" ]; then
  echo "No new version"
  if [ "$REBUILD" = "no" ]; then
    exit 0
  else
    echo "Rebuilding"
  fi
fi
echo "Making new package for $F_VERSION"

TMP="$(dirname "$0")/rebuild-work"
if [ -d "$TMP" ]; then
  rm -rf "$TMP"
fi
mkdir -p "$TMP"

set -ex
cd "$TMP"

# Fetch upstream srpm
dnf4 download --repo "$REPO" --source "$PKG" --disableexcludes=all --releasever="$REL"

mkdir pkg
mkdir pkg-new
cd pkg
rpm2cpio ../*.src.rpm | cpio -idmv

# Patch 
RELEASE="$(echo "$F_VERSION" | sed 's/.*-\([0-9]*\)\.fc.*/\1/')"

PATCH_SCRIPT="$(cat << EOF
from specfile import Specfile
specfile = Specfile('$PKG.spec')
RELEASE=$RELEASE
if specfile.raw_release == '%autorelease':
  specfile.raw_release = f'{RELEASE}%{{?dist}}.adlr'
else:
  specfile.raw_release = specfile.raw_release + '.adlr'
with specfile.patches() as patches:
  patches.append('$PATCH_BASENAME')
specfile.save()
EOF
)"
python -c "$PATCH_SCRIPT"

cp "$PATCH" .

LOCALBUILD=no
if [ "$LOCALBUILD" = "yes" ]; then
  rpmbuild -ba "$PKG".spec --define "_sourcedir $PWD" --define "_srcrpmdir $PWD/../pkg-new"
fi
  # Just repackage
  rpmbuild -bs "$PKG".spec --define "_sourcedir $PWD" --define "_srcrpmdir $PWD/../pkg-new"
cd ..

if [ "$LOCALBUILD" = "no" ]; then
  # push to copr
  copr-cli build -r fedora-${REL}-x86_64 andrewdelosreyes/gnome-patched pkg-new/*.src.rpm
fi

############ update available
#Last metadata expiration check: 0:37:52 ago on Fri 26 Apr 2024 06:36:49 PM PDT.
#Installed Packages
#mutter.x86_64 46.0-1.fc40.adlr @copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched
#Available Packages
#mutter.i686   46.0-1.fc40      fedora                                                        
#mutter.x86_64 46.0-1.fc40      fedora                                                        
#mutter.src    46.0-1.fc40.adlr copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched 
#mutter.x86_64 46.0-1.fc40.adlr copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched 
#mutter.i686   46.1-2.fc40      updates                                                       
#mutter.x86_64 46.1-2.fc40      updates                                                       
########### update available w/o show dups
#Last metadata expiration check: 0:38:14 ago on Fri 26 Apr 2024 06:36:49 PM PDT.
#Installed Packages
#mutter.x86_64 46.0-1.fc40.adlr @copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched
#Available Packages
#mutter.src    46.0-1.fc40.adlr copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched 
#mutter.i686   46.1-2.fc40      updates                                                       
#mutter.x86_64 46.1-2.fc40      updates                                                       
############ no update available
