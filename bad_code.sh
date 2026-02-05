#!/bin/bash

# Submit to teaching partition
#SBATCH --partition=teaching

# Specify project account
#SBATCH --account=teaching

# Request one node
#SBATCH --nodes=1

# Number of tasks per node
#SBATCH --ntasks-per-node=16

# Allocate one core per task
#SBATCH --cpus-per-task=1

# Maximum runtime
#SBATCH --time=01:00:00 	

# Job and output file name
#SBATCH --job-name=bad_code
#SBATCH --output=bad_code.out

# Exit immediately on errors, undefined variables, or pipeline failures
set -euo pipefail

badcode = "bad_code.py"

# Print python version
echo "------------------------------------"
echo "Python Version: $(python3 --version)"
echo "------------------------------------"

# N value as defined in bad_code.py
N = 100000000

# List of MPI process numbers
NPROCS = "1 2 4 8 16"

# Table headings
echo "--------------------------------"
echo "P     N     Time(s)     Integral"
echo

# Loop through different MPI process counts
for P in $NPROCS; do
	
	export N=$N
	
	# Runs program and measures runtime
	RESULT=$(/usr/bin/time -f "%e" srun -n $P python 3 $badcode 2>&1)
	
	# Extract the last line of "RESULT" (runtime in seconds)
	TIME=$(echo "$RESULT" | tail -n 1)
	
	# Find line containing "Intergral" in RESULT and extract result
	INTEGRAL=$(echo "$RESULT" | grep Integral | awk '{print $2}')
	
	#Print results and align with table headings
	printf "%-8s %-11s %-12s %-10s\n" "$P" "$N" "$TIME" "$INTEGRAL"

done
