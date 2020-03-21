#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Cannot publish pull requests."
    exit
fi

if [ "$GH_TOKEN" = "" ]; then
    echo "No GitHub token, publication is not possible."
    exit
fi

if [ "$GIT_PUB_REPO" = "" ]; then
    echo "No publication repo; publication is not possible."
    exit
fi

git config --global user.email ${GIT_EMAIL}
git config --global user.name ${GIT_NAME}

TIP=${TRAVIS_TAG:="head"}

cd $HOME
echo "Publishing to gh-pages/${TRAVIS_BRANCH}/${TIP} in ${GIT_PUB_REPO}"
    
git clone --quiet --branch=gh-pages \
    https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} gh-pages > /dev/null

# N.B. The expectation here is that the this repository
# may be updating gh-pages in a different repository
# Consequently, we don't try to remove the old files.
# Occasional manual cleanup may be required.

cd gh-pages
mkdir -p ./${TRAVIS_BRANCH}/${TIP}
cp -Rf $TRAVIS_BUILD_DIR/build/dist/* ./${TRAVIS_BRANCH}/${TIP}/

git add --verbose -f .
git commit -m "Travis build $TRAVIS_BUILD_NUMBER for $GIT_PUB_REPO"
git push -fq origin gh-pages > /dev/null

cd $HOME
rm -rf gh-pages

echo -e "Published."

if [ "$TRAVIS_REPO_SLUG" = "xproc/3.0-steps" ]; then
    # This is a merged PR going to the public repo
    # Publish the updated library and grammar files
    # to the grammar repo.
    GRAMMAR_REPO_SLUG=xproc/3.0-grammar

    cd $HOME
    echo "Publishing library and grammar files to ${GRAMMAR_REPO_SLUG}"
    
    git clone --quiet --branch=master \
        https://${GH_TOKEN}@github.com/${GRAMMAR_REPO_SLUG} grammar > /dev/null

    cd grammar
    mkdir -p ./steps
    cp -Rf $TRAVIS_BUILD_DIR/build/dist/etc/* ./steps/
    rm -f ./steps/*/source.xml ./steps/*/toc.xml

    git add --verbose -f .
    git commit -m "Travis build $TRAVIS_BUILD_NUMBER for $TRAVIS_REPO_SLUG"
    git push -fq origin master > /dev/null

    cd $HOME
    rm -rf gh-pages

    echo -e "Published."
fi
