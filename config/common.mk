PRODUCT_BRAND ?= MagicMod

-include vendor/mm-priv/keys.mk

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.mm.superuser

# To deal with MM9 specifications
# TODO: remove once all devices have been switched
ifneq ($(TARGET_BOOTANIMATION_NAME),)
TARGET_SCREEN_DIMENSIONS := $(subst -, $(space), $(subst x, $(space), $(TARGET_BOOTANIMATION_NAME)))
ifeq ($(TARGET_SCREEN_WIDTH),)
TARGET_SCREEN_WIDTH := $(word 2, $(TARGET_SCREEN_DIMENSIONS))
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
TARGET_SCREEN_HEIGHT := $(word 3, $(TARGET_SCREEN_DIMENSIONS))
endif
endif

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# clear TARGET_BOOTANIMATION_NAME in case it was set for MM9 purposes
TARGET_BOOTANIMATION_NAME :=

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/mm/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_BOOTANIMATION := vendor/mm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif

#ifdef MM_NIGHTLY
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.rommanager.developerid=cyanogenmodnightly
#else
#PRODUCT_PROPERTY_OVERRIDES += \
#    ro.rommanager.developerid=cyanogenmod
#endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.google.clientidbase=android-google \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy our launcher
PRODUCT_COPY_FILES +=  \
    vendor/mm/prebuilt/common/app/MagicLauncher.apk:system/app/MagicLauncher.apk \

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/mm/CHANGELOG.mkdn:system/etc/CHANGELOG-MM.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/mm/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/mm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/mm/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/mm/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# MM-specific init file
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Compcache/Zram support
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/bin/compcache:system/bin/compcache \
    vendor/mm/prebuilt/common/bin/handle_compcache:system/bin/handle_compcache

# Default default theme
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/media/default.ctz:system/media/default.ctz
    
# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/mm/proprietary/Term.apk:system/app/Term.apk \
    vendor/mm/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/mm/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/mm/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is MM!
#PRODUCT_COPY_FILES += \
#    vendor/mm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/mm/prebuilt/common/etc/mkshrc:system/etc/mkshrc

# T-Mobile theme engine
include vendor/mm/config/themes_common.mk

# Required MM packages
PRODUCT_PACKAGES += \
    Development \
    LatinIME \
    BluetoothExt

# Optional MM packages
PRODUCT_PACKAGES += \
    VoicePlus \
    VoiceDialer \
    SoundRecorder \
    Basic \
    libemoji

# Custom MM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    Apollo \
    CMFileManager \
    LockClock \
    FileExplorer \
    MMPhoneNumGeoProvider

# MM Hardware Abstraction Framework
#PRODUCT_PACKAGES += \
#    org.cyanogenmod.hardware \
#    org.cyanogenmod.hardware.xml

PRODUCT_PACKAGES += \
    CellBroadcastReceiver

# Extra tools in MM
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    vim \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    procmem \
    procrank \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    CMUpdater \
    Superuser \
    su

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/cm/proprietary/Term.apk:system/app/Term.apk \
    vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PACKAGES += \
    CMFota

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/mm/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/mm/overlay/common

PRODUCT_VERSION_MAJOR = DE
PRODUCT_VERSION_MINOR = 4.4
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# Set MM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef MM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "MM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^MM_||g')
        MM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(MM_BUILDTYPE)),)
    MM_BUILDTYPE :=
endif

ifdef MM_BUILDTYPE
    ifneq ($(MM_BUILDTYPE), SNAPSHOT)
        ifdef MM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            MM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from MM_EXTRAVERSION
            MM_EXTRAVERSION := $(shell echo $(MM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to MM_EXTRAVERSION
            MM_EXTRAVERSION := -$(MM_EXTRAVERSION)
        endif
    else
        ifndef MM_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            MM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from MM_EXTRAVERSION
            MM_EXTRAVERSION := $(shell echo $(MM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to MM_EXTRAVERSION
            MM_EXTRAVERSION := -$(MM_EXTRAVERSION)
        endif
    endif
else
    # If MM_BUILDTYPE is not defined, set to UNOFFICIAL
    MM_BUILDTYPE := LOCAL_BUILD
    MM_EXTRAVERSION := $(shell hostname)
endif

ifeq ($(MM_BUILDTYPE), RELEASE)
    MM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(MM_BUILD)
else
    ifeq ($(PRODUCT_VERSION_MINOR),0)
        MM_VERSION := $(PRODUCT_VERSION_MAJOR)-$(shell date -u +%Y%m%d)-$(MM_BUILDTYPE)-$(MM_EXTRAVERSION)-$(MM_BUILD)
    else
        MM_VERSION := $(PRODUCT_VERSION_MAJOR)-$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(MM_BUILDTYPE)-$(MM_EXTRAVERSION)-$(MM_BUILD)
    endif
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.mm.version=$(MM_VERSION) \
  ro.modversion=$(MM_VERSION) \
  ro.mm.mmname=MagicMod \
  ro.mm.mmversion=4.3-DevelopmentEdition

-include vendor/mm/sepolicy/sepolicy.mk

-include vendor/cm-priv/keys/keys.mk

-include $(WORKSPACE)/hudson/image-auto-bits.mk
