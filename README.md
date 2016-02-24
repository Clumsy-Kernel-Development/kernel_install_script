# kernel_install_script
A kernel install script that can be executed in aroma during a ROM installation.

# Running this script in your ROM Aroma install
1. Put your moudles, dt.img and zImage in the correct directory
2. put kernel directory in the root of your rom zip
3. Add these lines to the end of your ROM installation
	- package_extract_dir("kernel", "/tmp/kernel");
	- set_perm(0, 0, 0755, "/tmp/kernel/installKernel.sh");
	- run_program("/tmp/kernel/installKernel.sh");
	
# File Tree
+-- kernel
|    +-- ClumsyKernelTweaks             # setAddress source files
|        +-- Clumsy_Kernel_Tweaks.apk   #Put this apk here
|    +-- dt                         	# Made when compile has been executed
|        +-- dt.img             
|    +-- modules                     	# Put all your .ko moudles in this directory
|        +-- Multiple .ko moudles
|    +-- tools                     		# Tools used to pack and unpack boot.img
|        +-- bin                 	
|			+-- busybox
|			+-- file
|			+-- lz4
|			+-- magic
|			+-- mkbootfs
|			+-- mkbootimg
|			+-- unpackbootimg
|			+-- xz
|        +-- unpackimg.sh 
|        +-- repackimg.sh 
|    +-- zImage                     	# Put your zImage here
|        +-- zImage
|    +-- installKernel.sh               # Install script