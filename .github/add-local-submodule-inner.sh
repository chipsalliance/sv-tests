#! /bin/bash


SCRIPT_SRC=$(realpath ${BASH_SOURCE[0]})

set -e

SM_PARENT="$1"
SM_NAME="$2"
SM_PATH="$3"
SM_SHA1="$4"
ORIGIN_URL="$5"

DISPLAY_NAME="${SM_PARENT}/${SM_PATH}"
if [ "$SM_NAME" != "$SM_PATH" ]; then
	DISPLAY_NAME="$DISPLAY_NAME ($SM_NAME)"
fi
echo
echo "Submodule $DISPLAY_NAME @ '$SM_SHA1' ($ORIGIN_URL)"
echo "---------------------------------------------------------"

# Get current origin from git
if echo $ORIGIN_URL | grep -q "github.com"; then
	echo -n "Found github - "

	ORIGIN_SLUG=$(echo $ORIGIN_URL | perl -pe 's|.*github.com/(.*?)(.git)?$|\1|')
	#echo "Origin slug is '$ORIGIN_SLUG'"

	ORIGIN_USER="$(echo $ORIGIN_SLUG | perl -pe 's|^([^/]*)/.*|\1|')"
	ORIGIN_REPO="$(echo $ORIGIN_SLUG | perl -pe 's|.*?/([^/]*)$|\1|')"

	#echo "Origin user is '$ORIGIN_USER'"
	#echo "Origin repo is '$ORIGIN_REPO'"

	USER_URL="https://github.com/$REQUEST_USER/$ORIGIN_REPO.git"

	# Check if the user's repo exists
	echo -n "User's repo would be '$USER_URL' "
	if git ls-remote --exit-code --heads "$USER_URL" > /dev/null 2>&1; then
		echo "which exists!"
	else
		echo "which does *not* exist!"
		USER_URL="$ORIGIN_URL"
	fi
else
	echo "Did not find github"
	USER_URL="$ORIGIN_URL"
fi

# If submodule doesn't exist, clone directly from the users repo
if [ ! -e $SM_PATH/.git ]; then
	echo "Cloning '$SM_PATH' from repo '$ORIGIN_URL'"
	git clone --filter=tree:0 "$ORIGIN_URL" "$SM_PATH" --origin origin
else
	(
		cd $SM_PATH
		git remote rm origin >/dev/null 2>&1 || true
		git remote add origin "$ORIGIN_URL"
		git config --local remote.origin.promisor true
		git config --local remote.origin.partialclonefilter 'tree:0'
	)
fi

# Fetch origin and make sure the submodule isn't shallow.
(
	cd $SM_PATH
	if [ $(git rev-parse --is-shallow-repository) != "false" ]; then
		git fetch origin --no-recurse-submodules --unshallow
	fi
	git fetch origin --no-recurse-submodules
)

# Add the user remote and fetch it.
if [ "$USER_URL" != "$ORIGIN_URL" ]; then
	(
		cd $SM_PATH
		git remote rm user >/dev/null 2>&1 || true
		git remote add user "$USER_URL"
		git config --local remote.user.promisor true
		git config --local remote.user.partialclonefilter 'tree:0'
		git fetch user --no-recurse-submodules
	)
fi

# Checkout to the correct SM_SHA1 value - which may come from origin or user.
(
	cd $SM_PATH
	git reset --hard "$SM_SHA1" --recurse-submodules=no
)

# Init the submodule
git submodule update --init $SM_PATH

# Call ourselves recursively.
(
	cd $SM_PATH
	SM_PARENT="$SM_PARENT/$SM_PATH"

	# Checkout the submodule at the right revision
	echo
	if [ -e '.gitmodules' ]; then
		echo "$SM_PARENT has submodules"
		echo
		echo "Sync submodules"
		echo "----------------------"
		git submodule sync
		echo
		echo "Status of submodules"
		echo "----------------------"
		git submodule status
		echo
		git_submodules | while read SM_NAME SM_PATH SM_SHA1 SM_ORIGIN
		do
			"$SCRIPT_SRC" "$SM_PARENT" "$SM_NAME" "$SM_PATH" "$SM_SHA1" "$SM_ORIGIN"
		done
	else
		echo "$SM_PARENT has no submodules"
	fi
	exit 0
) || exit 1

exit 0
