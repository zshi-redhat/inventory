#!/bin/bash

action=""
if [ -z $1 ]; then
	action="create"
elif [ $1 == "delete" ]; then
	action="delete"
else
	action="create"
fi

if [ $action == "create" ]; then
	for i in {1..100}
	do
		export index=$i
		envsubst <"svc.yaml.template" >"svc-${i}.yaml"
		oc create -f svc-${i}.yaml
		rm -rf svc-${i}.yaml
	done
fi

if [ $action == "delete" ]; then
	for i in {1..100}
	do
		export index=$i
		envsubst <"svc.yaml.template" >"svc-${i}.yaml"
		oc delete -f svc-${i}.yaml
		rm -rf svc-${i}.yaml
	done
fi

echo "Done"
