#!/bin/bash

# git squish - Squash all commits since diverging from the base branch
#
# USAGE:
#   git squish [-m <commit-message>]
#
# OPTIONS:
#   -m <message>    Specify a commit message for the squashed commit
#                   If not provided, uses the message from the last commit
#
# EXAMPLES:
#   git squish                          # Squash commits using last commit's message
#   git squish -m "Feature complete"    # Squash commits with a new message
#
# DESCRIPTION:
#   Squashes all commits on your current branch since it diverged from the
#   default base branch (main/master) into a single commit. This is useful
#   for cleaning up your commit history before merging a feature branch.
#   The command will preserve all your changes but combine them into one commit.

# Function to detect the default base branch name
get_default_base_branch() {
    # Get the origin name - try to find "origin" or use the first remote if not found
    local ORIGIN_NAME=$(git remote | grep -m 1 origin || git remote | head -n 1)
    # Get the full head reference
    local HEAD_REF=$(set -- `git ls-remote --symref $ORIGIN_NAME HEAD` && test $1 = ref: && echo $2)
    # Derive the branch name by removing the "refs/heads/" prefix
    local GIT_DEFAULT_BASE_BRANCH=${HEAD_REF#refs/heads/}
    # Determine the base branch to use
    echo "${GIT_DEFAULT_BASE_BRANCH:-master}"
}

# Function to squash commits since diverging from base branch
git_squish() {

    ##
    ## Parse Args
    ##
    
    # Defaults
    local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    local BASE_BRANCH=$(get_default_base_branch)
    local COMMIT=$(git merge-base HEAD $BASE_BRANCH)
    local COMMIT_MESSAGE=""

    # Parse arguments for -m flag
    while getopts "m:" opt; do
        case $opt in
            m)
                COMMIT_MESSAGE="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
        esac
    done

    ##
    ## Validators
    ##

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "Cannot squish with uncommitted changes" >&2
        return 1
    fi

    # If no commit message provided, get the latest commit message
    if [ -z "$COMMIT_MESSAGE" ]; then
        COMMIT_MESSAGE=$(git log -1 --pretty=%B)
    fi

    ##
    ## Main Logic
    ##

    echo "🔍 Base branch: $BASE_BRANCH"
    echo "📍 Squishing to commit: $(git rev-parse --short $COMMIT)"
    echo "💬 Using commit message: $COMMIT_MESSAGE"
    echo ""

    git reset --soft $COMMIT
    echo "📝 Changes ready to commit:"
    git status --short

    if [ -n "$COMMIT_MESSAGE" ]; then
        # Commit message is not empty
        git commit -m "$COMMIT_MESSAGE"
        echo "✨ Commits have been squished locally!"
    else
        # No commit message, show the command to use
        echo "✨ Changes have been reset and staged. To commit, run:"
        echo "git commit -m \"update\""
    fi
    
    return 0
}

# If this script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_squish "$@"
fi
