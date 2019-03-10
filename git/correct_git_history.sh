#!/bin/sh

# Provides the way to correct name and email in existing commits
# Useful if you made commits using wrong git config

git filter-branch --env-filter '
OLD_EMAIL="ilya.builuk@here.com"
CORRECT_NAME="reinterpretcat"
CORRECT_EMAIL="ilya.builuk@gmail.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
