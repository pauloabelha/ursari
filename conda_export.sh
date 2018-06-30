#!/bin/bash


FOLDER=$1

NOW=$(date "+%Y-%m-%d")
echo "Creating folder: "$FOLDER/envs-$NOW
mkdir $FOLDER/envs-$NOW
ENVS=$(conda env list | grep '^\w' | cut -d' ' -f1)
echo "Environments: "$ENVS
for env in $ENVS; do
    echo "Exporting environment "$env
    source activate $env
    conda env export > $FOLDER/envs-$NOW/$env.yml
    echo "Done. Exported to: "$FOLDER/envs-$NOW/$env.yml
done
echo "Done exporting all environments"
