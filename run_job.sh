#!/bin/bash

WRAP_SCRIPT="wrap_script"

if [ -z $1 ] || [[ $1 == "--help" ]]
then
	echo "This is a script to run jobs on the Unviersity of Bimringham BlueBEAR HPC"
	echo "It takes a configuration file and a script as arguments"
	echo "It re-creates a wrapping script (default name wrap_script) setting all SBATCH variables on the beggining and pastes the input script after them"
	echo "After running run_job.sh, you can check the created wrap_script (it is re-created from scratch each time you run run_job.sh)"
	echo "Example run: ./run_job -c job.config -s my_script"
	echo "Config file example (in case you don't have one:"
	echo ""
	echo "# Begin config file"
	echo "######## GPU ################################
USE_GPU="no"                                                    # whether to use GPU ("yes" or "no")
GPU_TO_USE=p100							# which GPU to use
# Choose GPU according to the codes below:
#     Nvidia Tesla P100:	p100
#     Nvidia Tesla K20: 	k20
#     Nvidia Quadro 5000:	q5000

######## LOG ################################
ERROR_FILE="--error=slurm-%j.err"				# what error file for output

######## ACCOUNT #############################
ACCOUNT=leonarda-muri 						# select accoutn according to your project name"
	echo "# End of config file"
	echo ""
	echo "Written by Paulo Ferreira: p.a.ferreira at cs bham ac uk"
	echo "GPL license applies"
	exit 0
fi

while getopts c:s: option
do
case "${option}"
in
c) CONFIG_FILE=${OPTARG};;
s) SCRIPT=${OPTARG};;
esac
done

if [[ -z $CONFIG_FILE ]]
then
	echo "Please define a configuration file: e.g. ./run_job -c job.config -s my_script"
	echo "See help: ./run_job.sh --help"
	exit 1 
fi

if [ ! -f $CONFIG_FILE ];
then
    	echo "Config file does not exist: $CONFIG_FILE"
        exit 1
fi

if [[ -z $SCRIPT ]]
then
    	echo "Please define a script to run: e.g. ./run_job -c job.config -s my_script"
	echo "See help:	./run_job.sh --help"
        exit 1
fi

if [ ! -f $SCRIPT ];
then
	echo "Script file does not exist: $SCRIPT"
	exit 1
fi

######### SOURCE CONFIG FILE ################
source $CONFIG_FILE

######## ECHO INFO #########################
echo "Debugging: "$DEBUG
echo "Account: "$ACCOUNT
echo "Use GPU: "$USE_GPU
if [ $USE_GPU = "yes" ]
then
	QOS="bbgpu"
	echo "GPU to use: "$GPU_TO_USE
fi
echo "QOS: "$QOS	
echo "Error file: "$ERROR_FILE
echo "Script to run: "$SCRIPT
echo "Notify user by e-mail: "$EMAIL_NOTIFICATION

######### CREATE WRAPPING SCRIPT ###########
rm $WRAP_SCRIPT
touch $WRAP_SCRIPT
echo '#!/bin/bash' > $WRAP_SCRIPT
echo "" >> $WRAP_SCRIPT
echo "#SBATCH --account="$ACCOUNT >> $WRAP_SCRIPT
echo "#SBATCH --qos "$QOS >> $WRAP_SCRIPT
if [ $USE_GPU = "yes" ];
then
	echo "#SBATCH --gres gpu:$GPU_TO_USE:1" >> $WRAP_SCRIPT
fi
echo "#SBATCH --error="$ERROR_FILE >> $WRAP_SCRIPT

######### MODULE LOADING ##################
echo "module purge; module load bluebear" >> $WRAP_SCRIPT
echo "Python modules to load:"
MODULE_COMMAND_BASE="module load apps/"
PYTHON_VERSION="3.5.2"
PYTHON_VERSION_CMD="-python-$PYTHON_VERSION"
echo "module load bear-apps/2018a" >> $WRAP_SCRIPT
echo "module load Python/$PYTHON_VERSION-iomkl-2018a" >> $WRAP_SCRIPT
GPU_MODULE="-cuda-8.0.44"
TORCH_MODULE="pytorch/0.2.0"$PYTHON_VERSION_CMD
TORCHVISION_MODULE="torchvision/0.1.9"$PYTHON_VERSION_CMD
IFS=';' read -ra ADDR <<< "$PYTHON_MODULES"
for i in "${ADDR[@]}"; do
        echo -e "\t"$i
        if [ $i == "torch" ]
        then
            	if [ $USE_GPU = "yes" ]
                then
                    	echo $MODULE_COMMAND_BASE$TORCH_MODULE$GPU_MODULE >> $WRAP_SCRIPT
                else
                    	echo $MODULE_COMMAND_BASE$TORCH_MODULE >> $WRAP_SCRIPT
                fi
        fi
	if [ $i == "torchvision" ]
        then
                if [ $USE_GPU = "yes" ]
                then
                    	echo $MODULE_COMMAND_BASE$TORCHVISION_MODULE$GPU_MODULE >> $WRAP_SCRIPT
                else
                    	echo $MODULE_COMMAND_BASE$TORCHVISION_MODULE >> $WRAP_SCRIPT
                fi
        fi
done

######## NOTIFICATIONS #####################
if [ $EMAIL_NOTIFICATION = "yes" ]
then
    	echo "#SBATCH --mail-type ALL" >> $WRAP_SCRIPT
fi

######## DEBUGGING #########################
if [ $DEBUG = "yes" ]
then
    	echo "set -e" >> $WRAP_SCRIPT
fi

echo "" >> $WRAP_SCRIPT
cat $SCRIPT >> $WRAP_SCRIPT

######## RUN JOB ###########################
sbatch $WRAP_SCRIPT
