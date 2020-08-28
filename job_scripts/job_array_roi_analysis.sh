#!/bin/bash
#SBATCH -a 0-153
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 30:00
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH -o job_array_roi_analysis_%A_%a.out
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de

module purge
source activate behaviour-switching

folder=${1?Error: Please provide the path to the folder containing analysis.csv and DLC .h5 outputs.}

python behaviour-switching/roi_analysis.py "$folder" "$SLURM_ARRAY_TASK_ID"

#Manually edit:
#slurm parameters: -a -t
#varibles: folder
