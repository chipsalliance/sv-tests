#!/bin/bash

export CURRENT_PATH=$PWD

set -x

git clone \
  git@github.com:SymbiFlow/sv-tests-results.git \
  --single-branch \
  --depth 1 \
  --branch gh-pages \
  output

cd output

# XXX changing the branch here is only temporary, remove this line before merging
git checkout -b gh-pages-gha-test
# XXX

rm -rf *
cp -a $CURRENT_PATH/out/report/* -t .
touch .nojekyll
git add .

GIT_MESSAGE_FILE=/tmp/git-message
  cat > $GIT_MESSAGE_FILE <<EOF
Deploy $GIT_REF (build $GITHUB_RUN_ID)
Build from $GITHUB_SHA
EOF

git config user.name "SymbiFlow Robot"
git config user.email "foss-fpga-tools@google.com"

git commit -F $GIT_MESSAGE_FILE

git show -s

# XXX change it to git push just before merging
git push --set-upstream origin gh-pages-gha-test
# XXX
