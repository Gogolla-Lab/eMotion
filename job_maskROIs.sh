#!/bin/bash
#SBATCH -p medium
#SBATCH -t 6:00:00
#SBATCH -n 16
#SBATCH -c 8
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_maskROIs.sh_%J.out

module purge
source activate behaviour-switching

n_jobs=${1?Error: no n_jobs given}

scdir=/scratch/onur.serce/temp_process
outdir=/scratch/onur.serce/temp_process/outputs
mkdir -p $scdir
cp ~/to_be_masked/* $scdir

python maskROIs.py $scdir $outdir $n_jobs

mkdir ~/to_be_masked/outputs
cp outdir/* ~/to_be_masked/outputs
rm -rf $scdir
