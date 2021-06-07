#!/bin/bash

git clone \
  git+ssh://github.com/SymbiFlow/sv-tests-results.git \
  --reference ./ \
  --single-branch \
  --branch gh-pages \
  output
cd output
cp -a ./out/report/* -t .
ls -la
