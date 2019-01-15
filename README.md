----------------------------------------------------------------------------------------------
AKBS - Easily automate your kernel building process with one script and the help of AnyKernel2
----------------------------------------------------------------------------------------------
### by osm0sis @ xda-developers ###

"AnyKernel is a template for an update.zip that can apply any kernel to any ROM, regardless of ramdisk." - Koush

AnyKernel2 pushes the format even further by allowing kernel developers to modify the underlying ramdisk for kernel feature support easily using a number of included command methods along with properties and variables.

### by OrdenKrieger @ xda-developers ###

The advanced kernel builder script - AKBS will help you to focus mainly on the kernel development, without
the stress writing a custom script for every kernel you might wanna create.

With the easy way of setting your properties, in the config file you're good to go, creating what ever flashable kernel you want.
The script will add the set properties in the config file to the AnyKernel2 project and easily create a zip
which will be ready to flash.

## // Instructions ##

Set everything you need in the `config` file and run `./build.sh`. Enjoy your flashable kernel.

If supporting a recovery that forces zip signature verification (like Cyanogen Recovery) then you will need to also sign your zip using the method I describe here:

http://forum.xda-developers.com/android/software-hacking/dev-complete-shell-script-flashable-zip-t2934449

Not required, but any tweaks you can't hardcode into the source (best practice) should be added with an additional init.tweaks.rc or bootscript.sh to minimize the necessary ramdisk changes.

Have fun!

## // AnyKernel2 Properties / Variables ##
```
VER="v.x.x.x what ever you want"
BASE_VER="YourKernelName"
AK_NAME1="first name"
AK_NAME2="another name"
AK_NAME3="another name"
AK_NAME4=""
AK_NAME5=""
```

__AK_DEVICECHECK="1"__ specified requires at least device.name1 to be present. This should match ro.product.device or ro.build.product for your device. There is support for as many device.name# properties as needed. You may remove any empty ones that aren't being used.

__AK_MODULES="1"__ will push the contents of the module directory to the same location relative to root (/) and apply 644 permissions.

__AK_CLEANUP="0"__ will keep the zip from removing it's working directory in /tmp/anykernel - this can be useful if trying to debug in adb shell whether the patches worked correctly.

__AK_CLEANUPONABORT="0"__ will keep the zip from removing it's working directory in /tmp/anykernel in case of installation abort.

__AK_SUPPORTED_VERSIONS=""__ will match against ro.build.version.release from the current ROM's build.prop. It can be set to a list or range. As a list, e.g. `7.1.2` or `8.1.0, 9` it will look for exact matches, as a range, e.g. `7.1.2 - 9` it will check to make sure the current version falls within those limits. Whitespace optional, and supplied version values should be in the same number format they are in the build.prop value for that Android version.

__AK_BLOCK="auto"__ instead of a direct block filepath enables detection of the device boot partition for use with broad, device non-specific zips. Also accepts specifically `boot` or `recovery`.

__AK_IS_SLOT_DEVICE="1"__ enables detection of the suffix for the active boot partition on slot-based devices and will add this to the end of the supplied `block=` path. Also accepts `auto` for use with broad, device non-specific zips.

__AK_RAMDISK_COMPRESSION="auto"__ allows automatically repacking the ramdisk with the format detected during unpack, changing `auto` to `gz`, `lzo`, `lzma`, `xz`, `bz2`, `lz4`, or `lz4-l` (for lz4 legacy) instead forces the repack as that format.

## // AKBS Properties / Variables ##
```
BUILD_DIR="path to AKBS folder"
KERNEL_DIR="path to your kernel"
KSOURCE_GIT="https://github.com/mygithub/supercoolkernel.git -b mybranch"
KERNEL_ARCH="your kernel arch"
KERNEL_DEFCONFIG="defconfig you want to use"
TOOLCHAIN_DIR="path to toolchain you want to use"
KERNEL_IMAGE="kernel image format your device supports"
ZIP_MOVE="output folder for your flashable kernel"
HEADLINE_TXT="Your fancy new kernel builder script. Start building..."
```

__OUTPUT_EMPTY_CHECK="1"__ if enabled, ask every build if you want to clean the output directory

__COLOR_BUILD_PROCESS="1"__ if enabled, color background and text to the color of your choice

__CLEAR_ON_SUCCESS="1"__ if enabled, wipe the kernel history from your terminal (ONLY ON SUCCESS; on error not for debug)

__OUTPUT_CLEAN_UP="1"__ if enabled, output folders from the zip and kernel build will be cleaned (ONLY ON SUCCESS; on error not for debug)

## // Binary Inclusion ##

The AK2 repo includes my latest static ARM builds of `mkbootimg`, `unpackbootimg`,`busybox`, `xz` and `lz4` by default to keep the basic package small. Builds for other architectures and optional binaries (see below) are available from my latest AIK-mobile and FlashIt packages, respectively, here:

https://forum.xda-developers.com/showthread.php?t=2073775 (Android Image Kitchen thread)
https://forum.xda-developers.com/showthread.php?t=2239421 (Odds and Ends thread)

Optional supported binaries which may be placed in /tools to enable built-in expanded functionality are as follows:
* `mkbootfs` - for broken recoveries, or, booted flash support for a script/app via bind mount to /tmp (deprecated/use with caution)
* `flash_erase`, `nanddump`, `nandwrite` - MTD block device support for devices where the `dd` command is not sufficient
* `pxa-unpackbootimg`, `pxa-mkbootimg` - Samsung/Marvell PXA1088/PXA1908 boot.img format variant support
* `dumpimage`, `mkimage` - DENX U-Boot uImage format support
* `unpackelf` - Sony ELF kernel.elf format support, repacking as AOSP standard boot.img for unlocked bootloaders
* `elftool`, `unpackelf` - Sony ELF kernel.elf format support, repacking as ELF for older Sony devices
* `mkmtkhdr` - MTK device boot image section headers support
* `futility` + `chromeos` test keys directory - Google ChromeOS signature support
* `BootSignature_Android.jar` + `avb` keys directory - Google Android Verified Boot (AVB) signature support
* `blobpack` - Asus SignBlob signature support
* `dhtbsign` - Samsung/Spreadtrum DHTB signature support
* `rkcrc` - Rockchip KRNL ramdisk image support
