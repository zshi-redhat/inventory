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
	data=$(kubectl top pod  --containers -n openshift-ovn-kubernetes | grep 'ovn')
	while read -r line; do
		container=`echo $line | awk -F' ' '{print $2}'`
		cpu=`echo $line | awk -F' ' '{print $3}'`
		mem=`echo $line | awk -F' ' '{print $4}'`

		if [ ! -e $datadir/$container-cpu ]; then
			touch $datadir/$container-cpu
		fi
		if [ ! -e $datadir/$container-mem ]; then
			touch $datadir/$container-mem
		fi
		echo $cpu | sed 's/m//g' >> $datadir/$container-cpu
		echo $mem | sed 's/Mi//g' >> $datadir/$container-mem
	done <<< $data
done

