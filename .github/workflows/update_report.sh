#!/bin/bash

export CURRENT_PATH=$PWD

git clone \
  git@github.com:SymbiFlow/sv-tests-results.git \
  --single-branch \
  --depth 1 \
  --branch gh-pages \
  output
cd output
pwd
cp -a $CURRENT_PATH/out/report/* -t .
ls -la
