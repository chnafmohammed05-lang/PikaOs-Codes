#!/bin/bash

echo "Pika Kernel - Applying configuration"

cp ../config .config

make prepare

scripts/config -d MZEN4 -d X86_NATIVE_CPU
scripts/config -e GENERIC_CPU --set-val X86_64_VERSION 3
#scripts/config -e CACHY -e SCHED_BORE
scripts/config -e CACHY

#scripts/config -e LTO -e LTO_CLANG -e ARCH_SUPPORTS_LTO_CLANG -e ARCH_SUPPORTS_LTO_CLANG_THIN -e HAS_LTO_CLANG -e LTO_CLANG_THIN_DIST -d LTO_NONE -d LTO_CLANG_FULL -d LTO_CLANG_THIN -e HAVE_GCC_PLUGINS
scripts/config -e LTO -e LTO_CLANG -e ARCH_SUPPORTS_LTO_CLANG -e ARCH_SUPPORTS_LTO_CLANG_THIN -e HAS_LTO_CLANG -e LTO_CLANG_FULL -d LTO_NONE -d LTO_CLANG_FULL -d LTO_CLANG_THIN -e HAVE_GCC_PLUGINS
scripts/config -e HZ_1000 --set-val HZ 1000
scripts/config -d HZ_PERIODIC -d NO_HZ_IDLE -d CONTEXT_TRACKING_FORCE -e NO_HZ_FULL_NODEF -e NO_HZ_FULL -e NO_HZ -e NO_HZ_COMMON -e CONTEXT_TRACKING
scripts/config -e PREEMPT_BUILD -d PREEMPT_NONE -d PREEMPT_VOLUNTARY -e PREEMPT -e PREEMPT_COUNT -e PREEMPTION -e PREEMPT_DYNAMIC
scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE -e CC_OPTIMIZE_FOR_PERFORMANCE_O3

scripts/config -e SCHED_CLASS_EXT
scripts/config -e I2C_CHARDEV

# This will somewhat bork HDR on steamdeck oled when not in gamescope - it also introduces crashes though so we need to disable for now 
scripts/config -d AMD_PRIVATE_COLOR

# nova is not ready so make sure it is disabled
scripts/config -d NOVA_CORE

scripts/config -e LRU_GEN -e LRU_GEN_ENABLED -d LRU_GEN_STATS

scripts/config -d TRANSPARENT_HUGEPAGE_MADVISE -e TRANSPARENT_HUGEPAGE_ALWAYS

scripts/config -e PER_VMA_LOCK -d PER_VMA_LOCK_STATS

scripts/config -e DAMON \
            -e DAMON_VADDR \
            -e DAMON_DBGFS \
            -e DAMON_SYSFS \
            -e DAMON_PADDR \
            -e DAMON_RECLAIM \
            -e DAMON_LRU_SORT

scripts/config -e SENSORS_STEAMDECK \
            -e MFD_STEAMDECK \
            -e HID_MSI_CLAW \
            -e ZOTAC_ZONE_HID \
            --set-val ZOTAC_ZONE_HID m \
            -e LEDS_STEAMDECK \
            -e ACPI_CALL \
            -e LENOVO_WMI_EVENTS \
            -e LENOVO_WMI_HELPERS \
            -e LENOVO_WMI_GAMEZONE \
            -e LENOVO_WMI_DATA01 \
            -e LENOVO_WMI_TUNING \
            --set-val LENOVO_WMI_EVENTS m \
            --set-val LENOVO_WMI_HELPERS m \
            --set-val LENOVO_WMI_GAMEZONE m \
            --set-val LENOVO_WMI_DATA01 m \
            --set-val LENOVO_WMI_TUNING m \
            -e MSI_WMI_PLATFORM \
            -e ZOTAC_ZONE_PLATFORM \
            --set-val ZOTAC_ZONE_PLATFORM m \
            -e EXTCON_STEAMDECK

scripts/config --set-val MODULE_COMPRESS_ZSTD_LEVEL 19 -e MODULE_COMPRESS_ZSTD_ULTRA --set-val MODULE_COMPRESS_ZSTD_LEVEL_ULTRA 22 --set-val ZSTD_COMP_VAL 22
scripts/config -e EFI_HANDOVER_PROTOCOL -e USER_NS

echo "Pika config script alterations:"
diff -u ../config .config || :
