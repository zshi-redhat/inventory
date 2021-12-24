#!/bin/bash

set +x
set +e

# Color definition
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

TX_MIN_RATE="true"
DEVICE=""
NUMVFS=2

echo_info () {
	echo -e "${GREEN} > [INFO] $* ${NC}"
}
echo_data () {
        while read -r line; do
                echo -e "${CYAN} > [DATA] "$line" ${NC}"
        done <<< $*
}
echo_err () {
	echo -e "${RED} > [ERR] $* ${NC}"
}

echo_and_eval () {
	echo_info "$*"
	eval "$@"
	if [ $? != 0 ]; then
		echo_err "Failed"
		exit 1
	else
		echo_info "Succeeded"
	fi
	echo
}

usage () {
	echo "Usage: $0 [ -h ] [-d INTERFACE] [ -s tx-min ]" 1>&2 
}

while getopts ":d:s:h" option; do
	case $option in
		h) # display Help
			usage
			exit 0
			;;
		d) # device to test
			DEVICE=${OPTARG}
			;;
		s) # skip
			SKIP=${OPTARG}
			if [ "$SKIP" = "tx-min" ]; then
				TX_MIN_RATE="false"
			fi
			;;
		:) # argument omitted
			echo_err "-${OPTARG} requires an argument."
			usage
			exit 1
			;;
	esac
done

if [ "$DEVICE" = "" ];then
	echo_err "-d is required"
	usage
	exit 1
fi

DRIVER=$(ethtool -i $DEVICE | grep driver | awk -F' ' '{print $2}')
DEVICE_PCI=$(ethtool -i $DEVICE | grep bus-info | awk -F' ' '{print $2}')
SHORT_PCI=$(ethtool -i $DEVICE | grep bus-info | awk -F' ' '{print $2}' | awk -F':' '{print $2":"$3}')
PCI_INFO=$(lspci | grep $SHORT_PCI)
DEVICE_INFO=$(lspci -v -nn -mm -s $DEVICE_PCI)
TOTALVFS=$(cat /sys/bus/pci/devices/$DEVICE_PCI/sriov_totalvfs)

dump-device-data () {
	echo
	echo_data "Hostname: `hostname`"
	echo_data "Name: $DEVICE"
	echo_data "Driver: $DRIVER"
	echo_data "PCI: $DEVICE_PCI"
	echo_data "Total VFs: $TOTALVFS"
	echo_data "$DEVICE_INFO"
	echo_data "$PCI_INFO"
	echo
}

dump-vf-data () {
	echo
	echo_data "Name: ${DEVICE}v0"
	echo_data "Driver: $VF_DRIVER"
	echo_data "PCI: $VF_DEVICE_PCI"
	echo_data "$VF_DEVICE_INFO"
	echo_data "$VF_PCI_INFO"
	echo
}

dump-device-data

# Create numvfs
echo_and_eval "echo 0 > /sys/bus/pci/devices/$DEVICE_PCI/sriov_numvfs"
echo_and_eval "echo $NUMVFS > /sys/bus/pci/devices/$DEVICE_PCI/sriov_numvfs"
sleep 3

echo_and_eval "ip link show $DEVICE"
echo_and_eval "ip link show ${DEVICE}v0"
echo_and_eval "ip link show ${DEVICE}v1"

VF_DRIVER=$(ethtool -i ${DEVICE}v0 | grep driver | awk -F' ' '{print $2}')
VF_DEVICE_PCI=$(ethtool -i ${DEVICE}v0 | grep bus-info | awk -F' ' '{print $2}')
VF_SHORT_PCI=$(ethtool -i ${DEVICE}v0 | grep bus-info | awk -F' ' '{print $2}' | awk -F':' '{print $2":"$3}')
VF_PCI_INFO=$(lspci | grep $VF_SHORT_PCI)
VF_DEVICE_INFO=$(lspci -v -nn -mm -s $VF_DEVICE_PCI)

dump-vf-data

# Configure VF0 effective and admin MAC
echo_and_eval "ip link set $DEVICE vf 0 mac 00:11:22:33:44:55"
echo_and_eval "ip link set dev ${DEVICE}v0 address 00:11:22:33:44:55"
echo_and_eval "ip link show $DEVICE"
echo_and_eval "ip link show ${DEVICE}v0"

# Configure VF0 attrs
echo_and_eval "ip link set $DEVICE vf 0 vlan 100 qos 1"
echo_and_eval "ip link set $DEVICE vf 0 spoofchk off"
echo_and_eval "ip link set $DEVICE vf 0 state enable"
echo_and_eval "ip link set $DEVICE vf 0 trust on"
echo_and_eval "ip link set $DEVICE vf 0 max_tx_rate 1000"
if [ "$TX_MIN_RATE" = "true" ];then
	echo_and_eval "ip link set $DEVICE vf 0 min_tx_rate 100"
fi
echo_and_eval "ip link show $DEVICE"

echo_and_eval "ip link set $DEVICE vf 0 vlan 0 qos 0"
echo_and_eval "ip link set $DEVICE vf 0 spoofchk on"
echo_and_eval "ip link set $DEVICE vf 0 state disable"
echo_and_eval "ip link set $DEVICE vf 0 trust off"
echo_and_eval "ip link set $DEVICE vf 0 max_tx_rate 0"
if [ "$TX_MIN_RATE" = "true" ];then
	echo_and_eval "ip link set $DEVICE vf 0 min_tx_rate 0"
fi
echo_and_eval "ip link show $DEVICE"

# Reset numvfs
echo_and_eval "echo 0 > /sys/bus/pci/devices/$DEVICE_PCI/sriov_numvfs"
echo_and_eval "ip link show $DEVICE"
