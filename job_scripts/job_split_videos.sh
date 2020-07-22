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

scdir=/scratch/onur.serce/temp_process
outdir=/scratch/onur.serce/temp_process/outputs

mkdir -p $outdir
cp $HOME/to_be_split/* $scdir

python behaviour-switching/split_videos.py $scdir $outdir $n_jobs

mkdir $HOME/to_be_split/outputs
cp outdir/* $HOME/to_be_split/outputs

#rm -rf $scdir
