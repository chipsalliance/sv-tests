#!/bin/bash
set -euxo pipefail
make $@ generate-tests
cp -ar ./out/report_*/logs ./out/
make $@ report
