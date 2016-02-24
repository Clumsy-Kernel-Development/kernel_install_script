#!/sbin/sh

# Kernel install shell script
# Made by ~clumsy~  using AIK from osm0sis

# Location of the boot partition of the device
bootPartition=/dev/block/platform/msm_sdcc.1/by-name/boot
# The current DIR of the script
dir=$(dirname $0)
# Location of the tools
tools=$dir/tools
# Location of bin
bin=$tools/bin
# Location of busybox binary
busybox=$bin/busybox
# Location of the modules
modules=$dir/modules
# Location of the Kernel App
app=$dir/ClumsyKernelTweaks
# Location of log file, if you don't want a log just set it to /dev/null
logFile=/sdcard/KernelInstall.log

rm $logFile > /dev/null
touch $logFile > /dev/null

# Log Function will log to a log file
# in - Strings
log(){

	if [ "$@" ]
	then
		echo "$@" >> $logFile
		echo " " >> $logFile
	fi
}


# Mount System
log "--> Mounting System"
$busybox mount "/system" >> $logFile

#Set Permissions
log "--> Setting the permissions of tools"
chmod 0755 $tools/*.sh >> $logFile
chmod 0755 $busybox >> $logFile

# Get current boot
log "--> Getting the current boot image from $bootPartition"
$busybox dd if=$bootPartition of=$tools/stockboot.img >> $logFile

#Split Image
if [ -f $tools/stockboot.img ]
then
	log "--> Unpacking $tools/stockboot.img"
	$tools/unpackimg.sh $tools/stockboot.img >> $logFile
else
	log "$tools/stockboot.img does not exist, something must of went wrong dumping the current $bootPartition/boot.img on the device"
fi

# Move zImage
if [ -f $dir/zImage/zImage ]
then
	log "--> Moving zImage"
	$busybox cp $dir/zImage/zImage $tools/split_img/stockboot.img-zImage >> $logFile
else
	log "--> zImage does not exist"

fi 

# Move dt.img
if [ -f $dir/dt/dt.img ]
then
	log "--> Moving dt.img"
	$busybox cp $dir/dt/dt.img $tools/split_img/stockboot.img-dtb >> $logFile
else
	log "--> dt.img does not exist"
fi

# Making new boot image
if [ -d $tools/split_img ]
then
	log "--> Repacking the boot.img"
	$tools/repackimg.sh >> $logFile
else
	log "--> $tools/split_img directory does not exists, so new boot.img can not be made"
fi

# Flash new boot image
if [ -f $tools/image-new.img ]
then
	log "--> Flashing new boot.img"
	$busybox dd if=$tools/image-new.img of=$bootPartition >> $logFile
else
	log "--> $tools/image-new.img does not exist, so new boot.img can't not be flashed to $bootPartition"
fi

# Install modules
if [ -d $modules ]
then
	log "--> Installing Modules"
	$busybox cp -f $modules/*.ko /system/lib/modules/. >> $logFile
	
	# Set the permissions of the modules
	log "--> Setting the permissions of the modules"
	chmod 0644 /system/lib/modules/*.ko >> $logFile
else
	log "--> $modules does not exist, so the new modules can not unpacked into /system/lib/modules/"
fi

# Install the app
if [ -d $app  ]
then
	log "--> Installing Clumsy Kernel Tweak App"
	$busybox cp -rf $app /system/app/ >> $logFile
else
	log "--> $app does not exists, so it will not be installed"
fi

# Unmount System
log "--> Unmounting the System"
$busybox umount "/system" >> $logFile
