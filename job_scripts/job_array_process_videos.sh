#!/bin/bash
#SBATCH -a 0-154
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 6:00:00
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_process_videos.sh_%A_%a.out

module purge
source activate behaviour-switching

sc_in_dir=/scratch/onur.serce/all_videos
sc_out_dir=$sc_in_dir/processed

python behaviour-switching/process_videos_slurm_jobarray_wrapper.py $sc_in_dir $sc_out_dir $SLURM_ARRAY_TASK_ID
