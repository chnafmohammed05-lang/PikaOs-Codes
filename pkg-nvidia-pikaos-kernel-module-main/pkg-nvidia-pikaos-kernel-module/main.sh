#!/usr/bin/env bash

set -euo pipefail

# The module repo is intentionally built by the central package workflow.  The
# legacy per-driver workflows were removed during cutover; build newest source
# available for current kernel so the generic provider is backed by real modules.
driver="$(apt-cache pkgnames \
    | sed -n 's/^nvidia-kernel-source-\([0-9][0-9]*\)$/\1/p' \
    | sort -n | tail -n1)"
[ -n "$driver" ] || { echo "No NVIDIA kernel source package is available" >&2; exit 1; }
echo "Building NVIDIA ${driver} modules"
bash ./build-driver.sh "$driver"

shopt -s nullglob
debs=(output/*.deb)
if ((${#debs[@]} == 0)); then
    echo "No NVIDIA module packages were produced" >&2
    exit 1
fi
printf 'Produced %d NVIDIA module packages\n' "${#debs[@]}"
