#!/bin/bash

oc create -f deployment.yaml
oc wait --for condition=available deployment testpod --timeout=120s
oc scale --replicas=0 deployment testpod

./cpu-mem.sh "data" &
pid=$!

while true; do
	if oc get pods | grep testpod > /dev/null 2>&1; then
		continue
	else
		break
	fi
done

kill $pid

oc delete -f deployment.yaml

rcs=$(oc get ReplicaSet)
while read -r rc; do
	n=$(echo $rc | awk -F" " '{print $1}')
	echo $n
	oc delete ReplicaSet $n
done <<< $rcs

echo "\n"
echo "CPU & MEM utilization:"
echo "\n"
#./cal.sh "data"
