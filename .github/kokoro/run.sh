#!/bin/bash

set -e

cd github/$KOKORO_DIR/

source ./.github/kokoro/steps/hostsetup.sh
source ./.github/kokoro/steps/hostinfo.sh
source ./.github/kokoro/steps/git.sh

echo
echo "========================================"
echo "Running tests"
echo "----------------------------------------"
(
	true
)
echo "----------------------------------------"

echo
echo "========================================"
echo "Copying tests logs"
echo "----------------------------------------"
(
	true
)
echo "----------------------------------------"
