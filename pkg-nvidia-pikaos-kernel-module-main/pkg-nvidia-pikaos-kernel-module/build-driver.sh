#!/usr/bin/env bash

set -euo pipefail

driver="${1:?driver number is required}"
source_package="nvidia-kernel-source-${driver}"

kernel="$(apt-cache show kernel-pika 2>/dev/null \
    | awk '/^Depends:/{for (i = 2; i <= NF; i++) if ($i ~ /^linux-image-/) {sub(/^linux-image-/, "", $i); sub(/,.*$/, "", $i); print $i; exit}}')"
[ -n "$kernel" ] || { echo "could not determine kernel version from kernel-pika" >&2; exit 1; }

source_version="$(apt-cache policy "$source_package" \
    | awk '/Candidate:/{print $2; exit}')"
[ -n "$source_version" ] && [ "$source_version" != "(none)" ] || {
    echo "$source_package is not available" >&2
    exit 1
}

driver_version="${source_version%%-*}"
source_root="/var/tmp/pika-nvidia-${driver}-${driver_version}"
rm -rf "$source_root"
mkdir -p "$source_root"
trap 'rm -rf "$source_root"' EXIT

cd linux-nvidia-modules
apt download "$source_package=$source_version"
source_deb="$(find . -maxdepth 1 -type f -name "${source_package}_*.deb" -print -quit)"
[ -n "$source_deb" ] || { echo "downloaded $source_package but no .deb was found" >&2; exit 1; }
dpkg-deb -x "$source_deb" "$source_root"
source_dir="$source_root/usr/src/modules/nvidia-kernel"
[ -f "$source_dir/Kbuild" ] || { echo "$source_package has no kernel source tree" >&2; exit 1; }

upstream_driver_version="$(awk -F '"' '/NV_VERSION_STRING=/{print $2; exit}' \
    "$source_dir/Kbuild" | tr -d '\\')"
[ -n "$upstream_driver_version" ] || upstream_driver_version="$driver_version"

package_version="${source_version}-${kernel}-100pika9"
module_package="linux-modules-nvidia-${driver}-${kernel}"
placeholder_package="nvidia-pika-kernel-module-${driver}"

cat >debian/control <<EOF
Source: linux-nvidia-modules
Section: graphics
Priority: optional
Maintainer: Ward Nakchbandi <hotrod.master@hotmail.com>
Standards-Version: 4.6.1
Build-Depends: debhelper-compat (= 13), linux-image-${kernel}, linux-headers-${kernel}, clang, lld, fakeroot
Rules-Requires-Root: no

Package: ${module_package}
Architecture: linux-any
Depends: linux-image-${kernel}, linux-headers-${kernel}
Provides: linux-modules-nvidia-${kernel}
Description: Prebuilt NVIDIA modules for PikaOS kernel ${kernel}

Package: ${placeholder_package}
Architecture: linux-any
Depends: ${module_package} (= \${binary:Version})
Description: NVIDIA kernel module dependency provider
EOF

cat >"debian/${module_package}.install" <<EOF
usr
EOF

cat >debian/changelog <<EOF
linux-nvidia-modules (${package_version}) pikauwu; urgency=medium

  * Build NVIDIA ${driver} modules for kernel ${kernel}.

 -- Ward Nakchbandi <hotrod.master@hotmail.com>  $(LC_ALL=C date '+%a, %d %b %Y %H:%M:%S %z')
EOF

cat >debian/postinst <<EOF
#!/bin/sh
set -e
depmod -a '${kernel}' || true
update-initramfs -u -k '${kernel}' || true
EOF
chmod +x debian/postinst

cat >debian/postrm <<EOF
#!/bin/sh
set -e
depmod -a '${kernel}' || true
update-initramfs -u -k '${kernel}' || true
EOF
chmod +x debian/postrm

cat >Makefile <<EOF
SOURCE_DIR := ${source_dir}
KERNEL := ${kernel}
DRIVER := ${driver}
DRIVER_VERSION := ${upstream_driver_version}
CLANG_INCLUDE := \$(shell clang -print-resource-dir)/include
KCFLAGS := -isystem \$(CLANG_INCLUDE) -I\$(SOURCE_DIR)/common/inc -I\$(SOURCE_DIR) -DNV_VERSION_STRING=\"\$(DRIVER_VERSION)\"

.PHONY: all install
all:
	true

install:
	make -C "\$(SOURCE_DIR)" KERNEL_UNAME="\$(KERNEL)" CC=clang LD=ld.lld IGNORE_CC_MISMATCH=1 KCFLAGS="\$(KCFLAGS)" modules
	install -Dt "\$(DESTDIR)/usr/lib/modules/\$(KERNEL)/extramodules" -m644 \$(SOURCE_DIR)/*.ko
	find "\$(DESTDIR)" -name '*.ko' -exec xz -T1 {} +
	install -D -m644 blacklist-pika-nouveau.conf "\$(DESTDIR)/usr/lib/modprobe.d/blacklist-pika-nouveau.conf"
	install -D -m644 pika-nvidia.conf "\$(DESTDIR)/usr/lib/modules-load.d/pika-nvidia.conf"
EOF

apt-get build-dep ./ -y
dpkg-buildpackage --no-sign
cd ..
mkdir -p output
mv ./*.deb output/
