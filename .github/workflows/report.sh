#!/bin/bash

# Add local submodules
git submodule update --init --recursive

make $@ generate-tests
cp -ar ./out/report_*/logs ./out/
make $@ report
