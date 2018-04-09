#!/bin/bash

while getopts c:s:w: option
do
case "${option}"
in
c) CONFIG_FILE=${OPTARG};;
s) SCRIPT=${OPTARG};;
w) WATCH_FILE=${OPTARG};;
esac
done

if [ -z $CONFIG_FILE ];
then
	echo "Please define a configuration file: e.g. ./run_bluebear_job -c job.config -s my_script"
	echo "See help: ./run_bluebear_job.sh --help"
	exit 0 
fi

if [ ! -f $CONFIG_FILE ];
then
    	echo "Config file does not exist: $CONFIG_FILE"
        exit 1
fi

if [ -z $SCRIPT ];
then
    	echo "Please define a script to run: e.g. ./run_bluebear_job -c job.config -s my_script"
	echo "See help:	./run_bluebear_job.sh --help"
        exit 0
fi

if [ ! -f $SCRIPT ];
then
    	echo "Script file does not exist: $SCRIPT"
        exit 1
fi

# obtain configuration variables
source $CONFIG_FILE

echo "User: "$ADF_USER
echo "Config file: "$CONFIG_FILE
echo "Script to run: "$SCRIPT
echo "Watch file: "$WATCH_FILE

# copy config file and script to bluebear home folder
echo "Copying files to BLueBEAR:"
scp $CONFIG_FILE $SCRIPT $WATCH_FILE $SSH_DEST:~

echo "Running command on BLueBEAR:"
ssh $ADF_USER@bluebear.bham.ac.uk "./run_job.sh -c $CONFIG_FILE -s $SCRIPT"
