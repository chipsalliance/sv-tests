#!/bin/bash

# Compressing tests logs
tar -jcf sv-tests-out.tar.bz2 out/
rm -rf out/
mkdir out/
mv sv-tests-out.tar.bz2 out/
