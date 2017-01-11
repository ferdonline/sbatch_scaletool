#!/bin/bash

# Installation prefix
PREFIX=$HOME/usr

if [ -z $1 ]; then
    echo "Syntax: $0 <job.prop file>"
    exit -1
fi

#Defaults (eventually overrited in $1 (job.prop file)
START=true
SBATCH_OPTIONS=""

#Set vars from properties
source $1


# Check if vars are ok
if [ -z "$NAME" ] || [ -z "$PARTITION" ] || [ -z "$COMMAND" ] || [ -z $MAX_TASKS ]; then
    echo "Please define NAME, PARTITION, COMMAND and ENV_SETUP in proj.prop file"
    exit -1
fi


# --------------------------------------------
# Main execution
# --------------------------------------------

set -e

#The main template
TPL_STR="$(<${PREFIX}/var/sbatch_job.cmd.tpl)"


#New running dir
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="srun_${NAME}_$(date +'%Y-%m-%d_%Hh%Mm')"
fi
mkdir -p $OUTPUT_DIR  


N_TSK=1
if [ -n $MIN_TASKS ]; then
    N_TSK=$MIN_TASKS
fi

while [ $N_TSK -le $MAX_TASKS ]; do
    echo " " 
    echo "Preparing run with  N_processes = $N_TSK""..."
    
    # --- max nodes per partition ---
    #  debug       1-512
    #  test        1-256
    #  prod        512-2k
    #  prod-large  1k-4k

    # As a distribution policy lets use up to 4 tasks per node up to 128 nodes ( 512 tasks )
    # Then we increase tasks per node up to 16, then nodes up to 256, then overcommit () (up to 64 tasks x 512 nodes)

    if [ $N_TSK -le 4 ]; then
        N_ND=1
        N_PER=$N_TSK
    elif [ $N_TSK -le 512 ]; then
        # With N_TSK being power of 2 it works quite well - no need to ceiling
        N_ND=$(($N_TSK/4))
        N_PER=4
    elif [ $N_TSK -le 2048 ]; then
        N_ND=128
        N_PER=$(($N_TSK/128))
    elif [ $N_TSK -le 8192 ]; then
        #Start "overcommiting" to 32 tasks per node, which is natureal in the bgq
        N_ND=256
        N_PER=$(($N_TSK/256))
    else
        N_ND=512
        N_PER=$(($N_TSK/512))
    fi
	
    # use at most 64 tasks per node. Values only higher when N_TSK > 512*64 
    if [ $N_PER -gt 64 ]; then
        echo "Seriously? $N_TSK dont fit in 512 BG-q nodes "
        exit -1
    fi
    if [ $N_PER -gt 16 ]; then
        echo "Ovecommiting being enabled with $N_PER processes per node"
    fi

    echo " - Parameters of run: [Nodes=$N_ND, Tasks_per_node=$N_PER]"

    _CMD_FILE=$OUTPUT_DIR/"_srun_${NAME}_${N_TSK}.cmd"
    
    #Fill template with necessary changes
    eval "echo \"$TPL_STR\"" > $_CMD_FILE
    if $START; then
        sbatch $SBATCH_OPTIONS $_CMD_FILE
    fi
  
    # Go as power of 2 
    N_TSK=$((2*N_TSK))
done

