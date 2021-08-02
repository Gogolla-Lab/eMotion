#!/bin/bash
#SBATCH -a 1-6
#SBATCH -p gpu
#SBATCH -t 18:00:00
#SBATCH -G 1
#SBATCH -x dge[008-015],dte[001-010]
#SBATCH --mem=64G
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_evaluate_network_%A_%a.out

module purge
module load cuda/11.1.0
module load cudnn/8.0.4.30-11.1-linux-x64

source "$HOME"/.bashrc
source activate DLC-GPU

gputouse=$CUDA_VISIBLE_DEVICES
config=${1?Error: no config.yaml given}

python behaviour-switching/worker_scripts/dlc_evaluate_network.py "$SLURM_ARRAY_TASK_ID" "$gputouse" "$config"
echo "job_array_evaluate_network.sh $SLURM_ARRAY_TASK_ID $gputouse $config completed!"

#Manually edit:
#iteration and shuffleindex in config.yaml file
#slurm parameters: -a -t
