#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 5
#SBATCH -G 1
#SBATCH -c 2
#SBATCH --qos=short
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o dlc_job_convertcsv2h5_%J.out

module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU
 
python eMotion/worker_scripts/dlc_convertcsv2h5.py

echo "Job Completed!"
