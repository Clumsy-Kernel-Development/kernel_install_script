#!/sbin/sh
# AIK-mobile/unpackimg: split image and unpack ramdisk
# osm0sis @ xda-developers
dir=$(dirname $0)

case $0 in
  /system/bin/sh|sh)
    echo "Please run without using the source command.";
    echo "Example: sh ./unpackimg.sh boot.img";
    return 1;;
esac;

cleanup() { rm -rf ramdisk split_img *new.*; }
abort() { cd "$dir"; echo "Error!"; }

if [ ! "$1" -o ! -f "$1" ]; then
  echo "No image file supplied.";
  abort;
  return 1;
fi;

case $1 in
  *\ *)
    echo "Filename contains spaces.";
    abort;
    return 1;;
esac;

bin="$dir/bin";
bb="$bin/busybox";
chmod -R 755 "$bin" "$dir"/*.sh;
chmod 644 "$bin/magic";
cd "$dir";

if [ ! -f $bb ]; then
  bb=busybox;
fi;

echo "Android Image Kitchen - UnpackImg Script";
echo "by osm0sis @ xda-developers";

file=`$bb basename "$1"`;
echo "Supplied image: $file";

if [ -d split_img -o -d ramdisk ]; then
  echo "Removing old work folders and files...";
  cleanup;
fi;

echo "Setting up work folders...";
mkdir split_img ramdisk;

echo 'Splitting image to "split_img/"...';
$bin/unpackbootimg -i "$1" -o split_img;
if [ $? != "0" ]; then
  cleanup;
  abort;
  return 1;
fi;

cd split_img;
$bin/file -m $bin/magic *-ramdisk.gz | $bb cut -d: -f2 | $bb cut -d" " -f2 > "$file-ramdiskcomp";
ramdiskcomp=`cat *-ramdiskcomp`;
unpackcmd="$bb $ramdiskcomp -dc";
compext=$ramdiskcomp;
case $ramdiskcomp in
  gzip) compext=gz;;
  lzop) compext=lzo;;
  xz) ;;
  lzma) ;;
  bzip2) compext=bz2;;
  lz4) unpackcmd="$bin/lz4 -dq"; extra="stdout";;
  *) compext="";;
esac;
if [ "$compext" ]; then
  compext=.$compext;
fi;
mv "$file-ramdisk.gz" "$file-ramdisk.cpio$compext";
cd ..;

echo 'Unpacking ramdisk to "ramdisk/"...';
cd ramdisk;
echo "Compression used: $ramdiskcomp";
if [ ! "$compext" ]; then
  abort;
  return 1;
fi;
$unpackcmd "../split_img/$file-ramdisk.cpio$compext" $extra | $bb cpio -i;
if [ $? != "0" ]; then
  abort;
  return 1;
fi;
cd ..;

echo "Done!";
return 0;

