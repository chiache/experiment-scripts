#!/bin/bash

if [ "$1" = "-gdb" ]; then
	GDB="-s"
fi

if [ "$1" = "-serial" ]; then
	[ -f console.log ] && mv console.log console-last.log
	SERIAL_APPEND="console=\"ttyS0,115200\""
	SERIAL="-serial file:console.log"
fi

CONSOLE="console=tty1 highres=off $SERIAL_APPEND"
ROOT="root=/dev/hda rw --no-log"

set -x
 
qemu-system-x86_64 $GDB -smb 4 -hda disk.img -kernel arch/x86/boot/bzImage \
	-initrd initrd.img \
	-append "$CONSOLE $ROOT" \
	-curses -snapshot $SERIAL
