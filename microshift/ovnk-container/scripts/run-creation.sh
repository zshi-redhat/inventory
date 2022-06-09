#!/bin/bash

oc create -f deployment.yaml

./cpu-mem.sh &
pid=$!

oc wait --for condition=available deployment testpod --timeout=120s
kill $pid


oc scale --replicas=0 deployment testpod
oc delete -f deployment.yaml


echo "\n"
echo "CPU & MEM utilization:"
echo "\n"
./cal.sh
