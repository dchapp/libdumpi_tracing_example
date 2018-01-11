#!/bin/bash

# This script does the following: 
# 1. Clone SST-DUMPI from its main git repo
# 2. Bootstrap, configure, and make the libdumpi tracing library
# 3. Compile a simple, tiny MPI C program and link it with libdumpi
# 4. Inspect the resulting DUMPI trace files

# Clone SST-DUMPI 
rm -rf $HOME/sst-dumpi
cd $HOME
git clone https://github.com/sstsimulator/sst-dumpi.git
cd sst-dumpi

# Bootstrap, configure, and make
# Notes:
# - In priciple, we should not have to explicitly specify CFLAGS, LDFLAGS, and 
#   LIBS here. I'm not exactly sure why the configure script was failing without
#   these, but adding them seems to fix it. 
mkdir build
./bootstrap.sh
./configure --prefix=$HOME/sst-dumpi/build --enable-libdumpi --with-mpi-version=3 CFLAGS=-I/usr/include/mpich LDFLAGS=-L/usr/lib/mpich/lib LIBS=-lmpi
make 
make install

# Compile and link test program
# Notes:
# - Adding the path where the DUMPI shared libs are installed to your 
#   LD_LIBRARY_PATH is necessary if you don't want to use the LD_PRELOAD trick.
#   I explicitly add this path to your LD_LIBRARY_PATH here, but you'll probably
#   want to add it to your .bashrc at some point
# - What LD_PRELOAD trick? Basically you can put LD_PRELOAD=$SOME_LIB before a
#   command that executes or schedules an execution (e.g., srun) and interpose
#   whatever is in $SOME_LIB between the application code and the library code
# - See: https://rafalcieslak.wordpress.com/2013/04/02/dynamic-linker-tricks-using-ld_preload-to-cheat-inject-features-and-investigate-programs/
export LD_LIBRARY_PATH=$HOME/sst-dumpi/build/lib:$LD_LIBRARY_PATH
cd $HOME/repos/libdumpi_tracing_example/src
make

# Run it
# Notes:
# - Since we are using MPICH as our MPI implementation, we must pass --mpi=pmi2
#   Slurm so it knows to using the Process Management Interface (pmi) to spin up
#   MPI processes. If you don't include this, only MPI process 0 will start and 
#   your program will hang.
srun -N1 -n4 --mpi=pmi2 ./ring.exe 4



