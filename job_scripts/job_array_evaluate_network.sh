#!/bin/bash
#SBATCH -a 0-9
#SBATCH -p gpu
#SBATCH -x dge007
#SBATCH --qos=short
#SBATCH -t 1:30:00
#SBATCH -G gtx1080:1
#SBATCH -c 2
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o evaluate_network_%A_%a.out

module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate behaviour-switching

gputouse=$CUDA_VISIBLE_DEVICES

python behaviour-switching/dlc_evaluate_network.py "$SLURM_ARRAY_TASK_ID" "$gputouse"

echo "dlc_evaluate_network.py $SLURM_ARRAY_TASK_ID $gputouse completed!"

#Manually edit:
#iteration and shuffleindex in config.yaml file
#slurm parameters: -a -t
