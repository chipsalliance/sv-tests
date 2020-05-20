#!/bin/bash

set -e

if [ "$(whoami)" == "root" ]
then
    echo "Please don't run this script as root!"
    exit 1
fi

if [ z$1 == z ]; then
	echo "Missing USER_SLUG as first argument!"
	exit 1
fi
export USER_SLUG=$1

# Get the pull request info
export REQUEST_USER="$(echo $USER_SLUG | perl -pe 's|^([^/]*)/.*|\1|')"
export REQUEST_REPO="$(echo $USER_SLUG | perl -pe 's|.*?/([^/]*)$|\1|')"

echo "Request user is '$REQUEST_USER'".
echo "Request repo is '$REQUEST_REPO'".

# Disable prompting for passwords - works with git version 2.3 or above
export GIT_TERMINAL_PROMPT=0

function git_submodules {
	GIT_CONFIG="git config --file .gitmodules"
	$GIT_CONFIG --list --name-only | grep '^submodule.[^.]*.url' | sed -e's/^submodule\.//' -e's/\.url$//' | while read SM_NAME
	do
		SM_PATH="$($GIT_CONFIG submodule.$SM_NAME.path || true)"
		SM_ORIGIN="$($GIT_CONFIG submodule.$SM_NAME.url || true)"
		SM_UPDATE="$($GIT_CONFIG submodule.$SM_NAME.update || true)"
		git submodule status | grep -E ".$SM_PATH( |$)" | sed -e's/^.//' | while read SM_SHA1 SM_PATH2 SM_DESC
		do
			echo "$SM_NAME" "$SM_PATH" "$SM_SHA1" "$SM_ORIGIN" "$SM_UPDATE"
		done
	done
}
export -f git_submodules

echo ""
echo ""
echo ""
echo "- Using local version of submodules (if they exist)"
echo "---------------------------------------------"
git submodule status
echo "---"
git_submodules | while read SM_NAME SM_PATH SM_SHA1 SM_ORIGIN SM_UPDATE
do
if [ z$SM_UPDATE != znone ]; then
	$PWD/.github/add-local-submodule-inner.sh "." "$SM_NAME" "$SM_PATH" "$SM_SHA1" "$SM_ORIGIN"
fi
done
echo "---"
git submodule status --recursive
echo
git submodule foreach --recursive 'git remote -v; echo'
exit 0
