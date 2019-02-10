# XProc 3.0 Steps

This is the home of the XProc 3.0 step specifications developed by the
[XProc next community group](https://www.w3.org/community/xproc-next/).
The core language specification is maintained in
[the language repository](https://github.com/xproc/3.0-specification/).

Drafts are published automatically at [spec.xproc.org](http://spec.xproc.org/).

(The core language specification and the step specifications are
jointly published at the same website.)

## GitHub

The XProc community is using GitHub to manage the development of this
specification. Please pull the repository, make improvements, and
propose changes in the form of pull requests.

### Continuous integration

The XProc specification is built automatically with Travis CI.

To build and publish the spec on your `gh-pages`, setup the `gh-pages` branch,
configure Travis CI to
run for your repo, and then create the following
secure environment variables for your repo in the Travis CI Settings
page for your fork:

* GH_TOKEN="your git token"
* GIT_EMAIL="you@example.com"
* GIT_NAME="Your Name"
* GIT_PUB_REPO="you/3.0-specification"

The `GIT_TOKEN` must be a
[personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/). The `GIT_PUB_REPO` must be the repository where you wish
to publish the results. The publications scripts will push the published documents
to the `gh-pages` branch.

Travis CI will then publish your changes everytime you do a commit
to your `master` branch. Travis CI cannot publish `gh-pages` for
pull requests.

The publication scripts for the language repository and the steps
repository are designed so that they can both be published to the same
`gh-pages` repository. It isn’t necessary to have a separate staging
area for the step specifications.

## How it works

See [the language specification](https://github.com/xproc/3.0-specification/).

The build process is owned by [norm](mailto:ndw@nwalsh.com);
bug him if you have difficulties.
