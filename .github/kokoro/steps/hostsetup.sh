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


if [[ $KOKORO_TYPE = continuous ]]; then
	echo
	echo "========================================"
	echo "Accessible secrets"
	echo "----------------------------------------"
	find $KOKORO_KEYSTORE_DIR

	echo
	echo "Configuring SSH client"
	echo "----------------------------------------"
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	find ~/.ssh

	cat ~/.ssh/config || true
	cat > ~/.ssh/config <<EOF
Host *
	BatchMode yes
	StrictHostKeyChecking no
	CheckHostIP no
	UserKnownHostsFile /dev/null

Host github.com
	User git
EOF
	chmod 600 ~/.ssh/config

	echo
	echo "Starting SSH agent and adding keys"
	echo "----------------------------------------"
	eval $(ssh-agent)
	ssh-add -l || true
	for KEY in $KOKORO_KEYSTORE_DIR/*; do
		chmod 600 $KEY
		ssh-add $KEY
	done
	ssh-add -l || true
	ssh-add -L || true

	echo
	echo "Testing connection to GitHub"
	echo "----------------------------------------"
	ssh -v git@github.com 2>&1 | tee /tmp/github.login
	if grep -q "successfully authenticated" /tmp/github.login; then
		echo "Successfully connected to GitHub!"
	else
		echo "Issue connecting to GitHub!"
		echo ":-("
		exit 1
	fi
	echo
	echo "----------------------------------------"
fi
