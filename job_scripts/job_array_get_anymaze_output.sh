#!/bin/bash
#SBATCH -a 0-155
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 04:58
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH -o job_array_get_anymaze_output_%A_%a.out

module purge
source activate behaviour-switching

folder=${1?Error: Please provide the path to the folder containing analysis.csv and DLC outputs.}

python behaviour-switching/roi_analysis.py "$folder" "$SLURM_ARRAY_TASK_ID"

#Manually edit:
#slurm parameters: -a -t
#varibles: folder
