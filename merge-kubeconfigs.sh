#!/bin/bash

CONFIG_FILES="${@}"
KUBECONFIG=""

for file in $CONFIG_FILES
do
    if [[ ! $(echo $file | grep ^/) ]]
    then
        file=$PWD/$file
    fi
    if [[ -f $file ]]
    then
        KUBECONFIG="${KUBECONFIG}:${file}"
    fi
done

export KUBECONFIG=${KUBECONFIG/:/}

kubectl config view --flatten
