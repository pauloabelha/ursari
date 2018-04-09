#!/bin/bash

while getopts c:u:j:w: option
do
case "${option}"
in
c) CONFIG_FILE=${OPTARG};;
u) ADF_USER=${OPTARG};;
j) JOB_ID=${OPTARG};;
w) WATCH_FILE=${OPTARG};;
esac
done

if [ -z $JOB_ID ]
then
	echo "Please define a job ID file: e.g. ./watch_bluebear_job -c job.config -j 123456 -w watch.txt"
	echo "See help: ./run_bluebear_job.sh --help"
	exit 0 
fi

# obtain configuration variables
if [[ -z $ADF_USER ]]
then
	source $CONFIG_FILE
fi

echo "User: "$ADF_USER
echo "Config file: "$CONFIG_FILE
if [[ -z $WATCH_FILE ]]
then
	echo "Watch file: no watch file"
	WATCH_FILE_CMD=""
else
	echo "Watch file: "$WATCH_FILE
	WATCH_FILE_CMD="echo 'WATCH FILE:'; echo ''; cat $WATCH_FILE"
fi

# copy config file and script to bluebear home folder
echo "Obtaining info from BlueBEAR:"
ssh $ADF_USER@bluebear.bham.ac.uk "
 echo 'SLURM-STATS:'; echo '';
 cat slurm-$JOB_ID.stats;
 echo 'SLURM-OUT:'; echo '';
 cat slurm-$JOB_ID.out;
 echo 'SLURM-ERR:'; echo '';
 cat slurm-$JOB_ID.err; 
 $WATCH_FILE_CMD	
"
