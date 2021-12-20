#!/bin/bash

ANALYZER=$PWD"/tools/report_analyzer.py"
GRAPHER=$PWD"/tools/history-graph"
REPORTS_HISTORY=$(mktemp -d --suffix='.history')
OUT_DIR=$PWD"/out/report/"
COMPARE_REPORT=$OUT_DIR"/report.csv"
BASE_REPORT=$REPORTS_HISTORY"/report.csv"
CHANGES_SUMMARY_JSON=$OUT_DIR"/tests_summary.json"
CHANGES_SUMMARY_MD=$OUT_DIR"/tests_summary.md"

set -x
set -e

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
