#!/bin/bash

echo "Export variables from config file"
source config
export $(cut -d= -f1 config| grep -v '^$\|^\s*\#' config)

echo "Create directory for config-drives for vm1 and vm2"
mkdir -p config-drives/$VM1_NAME-config config-drives/$VM2_NAME-config


echo "Download Ubuntu cloud image, if it doesn't exist"
wget -O /var/lib/libvirt/images/ubunut-server-16.04.qcow2 -nc https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img

echo "Create two disks from image"
cp /var/lib/libvirt/images/ubunut-server-16.04.qcow2 $VM1_HDD
cp /var/lib/libvirt/images/ubunut-server-16.04.qcow2 $VM2_HDD

echo "Create config drives"
mkisofs -o "$VM1_CONFIG_ISO" -V cidata -r -J --quiet config-drives/vm1-config
mkisofs -o "$VM2_CONFIG_ISO" -V cidata -r -J --quiet config-drives/vm2-config

echo "Generate MAC adress for external network"
export MAC_VM1_EXT=52:54:00:`(date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{6}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`




