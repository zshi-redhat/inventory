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

echo "\n"
echo "CPU & MEM utilization:"
echo "\n"
./cal.sh "data"
