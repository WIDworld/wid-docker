#!/bin/bash

configfile=config.txt

echo "================================"
echo "Pulling defaults from ${configfile}:"
cat $configfile
echo "--------------------------------"
source $configfile
echo "================================"
echo "Running docker:"

# When we are on Github Actions
if [[ $CI ]] 
then
   echo "In CI Github Actions"
   DOCKEROPTS="--rm"
   DOCKERIMG=$(echo $GITHUB_REPOSITORY | tr [A-Z] [a-z])
   TAG=latest
else
   DOCKEROPTS="-dit"
   DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
fi

# Run container with bash
time docker run $DOCKEROPTS \
  -v ${DROPBOX}/Country-Updates:/W2ID-Country-Updates \
  -v $(pwd)/wid-world:/wid-world \
  --platform linux/arm64/v8 \
  $DOCKERIMG:$TAG /bin/bash



