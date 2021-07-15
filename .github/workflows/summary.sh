#!/bin/bash

ANALYZER=$PWD"/tools/report_analyzer.py"
OUT_DIR=$PWD"/out/report/"
COMPARE_REPORT=$OUT_DIR"/report.csv"
BASE_REPORT=$OUT_DIR"/base_report.csv"
CHANGES_SUMMARY_JSON=$OUT_DIR"/tests_summary.json"
CHANGES_SUMMARY_MD=$OUT_DIR"/tests_summary.md"

set -x
set -e

# Get a conda environment
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source "$HOME/miniconda/etc/profile.d/conda.sh"
hash -r
conda config --set always_yes yes --set changeps1 no

conda env create --file conf/environment.yml
conda activate sv-test-env
hash -r
conda info -a

# Get base report from sv-tests master run
wget https://chipsalliance.github.io/sv-tests-results/report.csv -O $BASE_REPORT

# Delete headers from all report.csv
for file in $(find ./out/report_* -name "*.csv" -print); do
	sed -i.backup 1,1d $file
done

# concatenate test reports
cat $(find ./out/report_* -name "*.csv" -print) >> $COMPARE_REPORT

# Insert header at the first line of concatenated report
sed -i 1i\ $(head -1 $(find ./out/report_* -name "*.csv.backup" -print -quit)) $COMPARE_REPORT

python $ANALYZER $COMPARE_REPORT $BASE_REPORT -o $CHANGES_SUMMARY_JSON -t $CHANGES_SUMMARY_MD

set +e
set +x

