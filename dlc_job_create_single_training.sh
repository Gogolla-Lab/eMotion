#!/bin/bash
#SBATCH -p gpu
#SBATCH -t 10
#SBATCH -G 1
#SBATCH -n 2
#SBATCH --qos=short
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de

module purge
module load cuda10.0/toolkit/10.0.130
module load cuda10.0/blas/10.0.130
module load cudnn/10.0v7.6.3

source activate DLC-GPU
 
python tftest.py<<input
yes
input
