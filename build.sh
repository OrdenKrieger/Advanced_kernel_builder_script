#!/bin/bash
#########################################################################################################################
#########################################################################################################################
# Values set by config
source config
#########################################################################################################################
#########################################################################################################################

# Reset layout if the build breaks or the user stop the script
function stop {
	  tput sgr0
}
trap stop EXIT

# Check if lazyflasher is present
if [ "$(ls -A $LAZYFLASHER_DIR/*)" ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;32mLazyflasher is present"
	tput sgr0
else
   	echo -e "\E[1;31mDownloading lazyflasher dependencie"
   	tput sgr0
   	git clone $LSOURCE_GIT $LAZYFLASHER_DIR
fi

# Check if kernel source is present
if [ "$(ls -A $KERNEL_DIR/*)" ]; then
   echo -e "\E[1;32mKernel source is present"
   tput sgr0
else
   echo -e "\E[1;31mDownloading kernel source"
   tput sgr0
   git clone $KSOURCE_GIT $KERNEL_DIR
fi

# Cleanup remains of last builds
cd $KERNEL_DIR # It's more safe to move first here. We don't want to clean any other git folder
git clean -d -f -x > /dev/null 2>&1
cd $LAZYFLASHER_DIR
git clean -d -f -x > /dev/null 2>&1
cd $KERNEL_DIR

# Empty output?
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
	rm $ZIP_MOVE/*.sha1 2>/dev/null
	echo -e "\E[1;31mCleanup successful!"
	tput sgr0
else
	echo -e ""
fi
fi
fi

echo -e ""
echo -e ""
echo -e "\e[1;4m$HEADLINE_TXT"
echo -e ""
echo -e "" 
tput sgr0

if [ $COLOR_TXT == 1 ]; then
	echo -e "\e[43m"
	echo -e "\e[30m"
fi

# Cleanup kernel build/out folder
if [ "$(ls -A $OUT/* 2>/dev/null)" ]; then
rm -rf $OUT/*
fi

# Vars
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

# Make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb $LAZYFLASHER_DIR/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd $LAZYFLASHER_DIR
make VERSION=$VER NAME=$BASE_VER

if [ $COLOR_TXT == 1 ]; then
	tput sgr0
fi

# Copy the zip to the output folder
if [ ! -d "$ZIP_MOVE" ]; then
mkdir $ZIP_MOVE
fi
cd $LAZYFLASHER_DIR
mv $LAZYFLASHER_DIR/*.zip $ZIP_MOVE
mv $LAZYFLASHER_DIR/*.sha1 $ZIP_MOVE

# Report if zImage was created
if [ ! -e $LAZYFLASHER_DIR/zImage ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mThere was no zImage created by the build process!"
	echo -e "\E[1;31mCheck the the build history for errors and fix them in the kernel source."
	tput sgr0
fi

# Check if a zip was created and the zImage is included
if [ -e $LAZYFLASHER_DIR/zImage ] &&  [ -e $ZIP_MOVE/*.zip ]; then
if [ $CLEAR_ON_SUCCESS == 1 ]; then
	echo -e '\0033\0143'
fi
	echo -e "\E[1;32mThe zImage of the kernel was created successful"
	echo -e "\E[1;32mThe $BASE_VER-$VER.zip was created successful"
	echo -e ""
	echo -e "\E[1;32mYou can find the compiled file inside of $ZIP_MOVE"
	echo -e ""
	echo -e "\E[1;32mSuccess!"
	echo -e ""
	echo -e ""
	tput sgr0
elif [ ! -e $file1 ] ||  [ -e "$file2" ]; then
	echo -e ""
	echo -e "\E[1;31mAn error with the zImage appeared!" 
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
