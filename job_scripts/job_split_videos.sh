#!/bin/bash
#SBATCH -p medium
#SBATCH -t 5:00:00
#SBATCH -c 20
#SBATCH -C scratch
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_split_videos.sh_%J.out

module purge
source activate behaviour-switching

n_jobs=${1?Error: no n_jobs given}

scdir=/scratch/onur.serce/week2/to_be_split
outdir=$scdir/outputs

mkdir -p $outdir

python eMotion/preprocessing/split_videos.py $scdir $outdir "$n_jobs"