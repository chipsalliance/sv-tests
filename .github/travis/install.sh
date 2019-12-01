#!/bin/bash

set -x
set -e

# Add local submodules
.github/add-local-submodules.sh "${TRAVIS_PULL_REQUEST_SLUG:-$TRAVIS_REPO_SLUG}"

# Get a conda environment
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda config --set always_yes yes --set changeps1 no
conda install -q setuptools
conda update -q conda
conda info -a
conda env create --file conf/environment.yml
conda activate sv-test-env

set +e
set +x
