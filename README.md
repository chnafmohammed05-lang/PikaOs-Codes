# PikaOs-Codes
This repository contains kernel sources, patches, and packaging helpers used when building and maintaining the Pika OS kernels and kernel modules.

## Repository layout
- `kernel-pika-main`
  - Kernel sources and patches specific to the Pika OS kernel branch called "kernel-pika-main". This folder typically contains the kernel tree (source files, Makefiles, Kconfig) and any small Pika-specific patches or drivers maintained separately from upstream Linux.

- `linux-pikaos-6.19-main`
  - A Pika OS kernel tree based on the Linux 6.19 series. Use this tree if you need a 6.19-compatible kernel with Pika OS customizations, configuration files, and platform-specific patches.

- `linux-pikaos-7.0-main`
  - A Pika OS kernel tree based on the Linux 7.0 series. Similar to the 6.19 tree but tracking the 7.0 branch and its corresponding patches/configs.

- `pkg-nvidia-pikaos-kernel-module-main`
  - Packaging and build scripts for the NVIDIA kernel module targeted at Pika OS. This directory usually contains DKMS or distribution packaging helpers, build scripts, and any module-specific patches or install rules.

## Quick build notes (general)
1. Choose the kernel directory you want to build (for example, `linux-pikaos-7.0-main`).
2. Inspect that directory for a README or build script. If none exists, a typical kernel build flow is:
   - Prepare the config (copy a defconfig or `make menuconfig` / `make defconfig`).
   - Run `make` (or the distro-specific build script) to compile the kernel and modules.
   - Install modules with `make modules_install` and the kernel with `make install`, or use the provided packaging scripts in the `pkg-*` directories.
3. For kernel modules (e.g. NVIDIA): use the packaging/build scripts in `pkg-nvidia-pikaos-kernel-module-main` to produce an installable package or use DKMS if supported.

## Contributing
- If you add patches or update kernel configs, please include a short CHANGELOG or commit message explaining the purpose.
- Open issues or pull requests for larger changes so we can review compatibility across the 6.19 and 7.0 trees.

If you'd like, I can expand each directory's description by listing the files inside and adding exact build commands (if those scripts or configs exist).