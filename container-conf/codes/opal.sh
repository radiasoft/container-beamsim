#!/bin/bash
#codes_dependencies common
# original source has bad ssl cert:
# https://amas.psi.ch/H5hut/raw-attachment/wiki/DownloadSources/H5hut-1.99.13.tar.gz
# Doc: https://amas.psi.ch/H5hut/wiki/H5hutInstall
codes_download_foss H5hut-1.99.13.tar.gz
patch -p0 < "$codes_data_src_dir"/opal/H5hut-1.99.13.patch
./autogen.sh
CC=mpicc CXX=mpicxx ./configure \
  --enable-parallel \
  --prefix="$(pyenv prefix)" \
  --with-pic
#  --enable-shared
make install
cd ..

#http://glaros.dtc.umn.edu/gkhome/metis/parmetis/download
codes_download_foss parmetis-4.0.3.tar.gz
make config shared=1 prefix="$(pyenv prefix)"
make install
cd ..

#http://glaros.dtc.umn.edu/gkhome/metis/metis/download
codes_download_foss metis-5.1.0.tar.gz
make config shared=1 prefix="$(pyenv prefix)"
make install
cd ..

# https://trilinos.org/oldsite/download/download.html
codes_download_foss trilinos-12.10.1-Source.tar.gz
mkdir build
cd build
CC=mpicc CXX=mpicxx cmake \
  -DCMAKE_INSTALL_PREFIX:PATH="$(pyenv prefix)" \
  -DCMAKE_CXX_FLAGS:STRING="-DMPICH_IGNORE_CXX_SEEK -fPIC" \
  -DCMAKE_C_FLAGS:STRING="-DMPICH_IGNORE_CXX_SEEK -fPIC" \
  -DCMAKE_CXX_STANDARD:STRING="11" \
  -DCMAKE_Fortran_FLAGS:STRING="-fPIC" \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DMETIS_LIBRARY_DIRS="$(pyenv prefix)/lib" \
  -DTPL_ENABLE_DLlib:BOOL=OFF \
  -DTPL_ENABLE_QT:BOOL=OFF \
  -DTPL_ENABLE_MPI:BOOL=ON \
  -DTPL_ENABLE_BLAS:BOOL=ON \
  -DTPL_ENABLE_LAPACK:BOOL=ON \
  -DTPL_ENABLE_METIS:BOOL=ON \
  -DTPL_ENABLE_ParMETIS:BOOL=ON \
  -DTrilinos_ENABLE_Amesos:BOOL=ON \
  -DTrilinos_ENABLE_Amesos2:BOOL=ON \
  -DTrilinos_ENABLE_AztecOO:BOOL=ON \
  -DTrilinos_ENABLE_Belos:BOOL=ON \
  -DTrilinos_ENABLE_Epetra:BOOL=ON \
  -DTrilinos_ENABLE_EpetraExt:BOOL=ON \
  -DTrilinos_ENABLE_Galeri:BOOL=ON \
  -DTrilinos_ENABLE_Ifpack:BOOL=ON \
  -DTrilinos_ENABLE_Isorropia:BOOL=ON \
  -DTrilinos_ENABLE_ML:BOOL=ON \
  -DTrilinos_ENABLE_NOX:BOOL=ON \
  -DTrilinos_ENABLE_Optika:BOOL=OFF \
  -DTrilinos_ENABLE_Teuchos:BOOL=ON \
  -DTrilinos_ENABLE_Tpetra:BOOL=ON \
  -DTrilinos_ENABLE_TESTS:BOOL=OFF \
  ..
make install
cd ../..

#codes_download https://gitlab.psi.ch/OPAL/src.git OPAL-1.6
# The git repo is 1.6G, and takes a long time to load. The tgz is 3M
codes_download_foss OPAL-1.6.tar.gz
mkdir build
cd build

CMAKE_PREFIX_PATH="$(pyenv prefix)" H5HUT_PREFIX="$(pyenv prefix)" \
    HDF5_INCLUDE_DIR=/usr/include \
    HDF5_LIBRARY_DIR=/usr/lib64/openmpi/lib \
    CC=mpicc CXX=mpicxx \
    cmake \
    --prefix="$(pyenv prefix)" \
    -DCMAKE_INSTALL_PREFIX="$(pyenv prefix)" \
    -DENABLE_SAAMG_SOLVER=TRUE \
    ..
make install
cd ../..
