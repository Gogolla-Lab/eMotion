#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 2-00:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_analyze_videos_%J.out


module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate behaviour-switching

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}

gputouse=$CUDA_VISIBLE_DEVICES

nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python behaviour-switching/dlc_analyze_videos.py "$shuffleindex" "$snapshotindex" "$gputouse"

echo "dlc_analyze_videos.py $shuffleindex $snapshotindex is completed!"
