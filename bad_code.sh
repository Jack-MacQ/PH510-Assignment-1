#!/bin/bash

#SBATCH --partition=teaching     # Submit to teaching partition
#SBATCH --account=teaching       # Specify project account
#SBATCH --nodes=1                # Request one node
#SBATCH --ntasks-per-node=16     # Number of tasks per node
#SBATCH --cpus-per-task=1        # Allocate one core per task
#SBATCH --time=01:00:00          # Maximum runtime	
#SBATCH --job-name=bad_code      # Job name
#SBATCH --output=bad_code.out    # Output file name

module load mpi

# Exit immediately on errors, undefined variables, or pipeline failures
set -euo pipefail

badcode="bad_code.py"

# Print python version
echo "------------------------------------"
echo "Python Version: $(python3 --version)"
echo "------------------------------------"

# N value as defined in bad_code.py
N=100000000

# List of MPI process numbers
NPROCS="1 2 4 8 16"

# Table headings
echo "--------------------------------"
echo "P     N     Time(s)     Integral"
echo

# Loop through different MPI process counts
for P in $NPROCS; do
	
	export N=$N
	
	# Runs program and measures runtime
	RESULT=$(/usr/bin/time -f "%e" srun -n $P python3 $badcode 2>&1)
	
	# Extract the last line of "RESULT" (runtime in seconds)
	TIME=$(echo "$RESULT" | tail -n 1)
	
	# Find line containing "Intergral" in RESULT and extract result
	INTEGRAL=$(echo "$RESULT" | grep Integral | awk '{print $2}')
	if [ -z "${INTEGRAL}" ]; then
		INTEGRAL="NA"
	fi
	
	#Print results and align with table headings
	printf "%-8s %-11s %-12s %-10s\n" "$P" "$N" "$TIME" "$INTEGRAL"
	
	# If run fails, print the error output
	if [ "$RC" -ne 0 ]; then
		echo "-------------------------------------------------"
		echo " Run failed for P=$P (exit code $RC). Output was:"
		echo " $RESULT"
		echo "-------------------------------------------------"
	
		break     # Stop after first failure
	fi
done
