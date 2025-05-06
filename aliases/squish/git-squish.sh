#!/bin/bash

commit_message=""

# Parse arguments for -m flag
while getopts "m:" opt; do
    case $opt in
        m)
            commit_message="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Get the origin name - try to find "origin" or use the first remote if not found
ORIGIN_NAME=$(git remote | grep -m 1 origin || git remote | head -n 1)
# Get the full head reference
HEAD_REF=$(set -- `git ls-remote --symref $ORIGIN_NAME HEAD` && test $1 = ref: && echo $2)
# Derive the branch name by removing the "refs/heads/" prefix
GIT_DEFAULT_BASE_BRANCH=${HEAD_REF#refs/heads/}
# Determine the base branch to use
DEFAULT_BASE_BRANCH="${GIT_DEFAULT_BASE_BRANCH:-main}"

COMMIT_HASH=$(git merge-base HEAD $DEFAULT_BASE_BRANCH)

# If no commit message provided, get the latest commit message
if [ -z "$commit_message" ]; then
    commit_message=$(git log -1 --pretty=%B)
fi

git reset --soft $COMMIT_HASH
git commit -m "$commit_message"

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "⚠️  Remember to git push --force to update the remote branch!"
echo "git push --force origin $CURRENT_BRANCH"

