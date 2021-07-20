#!/bin/bash

if [ "$CIRCLE_BRANCH" = "" ]; then
    # It appears that CircleCI doesn't set CIRCLE_BRANCH for tagged builds.
    # Assume we're doing them on the master branch, I guess.
    BRANCH=master
else
    BRANCH=$CIRCLE_BRANCH
fi

echo "Deploying website updates for $BRANCH branch"

if [ `set | grep GIT_EMAIL | wc -l` = 0 -o `set | grep GIT_USER | wc -l` = 0 ]; then
    echo "No identity configured with GIT_USER/GIT_EMAIL"
    exit
fi

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER

# N.B. This publish script actually updates the grammar repository
# and the gh-pages branch of the 3.0-specification repository!

