#!/bin/bash

if [[ -f config.txt ]]
then 
   configfile=config.txt
else 
   configfile=init.config.txt
fi

echo "================================"
echo "Pulling defaults from ${configfile}:"
cat $configfile
echo "--------------------------------"
source $configfile
echo "================================"

echo "Running docker:"

# Docker options
DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])

if [[ $CI ]] 
   then
      echo "In CI Github Actions..."
      DOCKEROPTS="--rm"
      # PLATFORM=linux/amd64 # see multi-platform usage
      TAG=latest
   else
      DOCKEROPTS="-dit -ls"
fi

# Run container 
if [ $# -eq 0 ]
  then
      echo "No file supplied, will run bash."
      # Run container with bash
      time docker run $DOCKEROPTS \
        -v ${DROPBOX}/W2ID:/W2ID \
        -v $(pwd)/wid-world:/wid-world \
        --platform $PLATFORM \
        $DOCKERIMG:$TAG /bin/bash
   else
      echo "Will run $1 file and check logfile"
      time docker run $DOCKEROPTS \
        -v ${DROPBOX}/W2ID:/W2ID \
        -v $(pwd)/wid-world:/wid-world \
        --platform $PLATFORM \
        --entrypoint stata-mp \
        $DOCKERIMG:$TAG -bq $1 &

      # print and check logfile
      basefile=$(basename $1)
      logfile="wid-world/${basefile%*.do}.log"
      
      EXIT_CODE=0
      # Will likely not finish, but continue in background
      sleep 5

      if [[ -f $logfile ]]
      then
         echo "===== $logfile ====="
         cat $logfile

         # Fail CI if Stata ran with an error
         LOG_CODE=$(tail -1 $logfile | tr -d '[:cntrl:]')
         echo "===== LOG CODE: $LOG_CODE ====="
         [[ ${LOG_CODE:0:1} == "r" ]] && EXIT_CODE=1 
      else
         echo "$logfile not found"
         EXIT_CODE=2
      fi
      echo "==== Exiting with code $EXIT_CODE"
      exit $EXIT_CODE
fi






