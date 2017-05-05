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
folder1="$LAZYFLASHER_DIR/*.*"
if [ "$(ls -A $folder1)" ]; then
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
folder2="$KERNEL_DIR/*.*"
if [ "$(ls -A $folder2)" ]; then
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
output1="$ZIP_MOVE/*.zip"
output2="$ZIP_MOVE/*.sha1"
if [ -e $output1 ] &&  [ -e $output2 ]; then # Both must be there otherwise they will be ignored
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mOutput folder contains older versions"
	echo -e ""
	read -p "Empty output folder? (y/n) " prompt
	tput sgr0
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
	rm $ZIP_MOVE/*.zip
	rm $ZIP_MOVE/*.sha1
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
make $DEFCONFIG
make $THREAD

# Make our zips
cp -vr $ZIMAGE_DIR/Image.gz-dtb $LAZYFLASHER_DIR/zImage
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd $LAZYFLASHER_DIR
make VERSION=$VER NAME=$BASE_VER

if [ $COLOR_TXT == 1 ]; then
	tput sgr0
fi

# Cleanup remains of the kernel build (drivers etc.)
cd $KERNEL_DIR
git clean -d -f -x > /dev/null 2>&1

# Copy the ZIP to the Output
cd $LAZYFLASHER_DIR
mv $LAZYFLASHER_DIR/*.zip $ZIP_MOVE
mv $LAZYFLASHER_DIR/*.sha1 $ZIP_MOVE

# Check if a zImage was created
# This appears if an error happens while building the kernel/zImage
file1="$LAZYFLASHER_DIR/zImage"
fix_done="$BUILD_DIR/.tmp/fix_done.tmp"
fix_user_standalone="$BUILD_DIR/.tmp/fix_user_standalone.tmp"
if [ ! -e $file1 ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mThere was no zImage created by the build process!"
if [ ! -f $fix_done ] &&  [ ! -f $fix_user_standalone ]; then
if [ $KERNEL_ARCH == arm64 ] ||  [ $KERNEL_ARCH == arm ]; then
if [ $STANDALONE_FIX == 1 ]; then
	echo -e ""
	echo -e ""
	echo -e "\E[1;31mDid you already applied a commit for the standalone compilation?"
	echo -e ""
	read -p "Apply a standalone compilation patch for your arch=$KERNEL_ARCH? (y/n) " prompt
	tput sgr0
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
if [ $KERNEL_ARCH == arm64 ]; then
	cp /home/ordenkrieger/Advanced_kernel_builder_script/patches/android-3.18.patch $KERNEL_DIR
	cd $KERNEL_DIR
	git apply android-3.18.patch
	rm android-3.18.patch
	mkdir -p $BUILD_DIR/.tmp &&  touch fix_done.tmp 
	echo "This file tells the script that the standalone fix was already applied but apparently didn't helped. :(" >> $fix_done
	git status
	git add .
	exec $0
	exit 1
	break
elif [ $KERNEL_ARCH == arm ]; then 
	cp /home/ordenkrieger/Advanced_kernel_builder_script/patches/android-3.4.patch $KERNEL_DIR
	cd $KERNEL_DIR
	git apply android-3.4.patch
	rm android-3.4.patch
	mkdir -p $BUILD_DIR/.tmp &&  touch fix_done.tmp
	echo "This file tells the script that the standalone compilation fix was already applied but apparently didn't helped. :(" >> $fix_done
	git status
	git add .
	exec $0
	exit 1
	break
else
	echo -e "\E[1;31mSorry but this script doesn't support a fix for your kernel architecture!"
	tput sgr0
fi
elif [[ $prompt == "n" || $prompt == "N" || $prompt == "no" || $prompt == "No" ]]; then
	mkdir -p $BUILD_DIR/.tmp &&  touch fix_user_standalone.tmp 
	echo "This file tells the script that the standalone compilation fix is not needed." >> $fix_user_standalone
fi
fi
fi
fi
if [ -f $fix_done ] &&  [ ! -e $file1 ]; then
	echo -e "\E[1;31mIt looks like the standalone fix is already applied. Maybe you only need to fix smaller errors?"
fi
	echo -e "\E[1;31mCheck the the build history for errors and fix them in the kernel source."
	tput sgr0
fi

# Check if lazyflasher made a .zip and this is working right
file2="$ZIP_MOVE/*.zip"
if [ -e $file1 ] &&  [ -e $file2 ]; then
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

# Cleanup remains of the *.zip build
git clean -d -f -x > /dev/null 2>&1

# Back to the roots
cd $BUILD_DIR
