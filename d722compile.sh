#!/bin/bash

make1="make mrproper"

make2="make jagnm_cyanogenmod_defconfig"

if [ -e "./arch/arm/boot/dt.img" ]; then
rm ./arch/arm/boot/dt.img
fi

if [ -e "./arch/arm/boot/msm8226-v1-jagnm.dtb" ]; then
rm ./arch/arm/boot/msm8226-v1-jagnm.dtb
rm ./arch/arm/boot/msm8226-v2-jagnm.dtb
fi

$make1 && $make2 && make -j5 && ./dtbToolCM -2 -s 2048 -p ./scripts/dtc/ -o ./arch/arm/boot/dt.img ./arch/arm/boot/

if [ ! -d "Output" ]; then
mkdir Output
fi

echo "Copying files to respective folder"

		cd ./RAMDISK/D722/
		./cleanup.sh
		./unpackimg.sh boot.img
		cp ../boot.img-ramdiskcomp ./split_img/boot.img-ramdiskcomp
		cp ../../arch/arm/boot/zImage ./split_img/boot.img-zImage
		cp ../../arch/arm/boot/dt.img ./split_img/boot.img-dtb
		echo "Repacking Kernel"
		./repackimg.sh
		echo "Signing Kernel"
		./bump.py image-new.img
		cd ../../
		echo "Moving Kernel to output folder"
		mv ./RAMDISK/D722/image-new_bumped.img ./Output/D722.img

