#!/bin/bash

mcu="cortex-m4"	# "cortex-m0"
arch="armv7-m"	# "armv6-m" for Cortex-M0/+

sources=`ls *.c`

mkdir -p obj
rm obj/*

objs=""
count=0
for s in $sources; do
	f=$(basename $s | sed -E 's/(^.*)\.[a-zA-Z]+$/\1/')
	o="obj/$count-$f.$arch.o"
	count=$(($count + 1))

	echo "Building $s => $o"
	arm-none-eabi-gcc -Wall -Wno-switch -nostdlib -nodefaultlibs -fno-exceptions \
		-g -Os -mthumb -mcpu=$mcu -Wno-attributes -mfloat-abi=hard -mfpu=fpv4-sp-d16\
		--function-sections \
		-I . \
		-o $o -x c -c $s

		if [ $? -ne 0 ]; then
			echo "Compiling failed."
			exit -1
		fi
	objs="$objs $o"
done

echo Linking...
# use single-object pre-link
arm-none-eabi-ld -o obj/zlib.$arch.o -r $objs

if [ $? -ne 0 ]; then
	echo "Linking failed."
	exit -1
fi

echo Archiving...
arm-none-eabi-ar r obj/libz.a obj/zlib.$arch.o

if [ $? -ne 0 ]; then
	echo "Archiving failed."
	exit -1
fi

echo "Build succeeded."

# link to final firmware with -Wl,--gc-sections

exit 0
