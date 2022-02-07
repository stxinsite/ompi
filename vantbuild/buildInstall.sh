#!/bin/bash

# make sure we pick up the default profile
if [ -f "/etc/profile" ] ; then
    source /etc/profile
fi

export CUDA_HOME=/usr/local/cuda-11.4
module load cuda/11.4
module load webproxy

set -e 

printenv | sort

pushd $thisdir/..

if [ -z $WORKSPACE ]; then
    echo \$WORKSPACE not defined, exitting.
    popd
    exit 1
fi

# Use Jenkins environment variable if possible, otherwise use current local
# branch information (can be wrong if Jenkins doesn't pull all git data)
branch=$GIT_BRANCH
if [ -z $branch ]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
fi

vtag=$(git describe --abbrev=0 --tags 2>&1)
if [ -z $vtag ]; then
	echo "Version tags not available in master/main branch, aborting install"
    popd
    exit 1
fi

if [ "$vtag" == 'fatal: No names found, cannot describe anything.' ]; then
	echo "Attempting to install an untagged branch, aborting install"
    popd
    exit 1
fi

ncommit=$(git log $vtag..HEAD --oneline | wc -l)
if [[ $ncommit -ne 0 ]]; then
	echo "Latest version has commits beyond the newest tag, aborting install"
	#popd
	#exit 1
fi

echo "vtag: " $vtag

install_path=$(echo $1 | sed "s:_latest:/releases:")/$vtag

echo "install path: " $install_path

set -x

./configure --prefix=$install_path --enable-mpi-cxx --enable-mpi-fortran --with-slurm --with-pmix --with-cuda=$CUDA_HOME |& tee config.out

make -j 12 |& tee make.out


mkdir -p $install_path
make install |& tee install.out

popd

