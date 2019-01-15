#!/bin/bash

# Inlcude config conditions
source config

# Reset layout if the build breaks or the user stop the script
function stop {
	  tput sgr0
}
trap stop EXIT

# Check if kernel source is present
if [ "$(ls -A $KERNEL_DIR/*)" ]; then
   echo -e "\E[1;32mKernel source is present"
   tput sgr0
else
   echo -e "\E[1;31mDownloading kernel source"
   tput sgr0
   git clone $KSOURCE_GIT $KERNEL_DIR
fi

# Clean up output?
if [ $OUTPUT_EMPTY_CHECK == 1 ]; then
if [ "$(ls -A $ZIP_MOVE/* 2>/dev/null)" ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mOutput folder contains older versions"
	echo -e ""
	read -p "Empty output folder? (y/n) " prompt
	tput sgr0
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
	rm $ZIP_MOVE/*.zip 2>/dev/null
	echo -e "\E[1;31mCleanup successful!"
	tput sgr0
else
	echo -e ""
fi
fi
fi

if [ $COLOR_BUILD_PROCESS == 1 ]; then
	echo -e $TERMINAL_BACKGROUND_COLOR
	echo -e $TERMINAL_TEXT_COLOR
fi

echo -e ""
echo -e ""
echo -e "|==|\e[1;31m$HEADLINE_TXT$TERMINAL_TEXT_COLOR|==|"
echo -e ""
echo -e "" 

# Cleanup kernel build/out folder
if [ "$(ls -A $OUT/* 2>/dev/null)" ]; then
rm -rf $OUT
fi

# Cleanup AnyKernel2 tmp files
if [ "$(ls -A $AnyKernel2_TMP/* 2>/dev/null)" ]; then
rm -rf $AnyKernel2_TMP
fi

# Vars
cd $KERNEL_DIR
export ARCH=$KERNEL_ARCH
export SUBARCH=$KERNEL_ARCH
export KBUILD_BUILD_USER=$BUILDER_NAME
export KBUILD_BUILD_HOST=$BUILD_HOST_NAME

# Build info 
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE="$TOOLCHAIN_DIR"
AKBS_VER="$BASE_VER$VER"
export LOCALVERSION=~`echo $AKBS_VER`
export LOCALVERSION=~`echo $AKBS_VER`
DEFCONFIG="$KERNEL_DEFCONFIG"
O_OUT="O=$OUT"
make $O_OUT $DEFCONFIG
make $O_OUT $THREAD
cd $BUILD_DIR

# Create AnyKernel2 structure
cp -rf $AnyKernel2 $AnyKernel2_TMP

AnyKernel2_REPLACE="$AnyKernel2_TMP/anykernel.sh"
sed -i "s:REPLACE_KERNEL_STRING:$AK_KERNEL_STRING:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_DEVICECHECK:$AK_DEVICECHECK:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_MODULES:$AK_MODULES:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_CLEANUP:$AK_CLEANUP:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_ONABORT_CLEANUP:$AK_CLEANUPONABORT:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_NAME1:$AK_NAME1:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_NAME2:$AK_NAME2:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_NAME3:$AK_NAME3:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_NAME4:$AK_NAME4:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_NAME5:$AK_NAME5:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_SUPPORTED_VERSIONS:$AK_SUPPORTED_VERSIONS:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_BLOCK:$AK_BLOCK:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_IS_SLOT_DEVICE:$AK_IS_SLOT_DEVICE:" $AnyKernel2_REPLACE
sed -i "s:REPLACE_RAMDISK_COMPRESSION:$AK_RAMDISK_COMPRESSION:" $AnyKernel2_REPLACE

# Add build modules to the zip
MODULES_DIR="$AnyKernel2_TMP/modules"
cp -vr $OUT/arch/$KERNEL_ARCH/boot/Image.gz-dtb $AnyKernel2_TMP/$KERNEL_IMAGE
find $OUT -name '*.ko' -exec cp -v {} $MODULES_DIR \;

# Make our zip
cd $AnyKernel2_TMP
AK_Name="$BASE_VER-$VER"
AK_DATE=`date +%m_%d_%Y`
zip -r9 $AK_Name-$AK_DATE.zip *

# Copy the zip to the output folder
if [ ! -d "$ZIP_MOVE" ]; then
mkdir $ZIP_MOVE
fi
mv $AnyKernel2_TMP/*.zip $ZIP_MOVE

# Check if a zip was created and the kernel image is included
if [ -e $AnyKernel2_TMP/$KERNEL_IMAGE ] &&  [ -e $ZIP_MOVE/*.zip ]; then
if [ $CLEAR_ON_SUCCESS == 1 ]; then
	echo -e '\0033\0143'
fi
if [ $OUTPUT_CLEAN_UP == 1 ]; then
rm -rf $OUT
rm -rf $AnyKernel2_TMP
fi
	echo -e "\E[1;32mThe kernel $KERNEL_IMAGE was created successful"
	echo -e "\E[1;32mThe $AK_Name-$AK_DATE.zip was created successful"
	echo -e ""
	echo -e "\E[1;32mYou can find the compiled file inside of $ZIP_MOVE"
	echo -e ""
	echo -e "\E[1;32mSuccess!"
	echo -e ""
	echo -e ""
	tput sgr0
elif [ ! -e $AnyKernel2_TMP/$KERNEL_IMAGE ] ||  [ -e $ZIP_MOVE/*.zip ]; then
	echo -e ""
	echo -e "\E[1;31mAn error with kernel appeared!"
	echo -e "\E[1;31mThere was no $KERNEL_IMAGE created by the build process!"
	echo -e "\E[1;31mCheck the the build history for errors and fix them in the kernel source."
	echo -e "\E[1;31mThe build process may have created a kernel.zip but this is corrupted."
	echo -e ""
	echo -e "\E[1;31mThe device won't boot if you flash it!"
	echo -e ""
	echo -e ""
	tput sgr0
else
	echo -e "\E[1;31mThere is no kernel.zip created by the build process!"
	echo -e "\E[1;31mCheck if lazyflasher is present and if the paths are set right in the build.sh."
	echo -e ""
	echo -e ""
	tput sgr0
fi
