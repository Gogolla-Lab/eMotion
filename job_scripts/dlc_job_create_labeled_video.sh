#!/bin/bash
#SBATCH -a 0-63
#SBATCH -t 16:00:00
#SBATCH -c 8
#SBATCH --mem=120G
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_create_labeled_video_%A_%a.out


module purge
#module load cuda/11.1.0
#module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}

#gputouse=$CUDA_VISIBLE_DEVICES  # ToDo: Unused! creating labeled videos might not require gpu!

#nvidia-smi --query-gpu=memory.total --format=csv

python eMotion/worker_scripts/dlc_create_labeled_video.py "$shuffleindex" "$snapshotindex" "$SLURM_ARRAY_TASK_ID"

echo "dlc_create_labeled_video.py $shuffleindex $snapshotindex is completed!"
