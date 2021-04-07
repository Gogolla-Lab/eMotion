#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 6:00:00
#SBATCH -G 1
#SBATCH -c 2
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_extract_outlier_frames_%J.out


module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate behaviour-switching

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}
outlieralgorithm=${3?Error: no outlier algorithm given}
epsilon=${4?Error: no epsilon given}
extractionalgorithm=${5?Error: no extraction algorithm given}
nframes=${6?Error: no number of frames to extract given}

nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python behaviour-switching/worker_scripts/dlc_extract_outlier_frames.py "$shuffleindex" "$snapshotindex" "$outlieralgorithm" "$epsilon" "$extractionalgorithm" "$nframes"

echo "dlc_extract_outlier_frames.py $shuffleindex $snapshotindex $outlieralgorithm $epsilon $extractionalgorithm $nframes is completed!"
