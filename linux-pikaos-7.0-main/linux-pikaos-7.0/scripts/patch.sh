#!/bin/bash

echo "Pika Kernel - Applying patches"

if [ -f ../patches/series ]
then
    for i in $(cat ../patches/series | grep -v '^#') ; do echo "Applying Patch: $i" && patch -Np1 -i ../patches/$i || bash -c "echo "Applying Patch $i Failed!" && exit 2"; done
fi

#echo "revert hdmi"
#patch -Rp1 -i ../patches/hdmi-revert.patch
#echo "revert 1"
#patch -Rp1 -i ../patches/revert1.patch