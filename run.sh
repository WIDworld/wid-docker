#!/bin/bash

configfile=config.txt

echo "================================"
echo "Pulling defaults from ${configfile}:"
cat $configfile
echo "--------------------------------"
source $configfile
echo "================================"
echo "Running docker:"


DOCKERIMG=$(echo $MYHUBID/$MYIMG | tr [A-Z] [a-z])
if [[ $CI ]] 
   then
      echo "In CI Github Actions..."
      DOCKEROPTS="--rm"
      TAG=latest
   else
      DOCKEROPTS="-dit"
      
fi

# Run container 
if [ $# -eq 0 ]
  then
      echo "No file supplied, will run bash..."
      # Run container with bash
      time docker run $DOCKEROPTS \
        -v ${DROPBOX}/Country-Updates:/W2ID-Country-Updates \
        -v $(pwd)/wid-world:/wid-world \
        --platform linux/arm64/v8 \
        $DOCKERIMG:$TAG /bin/bash
   else
      echo "Will run $1 file and check logfile"
      time docker run $DOCKEROPTS \
        -v ${DROPBOX}/Country-Updates:/W2ID-Country-Updates \
        -v $(pwd)/wid-world:/wid-world \
        --platform linux/arm64/v8 \
        --entrypoint stata-mp \
        $DOCKERIMG:$TAG -bq $1

      # print and check logfile
      logfile=${1%*.do}.log
      EXIT_CODE=0
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






