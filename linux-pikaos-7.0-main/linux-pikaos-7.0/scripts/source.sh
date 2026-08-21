#!/bin/bash

echo "Pika Kernel - Getting source"
wget -nv https://github.com/CachyOS/linux/releases/download/cachyos-"$(cat ./VERSION)"-1/cachyos-"$(cat ./VERSION)"-1.tar.gz

tar -xf ./cachyos-"$(cat ./VERSION)"-1.tar.gz

cd cachyos-"$(cat ./VERSION)"-1
