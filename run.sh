#!/bin/bash

# If step using system ruby, it should install gem as root.
# If step using rvm/rbenv ruby, it shouldn't install gem as root.
# See https://github.com/wantedly/step-pretty-slack-notify/issues/1
if [ -z "${WERCKER_GENERATE_CHANGELOG_GITHUB_NAME}" ];
then
  GIT_AUTHOR="Wercker";
else
  GIT_AUTHOR="${WERCKER_GENERATE_CHANGELOG_GITHUB_NAME}";
fi

if [ -z "${WERCKER_GENERATE_CHANGELOG_GITHUB_EMAIL}" ];
then
  GIT_EMAIL="pleasemailus@wercker.com";
else
  GIT_EMAIL="${WERCKER_GENERATE_CHANGELOG_GITHUB_EMAIL}";
fi

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


  if [[ "${CURRENT_USER}" = "${RUBY_OWNER}" ]]; then
    echo "Installing gem github_changelog_generator"
    gem install github_changelog_generator --no-ri --no-rdoc
  else
    echo "Installing gem github_changelog_generator as root..."
    sudo gem install github_changelog_generator --no-ri --no-rdoc
  fi

  if [[ "${WERCKER_GIT_BRANCH}" =~ "${WERCKER_GENERATE_CHANGELOG_GITHUB_BRANCH}" ]]; then
    git init
    git remote add origin "${GIT_PATH}"
    git fetch
    git checkout "${WERCKER_GIT_BRANCH}"
    github_changelog_generator
    if [ "$(git ls-files -m)" ];
    then
      export WERCKER_GENERATE_CHANGELOG_HAS_NEW_CHANGELOG=true
    else
      export WERCKER_GENERATE_CHANGELOG_HAS_NEW_CHANGELOG=false
    fi
    git add CHANGELOG.md
    git config --global user.email "${GIT_AUTHOR}"
    git config --global user.name "${GIT_EMAIL}"
    git commit -m "CHANGELOG Generated"
    git push "${GIT_PATH}"
  fi
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
