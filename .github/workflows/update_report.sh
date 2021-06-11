#!/bin/bash

export GIT_DESCRIBE=$(git describe --match v*)
export CURRENT_PATH=$PWD

git clone \
  git@github.com:SymbiFlow/sv-tests-results.git \
  --single-branch \
  --depth 1 \
  --branch gh-pages \
  output

cd output
rm -rf *
cp -a $CURRENT_PATH/out/report/* -t .
touch .nojekyll
git add .

echo "$GIT_DESCRIBE"
echo "$GIT_REF"

GIT_MESSAGE_FILE=/tmp/git-message
  cat > $GIT_MESSAGE_FILE <<EOF
Deploy $GIT_REF (build $GITHUB_RUN_ID)
Build from $GITHUB_SHA
EOF

git commit \
  -F $GIT_MESSAGE_FILE \
  --author "SymbiFlow Robot <foss-fpga-tools@google.com>"

git show -s
git status
