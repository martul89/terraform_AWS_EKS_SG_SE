#!/bin/bash

mkdir ~/.kube/
terraform output -raw AWS-kubeconfig > ~/.kube/config
aws configure set aws_access_key_id ${access_key}
aws configure set aws_secret_access_key ${secret_key}
aws configure set region ${region}