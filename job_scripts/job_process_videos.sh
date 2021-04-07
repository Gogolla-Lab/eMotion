#!/bin/bash
#SBATCH -p medium
#SBATCH -t 12:00:00
#SBATCH -c 16
#SBATCH -C scratch
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o job_process_videos.sh_%J.out

module purge
source activate behaviour-switching

n_jobs=${1?Error: no n_jobs given}

h_in_dir=$HOME/to_be_processed #CHANGE THIS LINE!
sc_in_dir=/scratch/onur.serce
sc_out_dir=$sc_in_dir/outputs
h_out_dir=$h_in_dir/outputs

mkdir -p $sc_out_dir
cp "$h_in_dir"/* $sc_in_dir

python behaviour-switching/preprocessing/process_videos.py $sc_in_dir $sc_out_dir "$n_jobs"

mkdir "$h_out_dir"
cp $sc_out_dir/* "$HOME"/"$h_out_dir"
