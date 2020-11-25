#!/bin/bash

set -e
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda activate sv-test-env
hash -r
set -x

make info
make -j2
