#!/bin/bash
#SBATCH -p medium
#SBATCH --qos=short
#SBATCH -t 10:00
#SBATCH -c 1
#SBATCH -C scratch
#SBATCH -o job_rename_files_%J.out


module purge
source activate behaviour-switching

rm -f "$HOME"/job_array_process_videos*.out

extension=${1?Error: no extension given}
scdir=/scratch/onur.serce/all_videos/processed

python eMotion/utility_functions.py $scdir "$extension"
