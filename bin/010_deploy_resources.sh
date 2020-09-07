#!/bin/bash

#
# UNSW IT STaR Domain > Faculty Subdomain > DevOps Team
#  _____
# |  ___|_/\__    Copyright UNSW 2020, BSD-2-Clause license (See LICENSE.md)
# | |_  \    /
# |  _| /_  _\    1. Do not redistribute without permission.
# |_|     \/      2. Do not remove this notice
#
#                 Extend this notice if required
#
# Created by Richard Green, richard.green@unsw.edu.au, 2020
#

set -e

if [ "$CONTAINER_ENGINE" != "podman" ]
then
  CONTAINER_ENGINE="docker"
fi

declare -a RegionArray=("ap-southeast-2" "ap-south-1")
stage=$1
stackname=unsw-interview-task-003
regionOutput=()
for region in ${RegionArray[@]}; do
  echo "Deploying for region: ${region}"
  export AWS_REGION=${region}
  export AWS_DEFAULT_REGION=${region}
  stackup="${CONTAINER_ENGINE} run --rm \
    -v `pwd`:/cwd:Z \
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
    -e AWS_DEFAULT_REGION -e AWS_REGION \
    realestate/stackup:latest"

  command="$stackup ${stackname} up -t cfn/templates/010_resources.yml \
    --tags cfn/tags.yml -o KeyName=unsw-test"
  eval ${command}

  command="$stackup ${stackname} outputs"
  regionOutput+=( $(eval ${command}) )

done
for output in "${regionOutput[@]}"
do
   echo "${output}"
done

