#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 12:00:00
#SBATCH -G gtx1080:1
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_plot_trajectories_%J.out


module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

shuffleindex=${1?Error: no shuffleindex given}
snapshotindex=${2?Error: no snapshotindex given}

nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits

python eMotion/worker_scripts/dlc_plot_trajectories.py "$shuffleindex" "$snapshotindex"

echo "dlc_plot_trajectories.py $shuffleindex $snapshotindex is completed!"
