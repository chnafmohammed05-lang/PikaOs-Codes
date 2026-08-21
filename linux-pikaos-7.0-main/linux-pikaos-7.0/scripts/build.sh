#!/bin/bash

echo "Pika Kernel - Building"

make CC=clang LD=ld.lld LLVM=1 LLVM_IAS=1 -j32 bindeb-pkg LOCALVERSION=-pikaos KDEB_PKGVERSION=$(make kernelversion)-101pika1