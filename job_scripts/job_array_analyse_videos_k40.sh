#!/bin/bash
#SBATCH -a 0-2:1
#SBATCH -p gpu
#SBATCH -t 1-00:00:00
#SBATCH -G k40:1
#Sbatch -c 2
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_analyse_videos_kepler_%A_%a.out

module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate DLC-GPU

videofolder=$HOME/week2temp2
shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}
gputouse=$CUDA_VISIBLE_DEVICES

nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

# $SLURM_ARRAY_TASK_ID will be used as an index to a python script
python behaviour-switching/dlc_analyse_videos_jobarray.py "$shuffleindex" "$snapshotindex" "$videofolder" "$SLURM_ARRAY_TASK_ID" "$gputouse"

#Manually edit:
#slurm parameters: -a -t
#varibles: videofolder
