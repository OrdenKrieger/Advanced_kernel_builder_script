#!/bin/bash
rm .version
make mrproper
make clean
# Kernel Details
VER="_V1.2.0_axon7"
BASE_AK_VER="Radioactive"

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=ordenkrieger
export KBUILD_BUILD_HOST=NuclearPowerPlant

#paths
KERNEL_DIR="/home/ordenkrieger/NucleaROM/kernel/zte/msm8996"
ZIP_MOVE="${HOME}/NucleaROM/releases"
ZIMAGE_DIR="/home/ordenkrieger/NucleaROM/kernel/zte/msm8996/arch/arm64/boot"
MODULES_DIR="${HOME}/NucleaROM/lazyflasher/modules"

#build info 
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE=${HOME}/NucleaROM/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
DEFCONFIG="radioactive_defconfig"
make $DEFCONFIG
make $THREAD

#make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb ~/NucleaROM/lazyflasher/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd ~/NucleaROM/lazyflasher
make VERSION=$VER NAME=$BASE_AK_VER
cd $KERNEL_DIR
