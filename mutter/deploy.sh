#!/bin/bash

HOST=192.168.1.223
PKG=mutter-42.1-2.fc36.adlr.x86_64.rpm
PKG_FULL=x86_64/mutter-42.1-2.fc36.adlr.x86_64.rpm

scp $PKG_FULL adlr@${HOST}:/home/adlr/
ssh adlr@${HOST} "echo hi && echo okay && systemctl list"
