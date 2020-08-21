#!/bin/bash
#SBATCH -p medium
#SBATCH -t 1:59:58
#SBATCH --qos=short
#SBATCH -c 4
#SBATCH -C scratch
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_process_anymaze_outputs_%J.out

module purge
source activate behaviour-switching

folder=${1?Error: Please provide the path to the folder containing anymaze-like outputs.}

python behaviour-switching/process_anymaze_outputs.py "$folder"