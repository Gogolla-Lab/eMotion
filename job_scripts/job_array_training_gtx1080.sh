#!/bin/bash
#SBATCH -a 0-9
#SBATCH -p gpu
#SBATCH -t 18:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_training_gtx1080_%A_%a.out


module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

gputouse=$CUDA_VISIBLE_DEVICES

python eMotion/worker_scripts/dlc_start_training.py "$SLURM_ARRAY_TASK_ID" "$gputouse"
