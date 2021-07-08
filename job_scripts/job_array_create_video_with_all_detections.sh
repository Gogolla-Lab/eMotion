#!/bin/bash
#SBATCH -a 0-63:1
#SBATCH -c 4
#SBATCH --mem=32G
#SBATCH -t 12:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_create_video_with_all_detections_%A_%a.out

module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}

python eMotion/worker_scripts/dlc_create_video_with_all_detections.py "$shuffleindex" "$snapshotindex" "$SLURM_ARRAY_TASK_ID"

echo "dlc_create_labeled_video.py $shuffleindex $snapshotindex $SLURM_ARRAY_TASK_ID is completed!"
