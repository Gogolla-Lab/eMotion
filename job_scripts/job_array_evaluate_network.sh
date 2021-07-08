#!/bin/bash
#SBATCH -a 0-9
#SBATCH -p gpu
#SBATCH -x dge007
#SBATCH --qos=short
#SBATCH -t 1:30:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o evaluate_network_%A_%a.out

module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

gputouse=$CUDA_VISIBLE_DEVICES

python behaviour-switching/worker_scripts/dlc_evaluate_network.py "$SLURM_ARRAY_TASK_ID" "$gputouse"
echo "dlc_evaluate_network.py $SLURM_ARRAY_TASK_ID $gputouse completed!"

#Manually edit:
#iteration and shuffleindex in config.yaml file
#slurm parameters: -a -t
