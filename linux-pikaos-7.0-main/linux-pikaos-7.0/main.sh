#! /bin/bash

export DEBIAN_FRONTEND="noninteractive"

apt-get update -y
apt-get install -y clang lld llvm libdw-dev

mkdir -p ./output

. ./scripts/source.sh
. ../scripts/patch.sh
. ../scripts/config.sh
. ../scripts/build.sh
. ../scripts/output.sh
