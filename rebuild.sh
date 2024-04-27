#!/bin/bash

set -x
PKG="$1"  # package, e.g. 'mutter'
REL="${2:-40}"  # Fedora version, e.g. '40'
PATCH="${3:-$PKG-$REL.patch}"
ARCH="${ARCH:-x86_64}"

F_VERSION="$(dnf -q --releasever="$REL" --disablerepo copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched list --available "$PKG" --refresh | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"
COPR_VERSION="$(dnf -q --releasever="$REL" --repo copr:copr.fedorainfracloud.org:andrewdelosreyes:gnome-patched list --available "$PKG" --refresh | grep "$PKG\.$ARCH" | awk '{print $2}' | sed 's/\.adlr//')"

if [ "$F_VERSION" = "$COPR_VERSION" ]; then
  echo "No new version"
  exit 0
fi
echo "Making new package for $F_VERSION"

TMP="$(dirname "$0")/rebuild-work"
mkdir -p "$TMP"

set -ex
cd "$TMP"

# Fetch upstream srpm
dnf download --source "$PKG" --disableexcludes=all --releasever="$REL"

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
if specfile.release == '%autorelease':
  specfile.release = f'{RELEASE}%{{?dist}}.adlr'
else:
  specfile.release = specfile.release + '.adlr'
with specfile.patches() as patches:
  patches.append('$PKG-f$REL.patch')
specfile.save()
EOF
)"
python -c "$PATCH_SCRIPT"

cp ../../$PKG-f$REL.patch .

# repackage
rpmbuild -bs "$PKG".spec --define "_sourcedir $PWD" --define "_srcrpmdir $PWD/../pkg-new"

cd ..

# push to copr
copr-cli build andrewdelosreyes/gnome-patched pkg-new/*.src.rpm


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
