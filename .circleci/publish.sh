#!/bin/bash

if [ "$CIRCLE_BRANCH" = "" ]; then
    # It appears that CircleCI doesn't set CIRCLE_BRANCH for tagged builds.
    # Assume we're doing them on the master branch, I guess.
    BRANCH=master
else
    BRANCH=$CIRCLE_BRANCH
fi

echo "Deploying website updates for $BRANCH branch"

if [ -z "${GIT_EMAIL}" -o -z "{$GIT_USER}" ]; then
    echo "No identity configured with GIT_USER/GIT_EMAIL"
    exit
fi

if [ -z "${GIT_PUB_REPO}" ]; then
    echo "No publication repository configured with GIT_PUB_REPO"
    exit
fi

if [ -z "${GIT_GRAMMAR_REPO}" ]; then
    echo "No grammar repository configured with GIT_GRAMMAR_REPO"
    exit
fi

if [ -z "${GH_TOKEN}" ]; then
    echo "No github token configured with GH_TOKEN for publication"
    exit
fi

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USER

# N.B. This publish script actually updates the grammar repository
# and the gh-pages branch of the 3.0-specification repository!

STEPHOME=`pwd`
TIP=${CIRCLE_TAG:="head"}

echo "Publishing to gh-pages/${BRANCH}/${TIP} in ${GIT_PUB_REPO}"

cd ..

if [ ! -d pub-gh-pages ]; then
    git clone --quiet --branch=gh-pages \
        https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} pub-gh-pages > /dev/null
fi

cd pub-gh-pages
mkdir -p ./${BRANCH}/${TIP}
cp -Rf ${STEPHOME}/build/dist/* ./${BRANCH}/${TIP}/
git add -f .
git commit -m "Successful CircleCI build $CIRCLE_BUILD_NUM"
git push -fq origin gh-pages 

echo "Published."

cd ${STEPHOME}

echo "Publishing library and grammar files to ${GIT_GRAMMAR_REPO}"

cd ..

if [ ! -d pub-grammar ]; then
    git clone --quiet --branch=master \
        https://${GH_TOKEN}@github.com/${GIT_GRAMMAR_REPO} pub-grammar > /dev/null
fi

cd pub-grammar
cp -Rf ${STEPHOME}/build/dist/etc/* ./steps/
rm -f ./steps/*/source.xml ./steps/*/toc.xml

git add --verbose -f .
git commit -m "Successful CircleCI build $CIRCLE_BUILD_NUM"
git push -fq origin master

echo "Published."
