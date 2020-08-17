#!/bin/bash
#SBATCH -p medium
#SBATCH -t 05:00
#SBATCH -c 2
#SBATCH -C scratch
#SBATCH -o job_split_videos.sh_%J.out

module purge
source activate behaviour-switching

extension=${1?Error: no extension given}
scdir=/scratch/onur.serce/all_outputs_main

python behaviour-switching/utility_functions.py $scdir