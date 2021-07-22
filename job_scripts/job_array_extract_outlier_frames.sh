#!/bin/bash
#SBATCH -a 0-63
#SBATCH -t 2:00:00
#SBATCH --qos=short
#SBATCH -c 2
#SBATCH --mem=80G
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_extract_outlier_frames_%A_%a.out


module purge
#module load cuda/11.1.0
#module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}
outlieralgorithm=${3?Error: no outlier algorithm given}
epsilon=${4?Error: no epsilon given}
extractionalgorithm=${5?Error: no extraction algorithm given}

python eMotion/worker_scripts/dlc_extract_outlier_frames.py "$shuffleindex" "$snapshotindex" "$outlieralgorithm" "$epsilon" "$extractionalgorithm" "$SLURM_ARRAY_TASK_ID"

echo "dlc_extract_outlier_frames.py $shuffleindex $snapshotindex $outlieralgorithm $epsilon $extractionalgorithm $SLURM_ARRAY_TASK_ID is completed!"
