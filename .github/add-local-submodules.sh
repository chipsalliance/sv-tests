#!/bin/bash

set -e

# Disable prompting for passwords - works with git version 2.3 or above
export GIT_TERMINAL_PROMPT=0

if [ z$1 == z ]; then
	echo "Missing USER_SLUG as first argument!"
	exit 1
fi
export USER_SLUG=$1

echo ""
echo ""
echo ""
echo "- Using local version of submodules (if they exist)"
echo "---------------------------------------------"
git submodule status
echo
git submodule status | sed -e's/^.//'  | while read SHA1 MODULE_PATH DESC
do
	"$PWD/.github/add-local-submodule-inner.sh" "$USER_SLUG" "$MODULE_PATH" "$SHA1"
done
echo
git submodule status --recursive
echo
git submodule foreach --recursive 'git remote -v; echo'
exit 0
