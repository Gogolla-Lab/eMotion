#!/bin/bash
#SBATCH -a 0-40
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 1:30:00
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH -o job_process_videos.sh_%J_%a.out

module purge
source activate behaviour-switching

sc_in_dir=/scratch/onur.serce
sc_out_dir=$sc_in_dir/outputs

python behaviour-switching/process_videos_slurm_jobarray_wrapper.py $sc_in_dir $sc_out_dir $SLURM_ARRAY_TASK_ID