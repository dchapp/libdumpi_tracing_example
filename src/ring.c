#include<stdlib.h>
#include<stdio.h>
#include<mpi.h>
#include<math.h>

void do_comm(int rank, int comm_size) {
    printf("Proc %d Entering do_comm\n", rank);
    int token;
    if (rank != 0) {
        printf("Process %d posting receive for message from process %d\n", rank, rank-1);
        MPI_Recv(&token, 1, MPI_INT, rank - 1, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Process %d received token %d from process %d\n",
               rank, token, rank - 1);
    } else {
        // Set the token's value if you are process 0
        printf("Process %d setting token value\n", rank);
        token = -1;
    }
    MPI_Send(&token, 1, MPI_INT, (rank + 1) % comm_size,
             0, MPI_COMM_WORLD);

    // Now process 0 can receive from the last process.
    if (rank == 0) {
        MPI_Recv(&token, 1, MPI_INT, comm_size - 1, 0,
                 MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        printf("Process %d received token %d from process %d\n",
               rank, token, comm_size - 1);
    }
}

int main(int argc, char** argv) {
    int iters = atoi(argv[1]);

    int mpi_err, rank, comm_size;
    mpi_err = MPI_Init(&argc, &argv);
    mpi_err = MPI_Comm_size(MPI_COMM_WORLD, &comm_size);
    mpi_err = MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    
    int i;
    for (i=0; i<iters; i++) {
        if (rank == 0) {
            printf("ITER %d\n", i);
        }
        do_comm(rank, comm_size);
    }


    // Post nonblocking receive for 

    mpi_err = MPI_Finalize();
		if (mpi_err != 0) {
			return 1;
		}
    return 0;
}
