#!/bin/bash

set -x
set -e

# Add local submodules
git submodule update --init --recursive

# Get a conda environment
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda config --set always_yes yes --set changeps1 no

# Replace all spaces with \|
USE_CHANNEL=${USE_CHANNEL// /\\|}
# Uncomment the correct channels
sed -e"/^#  - $USE_CHANNEL$/ { s/^#// }" -i conf/environment.yml
# Uncomment the correct runner
sed -e"/^#  - .*::$JOB_NAME$/ { s/^#// }" -i conf/environment.yml
# For verilator, we need to explicitly add gxx dependency
# otherwise conda will download older version of gxx
# and verilator won't be able to find gxx binary
if [ "$JOB_NAME" = "verilator" ] || [ "$JOB_NAME" = "verilator-uhdm" ]; then
  sed -e"/^#  - gxx_impl_linux-64$/ { s/^#// }" -i conf/environment.yml
fi
git diff

conda env create --file conf/environment.yml
conda activate sv-test-env
hash -r
conda info -a

# Generate the tests
make $@ generate-tests
make $@ info

set +e
set +x
