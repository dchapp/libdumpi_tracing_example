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
mkdir build
./bootstrap.sh
./configure --prefix=$HOME/sst-dumpi/build --enable-libdumpi --with-mpi-version=3 CFLAGS=-I/usr/include/mpich LDFLAGS=-L/usr/lib/mpich/lib LIBS=-lmpi
make 
make install

# Compile and link test program
rm -rf $HOME/libdumpi_tracing_example
cd $HOME
git clone https://github.com/dchapp/libdumpi_tracing_example.git
cd libdumpi_tracing_example/src
make
ldd ring.exe



