#!/bin/bash

set -e

# Disable prompting for passwords - works with git version 2.3 or above
export GIT_TERMINAL_PROMPT=0
# Harder core version of disabling the username/password prompt.
GIT_CREDENTIAL_HELPER=$PWD/.git/git-credential-stop
cat > $GIT_CREDENTIAL_HELPER <<EOF
cat
echo "username=git"
echo "password=git"
EOF
chmod a+x $GIT_CREDENTIAL_HELPER
git config credential.helper $GIT_CREDENTIAL_HELPER

DF_BEFORE_GIT="$(($(stat -f --format="%a*%S" .)))"

echo "========================================"
echo "- Fetching non shallow to get git version"
echo "---------------------------------------------"
git fetch origin --unshallow || true
git fetch origin --tags

echo
echo "========================================"
echo "Git fetching tags"
echo "----------------------------------------"
git fetch --tags || true
echo "----------------------------------------"

echo
echo "========================================"
echo "Using local version of submodules (if they exist)"
echo "---------------------------------------------"
"$PWD/.github/add-local-submodules.sh" "SymbiFlow/sv-tests"
echo "---------------------------------------------"
git submodule foreach --recursive 'git remote -v; echo'
echo "---------------------------------------------"
git submodule status --recursive
echo "---------------------------------------------"

echo
echo "========================================"
echo "Git log"
echo "----------------------------------------"
git log -n 5 --graph
echo "----------------------------------------"

echo
echo "========================================"
echo "Git version info"
echo "----------------------------------------"
git log -n1
echo "----------------------------------------"
git describe --tags || true
echo "----------------------------------------"
git describe --tags --always || true
echo "----------------------------------------"

echo
echo "========================================"
echo "Disk space free (after fixing git)"
echo "---------------------------------------------"
df -h
echo ""
DF_AFTER_GIT="$(($(stat -f --format="%a*%S" .)))"
awk "BEGIN {printf \"Git is using %.2f megabytes\n\",($DF_BEFORE_GIT-$DF_AFTER_GIT)/1024/1024}"
