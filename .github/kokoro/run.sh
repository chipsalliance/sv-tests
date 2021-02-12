#!/bin/bash

set -e

cd github/$KOKORO_DIR/

source ./.github/kokoro/steps/hostsetup.sh
source ./.github/kokoro/steps/hostinfo.sh
source ./.github/kokoro/steps/git.sh

export GIT_CHECKOUT=$PWD
export GIT_DESCRIBE=$(git describe --match v*)

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
	set +x +e
	# Limit per runner memory to a fraction of the physically available memory as
	# there is no swap, but we don't want it to OOM the toplevel make process
	export USE_CGROUP=sv-tests
	export CGROUP_MAX_MEMORY=$(free -b | awk '/Mem:/ { printf("%.0f", $2 * 0.7);}')

	source "$HOME/miniconda/etc/profile.d/conda.sh"
	hash -r
	conda activate sv-test-env
	make generate-tests

	tmp=`mktemp`
	script --return --flush --command "make USE_ALL_RUNNERS=1 -j$CORES --keep-going tests" $tmp
	TESTS_RET=$?

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
		make USE_ALL_RUNNERS=1 --question tests
		TESTS_FINISHED=$?

		if [[ $TESTS_FINISHED != 0 ]]; then
			echo "----------------------------------------"
			echo "Tasks still left to run after success?"
			echo "----------------------------------------"
			make USE_ALL_RUNNERS=1 -j1 tests
			#exit 1
		fi

	fi
	make report USE_ALL_RUNNERS=1
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Running Analysis"
echo "----------------------------------------"
{
	ANALYZER=$GIT_CHECKOUT"/tools/report_analyzer.py"
	OUT_DIR=$GIT_CHECKOUT"/out/report/"
	COMPARE_REPORT=$OUT_DIR"/report.csv"
	BASE_REPORT=$OUT_DIR"/base_report.csv"
	CHANGES_SUMMARY_JSON=$OUT_DIR"/tests_summary.json"
	CHANGES_SUMMARY_MD=$OUT_DIR"/tests_summary.md"

	set +x +e
	source "$HOME/miniconda/etc/profile.d/conda.sh"
	hash -r
	conda activate sv-test-env

	# Get base report from sv-tests master run
	wget https://symbiflow.github.io/sv-tests-results/report.csv -O $BASE_REPORT

	python $ANALYZER $COMPARE_REPORT $BASE_REPORT -o $CHANGES_SUMMARY_JSON -t $CHANGES_SUMMARY_MD
}
echo "----------------------------------------"

if [[ $KOKORO_TYPE = continuous ]]; then
	#   - "make report USE_ALL_RUNNERS=1"
	#   - "touch out/report/.nojekyll"
	# deploy:
	#   provider: pages
	#   github_token: $GH_TOKEN
	#   skip_cleanup: true
	#   keep_history: true
	#   local_dir: out/report
	#   verbose: true
	#   on:
	#     branch: master
	echo
	echo "========================================"
	echo "Deploying sv-tests report to GitHub pages"
	echo "----------------------------------------"
	(
		cd /tmp
		echo
		echo "Cloning the repo to deploy..."
		git clone \
			git+ssh://github.com/SymbiFlow/sv-tests-results.git \
			--reference $GIT_CHECKOUT \
			--single-branch \
			--depth 1 \
			--branch gh-pages \
			output
		cd output
		echo
		echo "Removing old content..."
		rm -rf *
		echo
		echo "Copying new content..."
		cp -a $GIT_CHECKOUT/out/report/* -t .
		touch .nojekyll
		echo
		echo "Adding the content..."
		git add .
		echo

		echo "Committing..."
		GIT_MESSAGE_FILE=/tmp/git-message
		cat > $GIT_MESSAGE_FILE <<EOF
Deploy $GIT_DESCRIBE (build $KOKORO_BUILD_ID)

Build from $KOKORO_GITHUB_COMMIT_URL
EOF
		git commit \
			-F $GIT_MESSAGE_FILE \
			--author "SymbiFlow Robot <foss-fpga-tools@google.com>"
		echo
		echo "Pushing..."
		git push \
			git+ssh://github.com/SymbiFlow/sv-tests-results.git \
			gh-pages
	)
	echo "----------------------------------------"
fi

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
