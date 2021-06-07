#!/bin/bash

git clone \
  git+ssh://github.com/SymbiFlow/sv-tests-results.git \
  --single-branch \
  --depth 1 \
  --branch gh-pages \
  output
cd output
cp -a ./out/report/* -t .
ls -la
