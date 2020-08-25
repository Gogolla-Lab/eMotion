#!/bin/bash
#SBATCH -p medium
#SBATCH -t 5:00:00
#SBATCH -c 16
#SBATCH -C scratch
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_maskROIs.sh_%J.out

module purge
source activate behaviour-switching

n_jobs=${1?Error: no n_jobs given}

scdir=/scratch/onur.serce/temp_process
outdir=/scratch/onur.serce/temp_process/outputs

mkdir -p $outdir
cp "$HOME"/to_be_masked/* $scdir

python behaviour-switching/maskROIs.py $scdir $outdir "$n_jobs"

mkdir "$HOME"/to_be_masked/outputs
cp outdir/* "$HOME"/to_be_masked/outputs

#rm -rf $scdir
