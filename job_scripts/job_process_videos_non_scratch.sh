#!/bin/bash
#SBATCH -p medium
#SBATCH -t 12:00:00
#SBATCH -c 16
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_process_videos.sh_%J.out

module purge
source activate behaviour-switching

n_jobs=${1?Error: no n_jobs given}

wd=$HOME/to_be_processed
outdir=$HOME/to_be_processed/outputs
mkdir -p "$outdir"

python eMotion/preprocessing/process_videos.py "$wd" "$outdir" "$n_jobs"