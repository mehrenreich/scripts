#!/bin/bash

CONFIG_FILES="${@}"
KUBECONFIG=""

for file in $CONFIG_FILES
do
    if [[ -f $file ]]
    then
        KUBECONFIG="${KUBECONFIG}:${file}"
    fi
done

kubectl config view --flatten
