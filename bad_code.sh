#!/bin/bash

#SBATCH --partition=teaching        # Submit to teaching partition
#SBATCH --account=teaching          # Specify project account
#SBATCH --nodes=1                   # Request one node
#SBATCH --ntasks-per-node=16        # Number of tasks per node
#SBATCH --cpus-per-task=1           # Allocate one core per task
#SBATCH --time=24:00:00             # Maximum runtime	
#SBATCH --job-name=bad_code         # Job name
#SBATCH --output=bad_code.out       # Output file name

# Exit immediately on errors, undefined variables, or pipeline failures
set -euo pipefail

# Print python version and node
echo "------------------------------------"
echo "Running on: $(hostname)             "
echo "Python Version: $(python3 --version)"
echo "------------------------------------"

# N value
N=100000000

# List of MPI process numbers
NPROCS="1 2 4 8 16"

# Table headings
echo "--------------------------------------------"
echo "P    N           Time(s)   Integral"
echo

# Loop through different MPI process counts
for P in $NPROCS; do
	
	export N=$N
	
	# Start Timing
	START=$(date +%s.%N)
	
	# Runs program
	RESULT=$(mpirun -np "$P" python3 bad_code.py 2>&1)
	
	# End Timing
	END=$(date +%s.%N)
	
	# Time taken for calculation
	TIME=$(echo "$END - $START" | bc)
	
	# Find line containing "Intergral" in RESULT and extract result
	INTEGRAL=$(echo "$RESULT" | awk '/Integral/{printf "%.14f", $2}')

	#Print results and align with table headings
	printf "%-4d %-11d %-9.2f %-1s\n" "$P" "$N" "$TIME" "$INTEGRAL"

done
