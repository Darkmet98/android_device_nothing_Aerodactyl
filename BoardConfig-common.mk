#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

BUILD_BROKEN_DUP_RULES := true

DEVICE_PATH := device/nothing/Aerodactyl
KERNEL_SOURCE := kernel/nothing/mt6886
KERNEL_MODULES := kernel/nothing/vendor/mediatek/kernel_modules

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv9-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 420

# Filesystem
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/configs/aids/config.fs

# HIDL
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml \
    $(DEVICE_PATH)/device_framework_matrix.xml
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE += $(DEVICE_PATH)/compatibility_matrix.xml

ODM_MANIFEST_SKUS += EEA IND ROW
ODM_MANIFEST_EEA_FILES += $(DEVICE_PATH)/configs/skus/vintf/manifest_EEA.xml
ODM_MANIFEST_IND_FILES += $(DEVICE_PATH)/configs/skus/vintf/manifest_IND.xml
ODM_MANIFEST_ROW_FILES += $(DEVICE_PATH)/configs/skus/vintf/manifest_ROW.xml

# Kernel
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_TAGS_OFFSET := 0x07c88000
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_RAMDISK_USE_LZ4 := true

BOARD_KERNEL_CMDLINE += androidboot.console=0
BOARD_KERNEL_CMDLINE += bootopt=64S3,32N2,64N2
BOARD_KERNEL_CMDLINE += cgroup_disable=memory
BOARD_KERNEL_CMDLINE += initcall_debug=0 loglevel=0 log_buf_len=1024K
BOARD_KERNEL_CMDLINE += kasan=off
BOARD_KERNEL_CMDLINE += rcu_nocbs=all rcutree.enable_rcu_lazy
BOARD_KERNEL_CMDLINE += sysctl.kernel.sched_pelt_multiplier=4
BOARD_KERNEL_CMDLINE += kasan=off

BOARD_INIT_BOOT_HEADER_VERSION := 4

BOARD_MKBOOTIMG_ARGS += \
    --base $(BOARD_KERNEL_BASE) \
    --dtb_offset $(BOARD_TAGS_OFFSET) \
    --header_version $(BOARD_BOOT_HEADER_VERSION) \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --pagesize $(BOARD_KERNEL_PAGESIZE) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_TAGS_OFFSET)

BOARD_MKBOOTIMG_INIT_ARGS += \
    --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_KERNEL_IMAGE_NAME := Image.lz4
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# Build kernel, DTB, DTBO and modules from Nothing's MT6886 sources.
TARGET_KERNEL_SOURCE := $(KERNEL_SOURCE)
TARGET_KERNEL_CONFIG := gki_defconfig
TARGET_KERNEL_CONFIG_EXT := \
    $(DEVICE_PATH)/configs/kernel/mgk_64_k515.config \
    $(KERNEL_SOURCE)/arch/arm64/configs/lineage.config \
    $(DEVICE_PATH)/configs/kernel/opt_a_bbr.config
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CLANG_PATH := $(abspath prebuilts/clang/host/linux-x86/clang-r450784e)
TARGET_KERNEL_LLVM_BINUTILS := true
KERNEL_LTO := thin

TARGET_KERNEL_DTB := \
    mediatek/mt6886.dtb \
    mediatek/k6886v1_64.dtbo \
    mediatek/k6886v1_64_1.dtbo \
    mediatek/k6886v1_64_2.dtbo
TARGET_DTB_LIST_WILDCARD := mediatek/mt6886
TARGET_NEEDS_DTBOIMAGE := true
BOARD_KERNEL_SEPARATED_DTBO := true
TARGET_KERNEL_DTBO := dtbo.img
BOARD_PREBUILT_DTBOIMAGE = $(TARGET_OUT_INTERMEDIATES)/DTBO_OBJ/arch/$(TARGET_ARCH)/boot/$(TARGET_KERNEL_DTBO)
BOARD_DTBO_CFG := $(DEVICE_PATH)/configs/kernel/mkdtboimg.cfg

