#!/bin/bash

if [ -z $1 ]; then
	datadir="data"
else
	datadir="$1"
fi

files=`ls $datadir`

while read -r file; do
	count=0
	sum=0
	peak=0
	low=1000
	while read -r line; do
		if [ $((line)) -gt $peak ];then
			peak=$((line))
		fi
		if [ $((line)) -lt $low ];then
			low=$((line))
		fi
		sum=$(bc <<< $sum+$((line)) )
		count=$(bc <<< $count+1)
	done < $datadir/$file
	avg=$(bc <<< "scale=2; $sum/$count")
	echo container:$file sum:$sum count:$count avg:$avg low:$low peak:$peak
done <<< $files
