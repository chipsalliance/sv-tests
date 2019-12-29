#!/bin/bash

set -e

echo
echo "========================================"
echo "Removing older packages"
echo "----------------------------------------"
sudo apt-get remove -y cmake
echo "----------------------------------------"

echo
echo "========================================"
echo "Host adding PPAs"
echo "----------------------------------------"
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main'
echo "----------------------------------------"

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


sudo apt-get autoremove -y

echo "----------------------------------------"
echo
echo "========================================"
echo "Host install packages"
echo "----------------------------------------"
sudo apt-get install -y \
        bash \
        bison \
        build-essential \
        ca-certificates \
        clang-format \
        cgroup-tools \
        cmake \
        colordiff \
        coreutils \
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
