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
        cgroup-tools \
        cmake \
        curl \
        flex \
        git \
        wget \

echo "----------------------------------------"
echo
echo "========================================"
echo "Creating cgroup to bse used"
echo "----------------------------------------"
sudo cgcreate -a $(whoami) -t $(whoami) -g memory,cpu:sv-tests
ls -l /sys/fs/cgroup/*/sv-tests
echo "----------------------------------------"
