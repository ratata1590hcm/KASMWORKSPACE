#! /bin/bash

## Parse input ##
NAME1=$1
NAME2=$2

## Run readme updater ##
docker run -v $PWD/docs:/docs \
  -e RELEASE="$KASM_RELEASE" \
  -e DOCKER_USERNAME="$README_USERNAME" \
  -e DOCKER_PASSWORD="$README_PASSWORD" \
  -e DOCKERHUB_REPOSITORY="${ORG_NAME}/core-${NAME1}-${NAME2}" \
  kasmweb/dockerhub-updater:develop
