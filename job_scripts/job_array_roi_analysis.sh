#!/bin/bash
#SBATCH -a 0-153
#SBATCH --qos=short
#SBATCH -t 40:00
#SBATCH -c 1
#SBATCH -o job_array_roi_analysis_%A_%a.out
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de

module purge
source activate behaviour-switching

folder=${1?Error: Please provide the path to the folder containing analysis.csv and DLC .h5 outputs.}

python eMotion/analysis/roi_analysis.py "$folder" "$SLURM_ARRAY_TASK_ID"

#Manually edit:
#slurm parameters: -a -t
#varibles: folder
