#!/bin/bash

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

        # N.B. gh-pages here is updated by two different repositories.
        # Consequently, we don't try to remove the old files.
        # Occasional manual cleanup may be required.

        cd gh-pages
        mkdir -p ./${TRAVIS_BRANCH}/${TIP}
        cp -Rf $TRAVIS_BUILD_DIR/build/dist/* ./${TRAVIS_BRANCH}/${TIP}

        git add --verbose -f .
        git commit -m "Successful travis build $TRAVIS_BUILD_NUMBER"
        git push -fq origin gh-pages > /dev/null

        echo -e "Published specification to gh-pages.\n"

        if [ "$TRAVIS_REPO_SLUG" == "xproc/3.0-steps" ]; then
            # Force a build of the 3.0-grammar repo
            # in case the steps have updated grammars.
            cd $HOME
            git clone --quiet --branch=master \
                https://${GH_TOKEN}@github.com/xproc/3.0-grammar grammar \
                > /dev/null
            cd grammar
            echo "Grammar for steps from build $TRAVIS_BUILD_NUMBER" \
                 > src/step-build.txt
            git add --verbose -f .
            git commit -m "Steps build $TRAVIS_BUILD_NUMBER"
            git push -fq origin master > /dev/null
        fi
    fi
fi
