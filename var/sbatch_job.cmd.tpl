#!/bin/bash -l
#SBATCH --job-name='$NAME'
#SBATCH --partition=$PARTITION
#SBATCH --nodes=$N_ND
#SBATCH --ntasks=$N_TSK
#SBATCH --exclusive
#SBATCH --overcommit
#SBATCH --ntasks-per-node=$N_PER
#SBATCH --time=1:00:00
#SBATCH --mail-type=ALL
#SBATCH --output=$OUTPUT_DIR/${NAME}_$N_TSK.log
#SBATCH --error=$OUTPUT_DIR/${NAME}_$N_TSK.err
#SBATCH --account=proj16


#----EXIT IF ERROR--------------------
set -e

#----Set Environment---------------- 
$ENV_SETUP

#----ALLOC INFO-----------------------
echo # Job info:
echo \"Nodes: [\$SLURM_JOB_NODELIST]\"
echo \"Limits: \$(ulimit -a)\"
echo
echo '#===== Beginning job execution ======'
echo

#----RUN-------------------------------
time srun $COMMAND

#----END-------------------------------            
echo '===== End job execution ======'
echo
