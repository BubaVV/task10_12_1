#!/bin/bash

echo "Export variables from config file"
source config
export $(cut -d= -f1 config| grep -v '^$\|^\s*\#' config)
envsubst < config > work_config
source work_config
export $(cut -d= -f1 work_config| grep -v '^$\|^\s*\#' work_config)


echo "Create directory for config-drives for vm1 and vm2"
mkdir -p config-drives/$VM1_NAME-config config-drives/$VM2_NAME-config


echo "Download Ubuntu cloud image, if it doesn't exist"
wget -O /var/lib/libvirt/images/ubuntu-server-16.04.qcow2 -nc https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img

echo "Create two disks from image"
cp /var/lib/libvirt/images/ubuntu-server-16.04.qcow2 $VM1_HDD
cp /var/lib/libvirt/images/ubuntu-server-16.04.qcow2 $VM2_HDD

echo "Create config drives"
mkisofs -o "$VM1_CONFIG_ISO" -V cidata -r -J --quiet config-drives/vm1-config
mkisofs -o "$VM2_CONFIG_ISO" -V cidata -r -J --quiet config-drives/vm2-config

echo "Generate MAC adress for external network"
export MAC_VM1_EXT=52:54:00:`(date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{6}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`

echo "Generate SSH key for management VMs"
if [ -e $SSH_PUB_KEY ]
then 
	echo "SSH key exists"
else
	ssh-keygen -f $SSH_PUB_KEY -t rsa -b 4096
fi

echo "Create directory for libvirt network XMLs"
mkdir -p networks/

echo "Create external.xml from template"
envsubst < templates/external_template.xml > networks/external.xml

echo "Create internal.xml from template"
envsubst < templates/internal_template.xml > networks/internal.xml

echo "Create management.xml from template"
envsubst < templates/management_template.xml > networks/management.xml












