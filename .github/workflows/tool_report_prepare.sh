#!/bin/bash

OUT_DIR=$PWD"/out/report/"
COMPARE_REPORT=$OUT_DIR"/report.csv"

set -x
set -e

source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda activate sv-test-env
hash -r

mv $COMPARE_REPORT $OUT_DIR"/"$JOB_NAME"_report.csv"

set +e
set +x
