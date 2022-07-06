#!/bin/bash

pods=$(oc get pods | grep -i deploy | awk -F" " "{print $2}")
rcs=$(oc get ReplicaSet)


while read -r rc
do
	n=$(echo $rc | awk -F" " '{print $1}')
	echo $n
	oc delete ReplicaSet $n
done <<< $rcs

while read -r p
do
	n=$(echo $p | awk -F" " '{print $1}')
	echo $n
	oc delete pod $n
done <<< $pods
