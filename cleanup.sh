#!/bin/sh
virsh net-destroy external
virsh net-undefine external
virsh destroy vm1
virsh undefine vm1


