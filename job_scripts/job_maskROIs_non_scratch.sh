#!/bin/bash
#SBATCH -p medium
#SBATCH -t 5:00:00
#SBATCH -c 16
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_maskROIs_non_scratch.sh_%J.out

module purge
source activate behaviour-switching

wd=$HOME/to_be_masked
outdir=$HOME/to_be_masked/outputs
mkdir -p "$outdir"

n_jobs=${1?Error: no n_jobs given}

python behaviour-switching/maskROIs.py "$wd" "$outdir" "$n_jobs"