#!/bin/bash
#SBATCH -a 0-40
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 1:00:00
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH -o job_array_get_anymaze_output.sh_%J_%a.out

module purge
source activate behaviour-switching

folder=/scratch/onur.serce/

python behaviour-switching/roi_analysis.py $folder $SLURM_ARRAY_TASK_ID

#Manually edit:
#slurm parameters: -a -t
#varibles: folder