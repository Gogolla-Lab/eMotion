#!/bin/bash
#SBATCH -a 0-9
#SBATCH -p gpu
#SBATCH --qos=short
#SBATCH -t 1:45:00
#SBATCH -G 1
#SBATCH -x dge[008-015]
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
#slurm parameters: -a -t