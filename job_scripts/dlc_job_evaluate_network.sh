#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 3:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_evaluate_network_%J.out


module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate DLC-GPU

shuffles=${1?Error: no shuffles given} #shuffles are expected to be seperated by "-"
gputouse=$CUDA_VISIBLE_DEVICES

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python behaviour-switching/dlc_evaluate_network.py $shuffles $gputouse

echo "dlc_evaluate_network.py $shuffles $gputouse completed!"
