#!/bin/bash

# BLAS++ runs try_compile + try_run during configure to detect Fortran
# mangling and integer size; on cross-compile the try_run cannot execute
# and configure fails. Pre-seed BLAS++'s internal cache variables so each
# *Finder/Config module short-circuits its check.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS} -Dblas_libraries_cached=${PREFIX}/lib/libblas${SHLIB_EXT}"
    export CMAKE_ARGS="${CMAKE_ARGS} -Dblas_found_cached=true"
    export CMAKE_ARGS="${CMAKE_ARGS} -Dblas_config_cache=${PREFIX}/lib/libblas${SHLIB_EXT}"
    export CMAKE_ARGS="${CMAKE_ARGS} -Dcblas_config_cache=${PREFIX}/lib/libblas${SHLIB_EXT} -Dblaspp_cblas_libraries=-lcblas"
fi

cmake -S . -B build             \
    -DCMAKE_INSTALL_LIBDIR=lib        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DBUILD_SHARED_LIBS=ON      \
    -Dbuild_tests=OFF           \
    -Duse_cmake_find_blas=ON    \
    -Duse_openmp=ON             \
    -Dgpu_backend=none          \
    -Dblas_int="int (LP64)"     \
    -DBLAS_LIBRARIES=${PREFIX}/lib/libblas${SHLIB_EXT} \
    -DLAPACK_LIBRARIES=${PREFIX}/lib/liblapack${SHLIB_EXT} \
    ${CMAKE_ARGS}

cmake --build build --parallel ${CPU_COUNT}

cmake --build build --target install
