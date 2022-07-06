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
	for i in {1..10}
	do
		export index=$i
		envsubst <"policy.yaml.template" >"policy-${i}.yaml"
		oc create -f policy-${i}.yaml
		rm -rf policy-${i}.yaml
	done
fi

if [ $action == "delete" ]; then
	for i in {1..10}
	do
		export index=$i
		envsubst <"policy.yaml.template" >"policy-${i}.yaml"
		oc delete -f policy-${i}.yaml
		rm -rf policy-${i}.yaml
	done
fi

echo "Done"
