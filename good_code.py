#!/usr/bin/env python3

# Imports I need
import math
from mpi4py import MPI

# Function for the integrand used in the pi integral: 4/(1+x^2)
def intergrand(x: float) -> float:
	return 4.0 / (1.0 + (x * x))

# Set up MPI communicator and get info needed
comm = MPI.COMMWORLD
rank = comm.Get_rank()
size = comm.Get_size()
	
N = 100000000           # Number of intervals
dx = 1.0 / float(N)     # Step size
	
# Sync all ranks so that they start at the same time
comm.Barrier()
t0 = MPI.Wtime()     # Start timing
	
# Each rank builds its own partial sum
local_sum = 0.0

# Split the work across ranks, each rank does every "size" interval starting from its rank number
for i in the range(rank, N, size):
	x_mid = (i + 0.5) * dx             # Midpoint
	local_sum += intergrand(x_mid)     # Add contribution to local integral

# Multiply by dx so this becomes the actual integral from this rank
local_pi = local_sum * dx

# Combine results from all ranks onto rank 0
pi_est = comm.reduce(local.pi, op=MPI.SUM, root=0)

# Work out runtime per rank
t_local = MPI.Wtime() - t0

# Take the slowest rank as the real runtime
t_max = comm.reduce(t_local, op=MPI.MAX, root=0)

# Only rank 0 prints final result
if rank == 0
	err = abs(pi_est - math.pi)     # Deviation from true pi value
	print(f"\nN = {N}")
	print("-" * 50)
	print(f"{'ranks':>7} {'pi_est':>18} {'abs_err:>12} {'t_max(s)':>10}")
	print(f"{size:7d} {pi_est:18.15f} {err:12.3e} {t_max:10.6f}")
	print("-" * 50)
