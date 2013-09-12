#!/bin/sh
# build.sh

usage()
{
	echo "usage: `basename $0`[-b] [-c] [-i]"
	echo "-b: update build.xml"
	echo "-c: delete bin folder..."
	echo "-i: install the builded apk directly"
}

DEVICE_SERIAL=$
PROJECT_NAME="iZJU"

check_device()
{
	echo checking device...
	echo 

	DEVICE_SERIAL=$(adb devices | sed -n '2p' | sed 's/[\t]*device//g') 

	if [ -z "$DEVICE_SERIAL" ]; then
		echo $DEVICE_SERIAL
		echo "Error!! No device"
		exit
	fi

	if [ "???" = "${DEVICE_SERIAL:0:3}" ]; then
		echo $DEVICE_SERIAL	
		echo Unkown device
		exit
	fi
}

install() 
{
	echo installing the following device
	echo -e "\tDevice serial:" $DEVICE_SERIAL
	echo

	echo "Uninstalling origin "$PROJECT_NAME".apk..."
	echo -e "\t\c"
	adb -s $DEVICE_SERIAL uninstall org.izju
	echo 

	echo "Installing "$PROJECT_NAME".apk..."
	cd bin/
	SURFIX="-debug.apk"
	APKNAME=$PROJECT_NAME$SURFIX
	adb -s $DEVICE_SERIAL install $APKNAME
	cd ..
	echo 

	echo "starting "$PROJECT_NAME"..."
	adb -s $DEVICE_SERIAL shell am start -n org.izju/.activity.SplashActivity
	echo
}

if [ $# -gt 3 ]; then
	usage
	exit 1
fi

OPT=$

while [ $# -ne 0 ] #while there are still arguments
do
	case $1 in
		-b)
		echo "updating build.xml"
		android update project -t android-15 -p .
		;;
		-c) 
		echo "Deleting bin folder..."
		rm -rf bin
		echo 
		;;
		-i)
		echo "Install apk directly..."
		check_device
		install
		exit
		;;

		*)
		usage
		exit 1
		;;
	esac
	shift
done

ant debug
echo 
echo

check_device
install
