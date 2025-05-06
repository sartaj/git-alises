#!/bin/bash

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
    local COMMIT_MESSAGE="update"
    local COMMIT=$(git merge-base HEAD $BASE_BRANCH)

    # Check for help flag
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "git squish - Squash all commits since diverging from the base branch"
        echo ""
        echo "USAGE:"
        echo "  git squish [-m <commit-message>]"
        echo ""
        echo "OPTIONS:"
        echo "  -m <message>    Specify a commit message (default: uses last commit's message)"
        echo "  -h, --help      Show this help message"
        echo ""
        echo "EXAMPLES:"
        echo "  git squish                           # Squash using last commit's message"
        echo "  git squish -m 'Complete feature X'   # Squash with custom message"
        echo ""
        echo "DESCRIPTION:"
        echo "  Squashes all commits on your current branch back to where it"
        echo "  diverged from the default base branch (main/master). This is"
        echo "  useful for cleaning up your feature branch before merging."
        return 0
    fi

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
    echo "📝 Commiting changes:"
    git status --short
    git commit -m "$COMMIT_MESSAGE"

    echo "✨ Commits have been squished locally!"
    echo "⚠️  To update the remote branch, use:"
    echo "git push --force origin $CURRENT_BRANCH"
    
    return 0
}

# If this script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_squish "$@"
fi
