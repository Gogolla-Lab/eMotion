#!/bin/bash
#SBATCH -p medium
#SBATCH -t 10:00
#SBATCH -c 2
#SBATCH -N 2-4
#SBATCH -C scratch
#SBATCH --qos=short
#SBATCH --mail-type=END
#SBATCH --mail-user=serce@neuro.mpg.de
#SBATCH -o trial_matmul_%J.out

module purge
module load python/3.6.3

scdir=/scratch/serce-trial-course
mkdir $scdir
cp ~/matrix.csv $scdir
cp ~/matmult.py $scdir
$scdir/matmult.py $scdir/matrix.csv $scdir/output.csv
cp $scdir/output.csv ~/
rm -rf $scdir

echo "vay anasini, job completed!"