TARGET_KERNEL_EXT_MODULE_ROOT := $(KERNEL_MODULES)
TARGET_KERNEL_EXT_MODULES := \
    connectivity/common \
    connectivity/connfem \
    connectivity/conninfra \
    connectivity/bt/mt66xx/btif \
    connectivity/fmradio \
    connectivity/gps/data_link/plat/v051 \
    connectivity/gps/gps_pwr \
    connectivity/gps/gps_scp \
    connectivity/wlan/adaptor \
    connectivity/wlan/core/gen4m \
    gpu

TARGET_KERNEL_ADDITIONAL_FLAGS += \
    TOP=$(abspath .) \
    BRANCH=android13-5.15 \
    KMI_GENERATION=8 \
    TARGET_BUILD_VARIANT=user \
    BT_PLATFORM=6886 \
    LOG_TAG=[BT_Drv][btif] \
    CONFIG_FM_USER_LOAD=1 \
    CONFIG_MTK_COMBO_WIFI_HIF=axi \
    CONNAC_VER=2_0 \
    MTK_ANDROID_EMI=y \
    MTK_ANDROID_WMT=y \
    MTK_COMBO_CHIP=CONNAC2X2_SOC7_0 \
    MTK_WLAN_SERVICE=yes \
    WIFI_IP_SET=1 \
    WLAN_CHIP_ID=6886

BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/system_dlkm.modules.load))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/vendor_dlkm.modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/vendor_ramdisk.modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/vendor_ramdisk.modules.load.recovery))

# kernel.mk requires an explicit source-module selection for vendor_boot.
# The *_MODULES_LOAD variables only control load order; they do not copy .ko files.
BOOT_KERNEL_MODULES := $(sort \
    $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD) \
    $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD))

# Source builds use module basenames; kernel.mk resolves and packages their paths.
SYSTEM_KERNEL_MODULES := $(BOARD_SYSTEM_KERNEL_MODULES_LOAD)

# Partitions
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    odm \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

BOARD_USES_METADATA_PARTITION := true

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_FLASH_BLOCK_SIZE := $(BOARD_KERNEL_PAGESIZE)
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := $(BOARD_DTBOIMG_PARTITION_SIZE)
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := $(BOARD_BOOTIMAGE_PARTITION_SIZE)

ifeq ($(PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE),ext4)
-include vendor/lineage/config/BoardConfigReservedSize.mk
endif

BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_SUPER_PARTITION_GROUPS := nothing_dynamic_partitions
BOARD_NOTHING_DYNAMIC_PARTITIONS_PARTITION_LIST := system product system_ext vendor odm system_dlkm vendor_dlkm odm_dlkm
BOARD_NOTHING_DYNAMIC_PARTITIONS_SIZE := $(shell expr $(BOARD_SUPER_PARTITION_SIZE) - 4194304)

BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := $(PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE)
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := $(PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE)
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := $(PRODUCT_SYSTEM_PARTITIONS_FILE_SYSTEM_TYPE)
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_EROFS_COMPRESS_HINTS := $(DEVICE_PATH)/configs/partitions/erofs_compress_hints.txt
BOARD_EROFS_PCLUSTER_SIZE := 262144
PRODUCT_FS_COMPRESSION := 1

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# Platform
TARGET_BOARD_PLATFORM := mt6886

# Properties
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.mt6886
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_USERIMAGES_USE_F2FS := true

# SEPolicy
include device/mediatek/sepolicy_vndr/SEPolicy.mk

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Verified Boot
BOARD_AVB_ENABLE := true
#ifneq ($(filter PacmanPro, $(PRODUCT_DEVICE)),)
#BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
#endif
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem

BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA2048
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_SYSTEM := product system system_dlkm system_ext
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR := odm odm_dlkm vendor vendor_dlkm
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# Wifi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := $(BOARD_WPA_SUPPLICANT_DRIVER)
WIFI_DRIVER_FW_PATH_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM := $(WIFI_DRIVER_FW_PATH_PARAM)
WIFI_DRIVER_STATE_ON := "1"
WIFI_DRIVER_STATE_OFF := "0"
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 2}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{AP_BRIDGED}, 1},}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{AP}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{P2P}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{NAN}, 1}}
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WIFI_FEATURE_HOSTAPD_11AX := true
WIFI_FEATURE_SUPPLICANT_11AX := true

# Inherit the proprietary files
include vendor/nothing/Aerodactyl/BoardConfigVendor.mk
