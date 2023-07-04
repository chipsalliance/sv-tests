#!/bin/bash

make $@ generate-tests
cp -ar ./out/report_*/logs ./out/
make $@ report
