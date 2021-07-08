#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 16:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_gtx1080_training_%J.out


module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
gputouse=$CUDA_VISIBLE_DEVICES

echo "CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES"
nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python eMotion/worker_scripts/dlc_start_training.py "$shuffleindex" "$gputouse"
