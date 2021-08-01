#!/bin/bash
#SBATCH -a 1-6
#SBATCH -p gpu
#SBATCH -t 18:00:00
#SBATCH -x dge[001-015],dte[001-010]
#SBATCH -G 1
#SBATCH --mem=100G
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_training_on_large_gpus_%A_%a.out

module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

config=${1?Error: no config.yaml given}

gputouse=$CUDA_VISIBLE_DEVICES

python eMotion/worker_scripts/dlc_start_training.py "$config" "$SLURM_ARRAY_TASK_ID" "$gputouse"
