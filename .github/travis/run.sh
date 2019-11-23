#!/bin/bash

set -x
set -e
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda activate sv-test-env
hash -r

make info
make -j2
