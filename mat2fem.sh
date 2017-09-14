#!/bin/bash -l

#SBATCH --job-name=mat2fem
#SBATCH --account=nn9249k
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=16G
#SBATCH --output=mat2fem_out.txt
#SBATCH --error=mat2fem_err.txt

source /cluster/bin/jobsetup
module load matlab
module load python2
module load gcc

python mat2fem.py
