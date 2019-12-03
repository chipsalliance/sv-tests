#!/bin/bash

set -e

cd github/$KOKORO_DIR/

source ./.github/kokoro/steps/hostsetup.sh
source ./.github/kokoro/steps/hostinfo.sh
source ./.github/kokoro/steps/git.sh

echo
echo "========================================"
echo "Installing dependencies"
echo "----------------------------------------"
(
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
	bash miniconda.sh -b -p $HOME/miniconda
	source "$HOME/miniconda/etc/profile.d/conda.sh"
	hash -r
	conda config --set always_yes yes --set changeps1 no
	conda install -q setuptools
	conda update -q conda
	conda info -a
	sed -e"s/^#  -/  -/" -i conf/environment.yml
	conda env create --file conf/environment.yml

	conda activate sv-test-env
	make USE_ALL_RUNNERS=1 info
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Running tests"
echo "----------------------------------------"
(
	export USE_CGROUP=sv-tests
	source "$HOME/miniconda/etc/profile.d/conda.sh"
	hash -r
	conda activate sv-test-env
	set -x
	make generate-tests

	set -x +e
	tmp=`mktemp`
	script --return --flush --command "make USE_ALL_RUNNERS=1 -j$CORES --keep-going tests" $tmp
	TESTS_RET=$?
	set +x -e

	if [[ $TESTS_RET != 0 ]]; then
		echo "----------------------------------------"
		echo "A failure occurred during test running."
		echo "----------------------------------------"
		make USE_ALL_RUNNERS=1 -j1 tests
		exit $TESTS_RET
	else
		echo "----------------------------------------"
		echo "Successful test running."
		echo "----------------------------------------"
	fi
	make report USE_ALL_RUNNERS=1
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Compressing tests logs"
echo "----------------------------------------"
(
	tar -jcvf sv-tests-out.tar.bz2 out/
	rm -rf out/
	mkdir out/
	mv sv-tests-out.tar.bz2 out/
	true
)
echo "----------------------------------------"
