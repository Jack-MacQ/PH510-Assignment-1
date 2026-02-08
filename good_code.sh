#!/bin/bash

#SBATCH --partition=teaching        # Submit to teaching partition
#SBATCH --account=teaching          # Specify project account
#SBATCH --nodes=1                   # Request one node
#SBATCH --ntasks-per-node=16        # Number of tasks per node
#SBATCH --cpus-per-task=1           # Allocate one core per task
#SBATCH --time=24:00:00             # Maximum runtime	
#SBATCH --job-name=good_code        # Job name
#SBATCH --output=good_code.out      # Output file name

# Exit immediately on errors, undefined variables, or pipeline failures
set -euo pipefail

# Print python version and node
echo "------------------------------------"
echo "Running on: $(hostname)             "
echo "Python Version: $(python3 --version)"
echo "------------------------------------"

# List of MPI process numbers
NPROCS="1 2 4 8 16"

# Loop through different MPI process counts
for P in $NPROCS; do
	
	echo "-----------------------------"
	echo "Running with $P MPI processes"
	echo "-----------------------------"

	mpirun -np "$P" python3 good_code.py

	echo

done
