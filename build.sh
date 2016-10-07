#!/bin/bash

echo "Input Model: D722, D724"
read model
echo "mrproper, clean, dtb or build"
read instruct
echo "compile: y/N"
read compile
echo "Do you want to repack? y/N"
read repack
echo "Do you you want to create a flashable zip? y/N"
read zip

if [ "$zip" = "y" ]
then
	echo "What version?"
	read ver
fi

if [ "$instruct" = "mrproper" ]
then

	make1="make mrproper"

if [ "$model" = "D722" ]
then
	make2="make jagnm_cyanogenmod_defconfig"
fi

if [ "$model" = "D724" ]
then
	make2="make jag3gds_cyanogenmod_defconfig"
fi

elif [ "$instruct" = "clean" ]
then

	make1="make clean"
	make2="make oldconfig"

elif [ "$instruct" = "build" ]
then

	make1="echo """
	make2="echo """

fi

if [ "$compile" = "y" ]
then

if [ -e "./arch/arm/boot/dt.img" ]; then
rm ./arch/arm/boot/dt.img
fi

if [ -e "./arch/arm/boot/msm8226-v1-jagnm.dtb" ]; then
rm ./arch/arm/boot/msm8226-v1-jagnm.dtb
rm ./arch/arm/boot/msm8226-v2-jagnm.dtb
fi

if [ -e "./arch/arm/boot/msm8226-jag3gds.dtb" ]; then
rm ./arch/arm/boot/msm8226-jag3gds.dtb
fi

	$make1 && $make2 && make -j5 && ./dtbToolCM -2 -s 2048 -p ./scripts/dtc/ -o ./arch/arm/boot/dt.img ./arch/arm/boot/

fi

if [ "$instruct" = "dtb" ]
then
	make dtbs && ./dtbToolCM -j5 -s 2048 -p ./scripts/dtc/ -o ./arch/arm/boot/dt.img ./arch/arm/boot/

fi

if [ ! -d "Output" ]; then
mkdir Output
fi

if [ "$repack" = "y" ]
then

echo "Copying files to respective folder"

		cd ./RAMDISK/$model/
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
		mv ./RAMDISK/$model/image-new_bumped.img ./Output/$model.img
fi

if [ "$zip" = "y" ]
then

	echo "Copying image to root of unzipped directory renaming it boot."

	cp ./Output/$model.img ./Output/BreadandButterKernel_CM/boot.img
	cd ./Output/BreadandButterKernel_CM

	echo "Changing the directory to root of BreadandButterKernel directory."

	echo "Creating flashable zip."

	zip -r BreadandButterKernel_CM13#$ver-$model.zip . -x ".*"

    echo "Moving zipped file to output folder."

    mv *.zip  ../
fi

