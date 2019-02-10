#!/bin/bash

set | grep TRAVIS

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Cannot publish pull requests."
    exit
fi

if [ "$GIT_PUB_REPO" != "" ]; then
    echo "Preparing to publish to $GIT_PUB_REPO..."
    cd $HOME
    git config --global user.email ${GIT_EMAIL}
    git config --global user.name ${GIT_NAME}

    if [ "$GH_TOKEN" != "" ]; then
        echo "Publishing..."

        git clone --quiet --branch=gh-pages \
            https://${GH_TOKEN}@github.com/${GIT_PUB_REPO} gh-pages > /dev/null

        TIP=${TRAVIS_TAG:="head"}

        cd gh-pages
        echo git rm -rf ./${TRAVIS_BRANCH}/${TIP}
        git rm -rf ./${TRAVIS_BRANCH}/${TIP} > /dev/null
        mkdir -p ./${TRAVIS_BRANCH}/${TIP}
        cp -Rf $TRAVIS_BUILD_DIR/build/dist/* ./${TRAVIS_BRANCH}/${TIP}

        git add --verbose -f .
        #git commit -m "Successful travis build $TRAVIS_BUILD_NUMBER"
        #git push -fq origin gh-pages > /dev/null

        echo -e "Published specification to gh-pages.\n"
    fi
fi
