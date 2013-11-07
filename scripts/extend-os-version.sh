#!/bin/sh

[ -z "$1" ] && exit 1

if [ "$1" == "solaris" ] || [ "$1" == "sunos" ]; then
    if [ -f /usr/sbin/zoneadm ]; then
        /usr/sbin/zoneadm list -vi | grep `zonename` | awk '{ print $1 }'
        if [ $? -eq 0 ]; then
            echo "global"
        else
            echo "non-global"
        fi
        exit 0
    else
        exit 1
    fi
elif [ "$1" == "mac os x" ]; then
    echo "lion"
    exit 0
else
    exit 1
fi
