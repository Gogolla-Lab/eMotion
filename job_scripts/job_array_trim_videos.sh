#!/bin/bash
#SBATCH -a 0-39
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 1:58:58
#SBATCH -c 4
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_array_trim_videos_%A_%a.out

module purge
source activate behaviour-switching

wd=$HOME/to_be_trimmed
outdir=$wd/outputs
mkdir -p "$outdir"

python behaviour-switching/worker_scripts/trim_videos_slurm_jobarray_wrapper.py "$wd" "$outdir" "$SLURM_ARRAY_TASK_ID"
