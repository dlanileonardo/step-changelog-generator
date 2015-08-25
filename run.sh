#!/bin/bash

# If step using system ruby, it should install gem as root.
# If step using rvm/rbenv ruby, it shouldn't install gem as root.
# See https://github.com/wantedly/step-pretty-slack-notify/issues/1

if [ -z "${WERCKER_GENERATE_CHANGELOG_GITHUB_TOKEN}" ]; then
  export CHANGELOG_GITHUB_TOKEN=${WERCKER_GENERATE_CHANGELOG_GITHUB_TOKEN}
fi

if which ruby > /dev/null 2>&1 ; then
  CURRENT_USER=$(whoami)
  RUBY_PATH=$(which ruby)
  RUBY_OWNER=$(ls -l "${RUBY_PATH}" | tr -s ' ' | cut -d ' ' -f 3)

  echo "Ruby Version: $(ruby -v)"
  echo "Ruby Path: ${RUBY_PATH}"
  echo "Install User: ${CURRENT_USER}"
  echo ""


  if [ "${CURRENT_USER}" = "${RUBY_OWNER}" ]; then
    echo "Installing slack-notifier..."
         gem install github_changelog_generator --no-ri --no-rdoc
  else
    echo "Installing slack-notifier as root..."
    sudo gem install github_changelog_generator -v 1.2.1 --no-ri --no-rdoc
  fi

  $WERCKER_STEP_ROOT/github_changelog_generator
else
  # Support Docker Box
  if which docker > /dev/null 2>&1 ; then
    echo "Docker Version: $(docker -v)"
    echo ""

    $WERCKER_STEP_ROOT/script/run
  # No ruby, no docker case
  else
    echo "You need to use a box that installed ruby."
    exit 1
  fi
fi
