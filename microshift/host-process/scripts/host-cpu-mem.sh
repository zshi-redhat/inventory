#!/bin/bash

if [ -z $1 ]; then
	datadir="data"
else
	datadir="$1"
fi

if [ ! -d $datadir ]; then
	mkdir -p $datadir
fi


while true; do
	data=$(ps faux --sort rss | grep 'openvsw' | grep 'ovs-vswitchd')
	data1=$(ps faux --sort rss | grep '/etc/openvswitch/conf.db' | grep 'ovsdb-server')
	while read -r line; do
		process="ovs-vswitchd"
		cpu=`echo $line | awk -F' ' '{print $3}'`
		mem=`echo $line | awk -F' ' '{print $6}'`

		if [ ! -e $datadir/$process-cpu ]; then
			touch $datadir/$process-cpu
		fi
		if [ ! -e $datadir/$process-mem ]; then
			touch $datadir/$process-mem
		fi
		echo $cpu  >> $datadir/$process-cpu
		echo $mem  >> $datadir/$process-mem
	done <<< $data
	while read -r line; do
		process="ovsdb-server"
		cpu=`echo $line | awk -F' ' '{print $3}'`
		mem=`echo $line | awk -F' ' '{print $6}'`

		if [ ! -e $datadir/$process-cpu ]; then
			touch $datadir/$process-cpu
		fi
		if [ ! -e $datadir/$process-mem ]; then
			touch $datadir/$process-mem
		fi
		echo $cpu  >> $datadir/$process-cpu
		echo $mem  >> $datadir/$process-mem
	done <<< $data1
done
