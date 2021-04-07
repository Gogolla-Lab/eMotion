#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 10
#SBATCH -G 1
#SBATCH -c 2
#SBATCH --qos=short
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_create_training_comparison_%J.out

module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3
source activate behaviour-switching
 
python behaviour-switching/worker_scripts/dlc_create_training_comparison.py<<input
yes
input

echo "Job Completed!"
