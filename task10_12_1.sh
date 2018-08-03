#!/bin/bash

echo "Export variables from config file"
source config
export $(cut -d= -f1 config| grep -v '^$\|^\s*\#' config)
envsubst < config > work_config
source work_config
export $(cut -d= -f1 work_config| grep -v '^$\|^\s*\#' work_config)

echo "Create directory for config-drives for vm1"
mkdir -p config-drives/$VM1_NAME-config

echo "Download Ubuntu cloud image, if it doesn't exist"
wget -O /var/lib/libvirt/images/ubuntu-server-16.04.qcow2 -nc $VM_BASE_IMAGE

echo "Growing image size"
cp /var/lib/libvirt/images/ubuntu-server-16.04.qcow2 /tmp/img.img
qemu-img resize /tmp/img.img +10G
cp /tmp/img.img $VM1_HDD
virt-resize --expand /dev/sda1 /tmp/img.img $VM1_HDD
rm /tmp/img.img

echo "Generate MAC adress for external network"
export MAC_VM1_EXT=52:54:00:`(date; cat /proc/interrupts) | md5sum | sed -r 's/^(.{6}).*$/\1/; s/([0-9a-f]{2})/\1:/g; s/:$//;'`

echo "Check if SSH key exists"
if [ -e $SSH_PUB_KEY ]
then 
	echo "SSH key exists"
else
	echo "SSH key doesn't exists"
        exit 1
fi

echo "Create directory for libvirt network XMLs"
mkdir -p networks/

echo "Create external.xml from template"
envsubst < templates/external_template.xml > networks/external.xml

echo "Create network from XML template"
virsh net-define networks/external.xml

echo "Start network"
virsh net-start external

echo "Create meta-data for VMs"
envsubst < templates/meta-data_VM1_template > config-drives/vm1-config/meta-data

echo "Create user-data for VM1"
envsubst < templates/user-data_VM1_template > config-drives/vm1-config/user-data
cat <<EOT >> config-drives/vm1-config/user-data
ssh_authorized_keys:
 - $(cat $SSH_PUB_KEY)
EOT

echo "Create VM1.xml from template"
envsubst < templates/vm1_template.xml > vm1.xml

echo "Create config drives"
mkisofs -o "$VM1_CONFIG_ISO" -V cidata -r -J --quiet config-drives/vm1-config

echo "Define VM from XML template"
virsh define vm1.xml


echo "Start VM"
virsh start vm1
