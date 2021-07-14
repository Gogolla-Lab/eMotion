#!/bin/bash
#SBATCH -a 0-63
#SBATCH -t 24:00:00
#SBATCH -c 4
#SBATCH --mem=64G
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_stitch_tracklets_%A_%a.out

module purge
#module load cuda/11.1.0
#module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

videofolder=${1?Error: no videofolder given}

# $SLURM_ARRAY_TASK_ID will be used as an index to a python script
python eMotion/worker_scripts/dlc_stitch_tracklets_jobarray.py "$videofolder" "$SLURM_ARRAY_TASK_ID"

#Manually edit:
#slurm parameters: -a -t
#varibles: videofolder
