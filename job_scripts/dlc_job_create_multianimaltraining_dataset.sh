#!/bin/bash
#SBATCH --qos=short
#SBATCH -t 2:00:00
#SBATCH -c 4
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_create_multianimaltraining_dataset_%J.out

module purge

source "$HOME"/.bashrc
source activate DLC-GPU

config=${1?Error: no config.yaml path given}
num_shuffles=${2?Error: no num_shuffles given}

python eMotion/worker_scripts/dlc_create_multianimaltraining_dataset.py "$config" "$num_shuffles"

echo "Job Completed!"
