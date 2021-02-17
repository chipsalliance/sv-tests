#!/bin/bash

set -e
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda activate sv-test-env
hash -r
set -x

conda list
whereis x86_64-conda_cos6-linux-gnu-ld

make info
make -j2
