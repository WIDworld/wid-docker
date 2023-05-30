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

# ensure that the directories are writable by Docker
chmod a+rwX /wid-world 

# Run container with bash
time docker run $DOCKEROPTS \
  -v ${DROPBOX}:/W2ID \
  -v $(pwd)/wid-world:/wid-world \
  -v /var/log:/var/log \
  --platform linux/arm64/v8 \
  $DOCKERIMG:$TAG \
  /bin/bash



