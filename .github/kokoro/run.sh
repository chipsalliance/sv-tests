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
	conda env create --file conf/environment.yml
	conda activate sv-test-env
	pip install -r conf/requirements.txt
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Running tests"
echo "----------------------------------------"
(
	source "$HOME/miniconda/etc/profile.d/conda.sh"
	hash -r
	conda activate sv-test-env

        make generate-tests
        make report USE_ALL_RUNNERS=1
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Copying tests logs"
echo "----------------------------------------"
(
        touch out/report/.nojekyll
	true
)
echo "----------------------------------------"
