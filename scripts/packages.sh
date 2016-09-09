#!/bin/bash

SERVER=http://mirrordirector.raspbian.org/raspbian/
MNT_FOLDER=$1
APT_LIST_PATH=/var/lib/apt/lists/mirrordirector.raspbian.org_raspbian_dists_jessie_main_binary-armhf_Packages
PACKAGES_TO_INSTALL=( busybox libnl-route-3-200 hostapd udhcpd )

for (( i=0;i<${#PACKAGES_TO_INSTALL[@]};i++)); do
    BEGIN="Package: ${PACKAGES_TO_INSTALL[${i}]}"
    echo -----------------------
    sed -n -e "/$BEGIN$/,/Filename: / p" $MNT_FOLDER$APT_LIST_PATH
    PACKAGE_BLOB=$(echo "$a" | sed -n -e "/$BEGIN$/,/Filename: / p" $MNT_FOLDER$APT_LIST_PATH)    
    PACKAGE_PATH=$(echo "$a" | echo $PACKAGE_BLOB | sed '/Filename:/s/.*Filename: \([^ ][^ ]*\)[ ]*.*/\1/')
    wget -O "$MNT_FOLDER/temp/${PACKAGES_TO_INSTALL[${i}]}.deb" "$SERVER$PACKAGE_PATH"
done 

