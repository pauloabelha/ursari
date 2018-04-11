#!/bin/bash

MOUNT_FOLDER=$1

sudo mount -t cifs -o vers=3.0 -o domain=ADF -o username=ferreipa //its-rds.bham.ac.uk/2017/leonarda-01 $MOUNT_FOLDER
