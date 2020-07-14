#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 16:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_create_labeled_video_%J.out


module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}
listindex1=${3?Error: no listindex1 given}
listindex2=${4?Error: no listindex2 given}

gputouse=$CUDA_VISIBLE_DEVICES

nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python dlc_create_labeled_video.py $shuffleindex $snapshotindex $listindex1 $listindex2

echo "dlc_create_labeled_video.py $shuffleindex $snapshotindex $listindex1 $listindex2 is completed!"
