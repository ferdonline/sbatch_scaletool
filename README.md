# sbatch_scaletool
A bash util to submit slurm jobs with increasing sizes for scaling tests

This tool auto generates batch submission files for slurm from a range of processes to be launched.
Project confifguration and test parameters shall be written in .prop file (an example is provided in var/sbatch_job.prop.example

The tool will create a new directory where all sbatch input files are stored, along with the generated stdout and stderr output files of each job.

# usage
sbatch_refine_run.sh \<project.prop_file\>


special thanks to Francesco Casalegno for the base script
