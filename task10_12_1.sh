#!/bin/bash

echo "Export variables from config file"
source config
export $(cut -d= -f1 config| grep -v '^$\|^\s*\#' config)

echo "Create directory for config-drives for vm1 and vm2"
mkdir -p config-drives/$VM1_NAME-config config-drives/$VM2_NAME-config



