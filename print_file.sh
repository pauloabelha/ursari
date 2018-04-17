#!/bin/bash

if [ "$1" == "--help" ]; then
	echo "Script to print a file through the network of the University of Bimringham"
	echo "First param: file path"
	echo "Second param: printer name (default=konica)"
	echo "Third param: server name (default=wallace)"
	echo "Adapted from Tomáš Jakl: https://kam.mff.cuni.cz/~jaklt/posts/sprint"
	exit 0
fi

# default variables
BHAM_USER=ferreipa
# wallace, tinky-winky, feathers, gromit
SERVER_NAME=tinky-winky
GATEWAY_SERVER=$SERVER_NAME.cs.bham.ac.uk
GATEWAY_SSH=$BHAM_USER@$GATEWAY_SERVER
DEFAULT_PRINTER=konica

FILE_PATH=$1
PRINTER_NAME=$2

if [ "$FILE_PATH" == "" ]
then
	echo "Please define a file path (see --help)"
	exit
fi

# get just the file basename (with extension) to send to printer
FILE_NAME="${FILE_PATH##*/}"
if [ "$FILE_NAME" == "" ]
then
	echo "ERROR! Problem obtaining filename base from filepath: "$FILE_PATH
	exit 1
fi
echo "Extracted filename base: "$FILE_NAME

if [ "$PRINTER" == "" ]
then
        PRINTER_NAME=$DEFAULT_PRINTER
        echo "Using default printer: " $DEFAULT_PRINTER
else
	echo "Using chosen printer: "$PRINTE_NAME
fi

echo "Copying file to gateway..."
scp "$FILE_PATH" $GATEWAY_SSH:$FILE_NAME
echo "Sending print command to printer..."
ssh $GATEWAY_SSH "lpr -P $PRINTER_NAME $FILE_NAME"
echo "Removing file from gateway..."
ssh $GATEWAY_SSH "rm -f $FILE_NAME"
