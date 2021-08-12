#!/bin/bash

ANALYZER=$PWD"/tools/report_analyzer.py"
GRAPHER=$PWD"/tools/history-graph"
OUT_DIR=$PWD"/out/report/"
COMPARE_REPORT=$OUT_DIR"/report.csv"
REPORTS_HISTORY=$OUT_DIR"/history"
BASE_REPORT=$OUT_DIR"/history/report.csv"
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
git clone https://github.com/chipsalliance/sv-tests-results.git --depth 120 $REPORTS_HISTORY

# Delete headers from all report.csv
for file in $(find ./out/report_* -name "*.csv" -print); do
	sed -i.backup 1,1d $file
done

# concatenate test reports
cat $(find ./out/report_* -name "*.csv" -print) >> $COMPARE_REPORT

# Insert header at the first line of concatenated report
sed -i 1i\ $(head -1 $(find ./out/report_* -name "*.csv.backup" -print -quit)) $COMPARE_REPORT

python $ANALYZER $COMPARE_REPORT $BASE_REPORT -o $CHANGES_SUMMARY_JSON -t $CHANGES_SUMMARY_MD

# generate history graph
python $GRAPHER -n 120 -r $REPORTS_HISTORY

set +e
set +x

