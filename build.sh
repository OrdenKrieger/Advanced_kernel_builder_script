#!/bin/bash
# Kernel Details
VER="V1.1.4_axon7"
BASE_AK_VER="Radioactive"

# Paths (should be set as one of the first so that everything know where it belong to)
KERNEL_DIR="${HOME}/NucleaROM/kernel/zte/msm8996"
ZIP_MOVE="${HOME}/NucleaROM/releases"
ZIMAGE_DIR="${HOME}/NucleaROM/kernel/zte/msm8996/arch/arm64/boot"
MODULES_DIR="${HOME}/NucleaROM/lazyflasher/modules"
BUILD_DIR="${HOME}/NucleaROM"

# Check if lazyflasher is present
folder1="${HOME}/NucleaROM/lazyflasher/*.*"
if [ "$(ls -A $folder1)" ]; then
   echo -e "\E[1;32mLazyflasher is present"
   tput sgr0
else
   echo -e "\E[1;31mDownloading lazyflasher dependencie"
   tput sgr0
   git clone https://github.com/OrdenKrieger/lazyflasher.git $BUILD_DIR/lazyflasher
fi

# Check if kernel source is present
folder2="${HOME}/NucleaROM/kernel/zte/msm8996/*.*"
if [ "$(ls -A $folder2)" ]; then
   echo -e "\E[1;32mKernel source is present"
   tput sgr0
else
   echo -e "\E[1;31mDownloading kernel source"
   tput sgr0
   git clone https://github.com/OrdenKrieger/android_kernel_zte_msm8996.git $BUILD_DIR/kernel/zte/msm8996
fi

# Cleanup remains of last builds
git clean -d -f -x
cd $BUILD_DIR/lazyflasher
git clean -d -f -x
cd $KERNEL_DIR

# Vars
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=ordenkrieger
export KBUILD_BUILD_HOST=NuclearPowerPlant

# Build info 
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE="${HOME}/NucleaROM/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
DEFCONFIG="radioactive_defconfig"
make $DEFCONFIG
make $THREAD

# Make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb $BUILD_DIR/lazyflasher/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd $BUILD_DIR/lazyflasher
make VERSION=$VER NAME=$BASE_AK_VER

# Cleanup remains of the kernel build (drivers etc.)
cd $KERNEL_DIR
git clean -d -f -x > /dev/null 2>&1

# Copy the ZIP to the Output
cd $BUILD_DIR/lazyflasher
mv $BUILD_DIR/lazyflasher/*.zip $ZIP_MOVE
mv $BUILD_DIR/lazyflasher/*.sha1 $ZIP_MOVE

# Message if success or fail
file1="${HOME}/NucleaROM/releases/*.zip"
file2="${HOME}/NucleaROM/lazyflasher/zImage"
if [ -e $file1 ] &&  [ -e $file2 ]; then
   echo -e ""
   echo -e ""
   echo -e "\E[1;32mSuccess!"
   echo -e "\E[1;32mYou can find the compiled kernel inside of $ZIP_MOVE"
   echo -e ""
   echo -e ""
   tput sgr0
else
   echo -e ""
   echo -e ""
   echo -e "\E[1;31mThere is no *.zip or zImage"
   echo -e "\E[1;31mSomething must be gone wrong :("
   echo -e "\E[1;31mCheck paths and kernel configuration and repeat the process"
   echo -e "\E[1;31mCheck also if the kernel source and lazyflasher are in the right folder because the script only check if the folders are empty"
   echo -e ""
   echo -e ""
   tput sgr0
fi

# Cleanup remains of the *.zip build
git clean -d -f -x > /dev/null 2>&1

# Back to the roots
cd $KERNEL_DIR
