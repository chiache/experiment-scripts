#!/bin/bash

while [ "$1" != "" ]; do

if [ "$1" = "-gdb" ]; then
	GDB="-s"
	shift
fi

if [ "$1" = "-net" ]; then
	NET_APPEND="net.ifnames=0 biosdevname=0"
	NET="-net nic,model=virtio -net user"
	shift
fi

if [ "$1" = "-serial" ]; then
	[ -f console.log ] && mv console.log console-last.log
	SERIAL_APPEND="console=\"ttyS0,115200\""
	SERIAL="-serial file:console.log"
	shift
fi

if [ "$1" = "-share" ]; then
	SHARE_FS="-virtfs local,path=$(readlink -f $2),security_model=mapped,mount_tag=host-share"
	CMD="$CMD mkdir -p /mnt/host-share; mount -t 9p -o trans=virtio,version=9p2000.L host-share /mnt/host-share;"
	shift
	shift
fi

if [ "$1" = "-cmd" ]; then
	CMD="$CMD $2;"
	shift
	shift
fi

done

CONSOLE="console=tty1 highres=off $SERIAL_APPEND"
ROOT="root=/dev/hda rw --no-log"
NCPUS=`grep -c ^processor /proc/cpuinfo`

set -x
 
qemu-system-x86_64 $GDB -smp $NCPUS -hda disk.img -kernel arch/x86/boot/bzImage \
	-initrd initrd.img \
	-append "$CONSOLE $ROOT $NET_APPEND commands=\"$CMD\"" \
	-curses -snapshot $NET $SHARE_FS $SERIAL
