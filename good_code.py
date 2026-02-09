#!/usr/bin/env python3

"""MPI midpoint-rule estimation of pi using integration

License: MIT

Output:
    Table showing:
    - number of ranks
    - pi results calculated
    - error vs math.pi
    - runtime

Designed to improve calculation speed and accuracy with parallelisation

"""

# Imports
import math
from mpi4py import MPI     # pylint:disable=no-name-in-module

N = 100000000           # Number of intervals
dx = 1.0 / float(N)     # Step size

def intergrand(x: float) -> float:
    """Function for the intergrand used in the pi integral: 4/(1+x^2)"""
    return 4.0 / (1.0 + (x * x))

def main() -> None:
    """Run the calculation and print results"""

    # Set up MPI communicator and get info needed
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    size = comm.Get_size()

    # Sync all ranks so that they start at the same time
    comm.Barrier()
    t0 = MPI.Wtime()     # Start timing

    # Each rank builds its own partial sum
    local_sum = 0.0

    # Store values for fsum later
    terms = []
    append = terms.append

    # Split the work across ranks, each rank does every "size" interval starting from its rank value
    for i in range(rank, N, size):
        x_mid = (i + 0.5) * dx             # Midpoint
        append(intergrand(x_mid))

    # Sum using float summation to improve accuracy
    local_sum = math.fsum(terms)

    # Multiply by dx so this becomes the actual integral from this rank
    local_pi = local_sum * dx

    # Combine results from all ranks onto rank 0
    pi_est = comm.reduce(local_pi, op=MPI.SUM, root=0)

    # Work out runtime per rank
    t_local = MPI.Wtime() - t0

    # Take the slowest rank as the real runtime
    t_max = comm.reduce(t_local, op=MPI.MAX, root=0)

    # Only rank 0 prints final result
    if rank == 0:
        err = abs(pi_est - math.pi)     # Deviation from true pi value
        print(f"{size:<4d} {pi_est:19.14f} {err:<14.3e} {t_max:<12.6f}")

if __name__ == "__main__":
    main()
