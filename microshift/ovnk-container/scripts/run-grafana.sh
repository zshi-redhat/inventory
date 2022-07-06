#!/bin/bash

start=$(date)
echo "start at $start"
for i in {1..50}; do
	oc create -f deployment.yaml
	oc wait --for condition=available deployment testdeploy --timeout=120s
	oc scale --replicas=0 deployment testdeploy
	
	while true; do
		if oc get pods | grep testdeploy > /dev/null 2>&1; then
			continue
		else
			break
		fi
	done
	oc delete -f deployment.yaml
	rcs=$(oc get ReplicaSet | grep -v NAME)
	while read -r rc; do
		n=$(echo $rc | awk -F" " '{print $1}')
		echo $n
		oc delete ReplicaSet $n
	done <<< $rcs
done
end=$(date)

echo "start at $start"
echo "end at $end"
