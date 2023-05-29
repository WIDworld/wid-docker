#!/bin/bash

# for debugging
BUILDARGS="--progress plain --no-cache"


# if we are on Github Actions
if [[ $CI ]] 
then
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   source config.txt
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi

# Check that the configured STATALIC is actually a file
if [[ ! -f $STATALIC ]] 
then
  echo "You specified $STATALIC - that is not a file"
	exit 2
fi

docker rmi -f ${DOCKERIMG}:${TAG}
DOCKER_BUILDKIT=1 docker build \
  $BUILDARGS \
  . \
  --secret id=statalic,src=$STATALIC \
  --platform linux/arm64/v8 \
  -t ${DOCKERIMG}:$TAG
   
