#!/bin/bash

# If step using system ruby, it should install gem as root.
# If step using rvm/rbenv ruby, it shouldn't install gem as root.
# See https://github.com/wantedly/step-pretty-slack-notify/issues/1

if which ruby > /dev/null 2>&1 ; then
  export CHANGELOG_GITHUB_TOKEN=${WERCKER_GENERATE_CHANGELOG_GITHUB_TOKEN}
  CURRENT_USER=$(whoami)
  RUBY_PATH=$(which ruby)
  RUBY_OWNER=$(stat -c '%U' "${RUBY_PATH}")
  GIT_PATH="https://${WERCKER_GENERATE_CHANGELOG_GITHUB_TOKEN}@github.com/${WERCKER_GENERATE_CHANGELOG_GITHUB_USER}/${WERCKER_GENERATE_CHANGELOG_GITHUB_REPO}.git"

  echo "Ruby Version: $(ruby -v)"
  echo "Ruby Path: ${RUBY_PATH}"
  echo "Install User: ${CURRENT_USER}"
  echo ""


  if [ "${CURRENT_USER}" = "${RUBY_OWNER}" ]; then
    echo "Installing gem github_changelog_generator"
    gem install github_changelog_generator --no-ri --no-rdoc
  else
    echo "Installing gem github_changelog_generator as root..."
    sudo gem install github_changelog_generator --no-ri --no-rdoc
  fi

  git init
  git remote add origin "${GIT_PATH}"
  git fetch
  github_changelog_generator
  git add CHANGELOG.md
  git commit -m "CHANGELOG Generated"
  git push "${GIT_PATH}"
else
  # Support Docker Box
  if which docker > /dev/null 2>&1 ; then
    echo "Docker Version: $(docker -v)"
    echo ""

    cd "$WERCKER_STEP_ROOT"
    script/run
    # No ruby, no docker case
  else
    echo "You need to use a box that installed ruby."
    exit 1
  fi
fi
