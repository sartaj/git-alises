#!/bin/bash

# git sync-main - Update local main branch with remote changes without switching branches
#
# USAGE:
#   git sync-main
#
# DESCRIPTION:
#   Fetches the latest changes from the remote main branch and updates the local
#   main branch without switching to it. This keeps your local main up to date
#   without disturbing your current work.

# Function to get origin
get_origin_name() {
    local ORIGIN_NAME=$(git remote | grep -m 1 origin || git remote | head -n 1)
    echo "${ORIGIN_NAME:-origin}"
}

# Function to detect the default base branch name
get_main_branch_name() {
    local ORIGIN_NAME=$(get_origin_name)
    local HEAD_REF=$(set -- `git ls-remote --symref $ORIGIN_NAME HEAD` && test $1 = ref: && echo $2)
    local GIT_DEFAULT_BASE_BRANCH=${HEAD_REF#refs/heads/}
    echo "${GIT_DEFAULT_BASE_BRANCH:-master}"
}

# Function to sync local main with remote main
git_sync_main() {
    local ORIGIN_NAME=$(get_origin_name)
    local BASE_BRANCH=$(get_main_branch_name)

    echo "🔄 Fetching latest changes from remote..."
    git fetch $ORIGIN_NAME --prune

    echo "🔄 Updating local $BASE_BRANCH with $ORIGIN_NAME/$BASE_BRANCH..."
    if git fetch $ORIGIN_NAME $BASE_BRANCH:$BASE_BRANCH; then
        echo "✨ Successfully synced local $BASE_BRANCH with remote!"
    else
        echo "❌ Failed to update local $BASE_BRANCH. Please check if there are conflicts."
        return 1
    fi

    return 0
}

# If this script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    git_sync_main "$@"
fi
