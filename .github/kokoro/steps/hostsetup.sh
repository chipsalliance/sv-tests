#!/bin/bash

set -e

echo
echo "========================================"
echo "Host updating packages"
echo "----------------------------------------"
sudo apt-get update
echo "----------------------------------------"

echo
echo "========================================"
echo "Host remove packages"
echo "----------------------------------------"
sudo apt-get remove -y \
	python-pytest \

echo "----------------------------------------"
echo
echo "========================================"
echo "Host install packages"
echo "----------------------------------------"
sudo apt-get install -y \
        bison \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        flex \
        git \
	wget \

echo "----------------------------------------"
