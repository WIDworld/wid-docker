#!/bin/bash


if [[ $CI ]] # if we are on Github Actions
then
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   source init.config.txt
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi

# Check that the configured STATALIC is actually a file
if [[ ! -f $STATALIC ]] 
then
  echo "You specified $STATALIC - that is not a file"
	exit 2
fi


# Remove old image with same tag and [re]build
docker rmi -f ${DOCKERIMG}:${TAG}

DOCKER_BUILDKIT=1 docker build . \
  --progress plain \
  --secret id=statalic,src=$STATALIC \
  --platform $PLATFORM \
  -t ${DOCKERIMG}:$TAG


if [[ $? == 0 ]] # If exited cleanly
then
   # write out final values to config.txt
   [[ -f config.txt ]] && \rm config.txt
   echo "# configuration created on $(date +%F_%H:%M)" | tee config.txt
   for name in $(grep -Ev '^#' init.config.txt| awk -F= ' { print $1 } ')
   do 
      echo ${name}=${!name} >> config.txt
   done
fi  
