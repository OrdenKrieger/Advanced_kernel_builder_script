# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=REPLACE_KERNEL_STRING
do.devicecheck=REPLACE_DEVICECHECK
do.modules=REPLACE_MODULES
do.cleanup=REPLACE_CLEANUP
do.cleanuponabort=REPLACE_ONABORT_CLEANUP
device.name1=REPLACE_NAME1
device.name2=REPLACE_NAME2
device.name3=REPLACE_NAME3
device.name4=REPLACE_NAME4
device.name5=REPLACE_NAME5
supported.versions=
'; } # end properties

# shell variables
block=REPLACE_BLOCK;
is_slot_device=REPLACE_IS_SLOT_DEVICE;
ramdisk_compression=REPLACE_RAMDISK_COMPRESSION;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod -R 755 $ramdisk/sbin;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

write_boot;

## end install

