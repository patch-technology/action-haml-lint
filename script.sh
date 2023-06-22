#!/bin/sh -e
version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

# Install rubocop
# This is inspired (read: copied) by https://github.com/reviewdog/action-rubocop/blob/master/script.sh
if [ "${INPUT_SKIP_INSTALL}" = "false" ]; then
  echo '::group:: Installing rubocop with extensions ... https://github.com/rubocop/rubocop'
  # if 'gemfile' rubocop version selected
  if [ "${INPUT_RUBOCOP_VERSION}" = "gemfile" ]; then
    # if Gemfile.lock is here
    if [ -f 'Gemfile.lock' ]; then
      # grep for rubocop version
      RUBOCOP_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}rubocop\s\(\K.*(?=\))/' Gemfile.lock)

      # if rubocop version found, then pass it to the gem install
      # left it empty otherwise, so no version will be passed
      if [ -n "$RUBOCOP_GEMFILE_VERSION" ]; then
        RUBOCOP_VERSION=$RUBOCOP_GEMFILE_VERSION
        else
          printf "Cannot get the rubocop's version from Gemfile.lock. The latest version will be installed."
      fi
      else
        printf 'Gemfile.lock not found. The latest version will be installed.'
    fi
    else
      # set desired rubocop version
      RUBOCOP_VERSION=$INPUT_RUBOCOP_VERSION
  fi

  gem install -N rubocop --version "${RUBOCOP_VERSION}"

  # Traverse over list of rubocop extensions
  for extension in $INPUT_RUBOCOP_EXTENSIONS; do
    # grep for name and version
    INPUT_RUBOCOP_EXTENSION_NAME=$(echo "$extension" |awk 'BEGIN { FS = ":" } ; { print $1 }')
    INPUT_RUBOCOP_EXTENSION_VERSION=$(echo "$extension" |awk 'BEGIN { FS = ":" } ; { print $2 }')

    # if version is 'gemfile'
    if [ "${INPUT_RUBOCOP_EXTENSION_VERSION}" = "gemfile" ]; then
      # if Gemfile.lock is here
      if [ -f 'Gemfile.lock' ]; then
        # grep for rubocop extension version
        RUBOCOP_EXTENSION_GEMFILE_VERSION=$(ruby -ne "print $& if /^\s{4}$INPUT_RUBOCOP_EXTENSION_NAME\s\(\K.*(?=\))/" Gemfile.lock)

        # if rubocop extension version found, then pass it to the gem install
        # left it empty otherwise, so no version will be passed
        if [ -n "$RUBOCOP_EXTENSION_GEMFILE_VERSION" ]; then
          RUBOCOP_EXTENSION_VERSION=$RUBOCOP_EXTENSION_GEMFILE_VERSION
          else
            printf "Cannot get the rubocop extension version from Gemfile.lock. The latest version will be installed."
        fi
        else
          printf 'Gemfile.lock not found. The latest version will be installed.'
      fi
    else
      # set desired rubocop extension version
      RUBOCOP_EXTENSION_VERSION=$INPUT_RUBOCOP_EXTENSION_VERSION
    fi

    # Handle extensions with no version qualifier
    if [ -z "${RUBOCOP_EXTENSION_VERSION}" ]; then
      unset RUBOCOP_EXTENSION_VERSION_FLAG
    else
      RUBOCOP_EXTENSION_VERSION_FLAG="--version ${RUBOCOP_EXTENSION_VERSION}"
    fi

    # shellcheck disable=SC2086
    gem install -N "${INPUT_RUBOCOP_EXTENSION_NAME}" ${RUBOCOP_EXTENSION_VERSION_FLAG}
  done
  
  # Installing haml-lint
  # The logic for this is inspired by Rubocop above
  # if 'gemfile' haml_lint version selected
  if [ "${INPUT_HAML_LINT_VERSION}" = "gemfile" ]; then
    # if Gemfile.lock is here
    if [ -f 'Gemfile.lock' ]; then
      # grep for rubocop version
      HAML_LINT_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}haml_lint\s\(\K.*(?=\))/' Gemfile.lock)

      # if rubocop version found, then pass it to the gem install
      # left it empty otherwise, so no version will be passed
      if [ -n "$HAML_LINT_GEMFILE_VERSION" ]; then
        HAML_LINT_VERSION=$HAML_LINT_GEMFILE_VERSION
        else
          printf "Cannot get the haml_lint's version from Gemfile.lock. The latest version will be installed."
      fi
      else
        printf 'Gemfile.lock not found. The latest version will be installed.'
    fi
    else
      # set desired rubocop version
      HAML_LINT_VERSION=$INPUT_HAML_LINT_VERSION
  fi

  echo '::group:: Installing haml-lint'
  gem install -N haml_lint  --version "${HAML_LINT_VERSION}"

  echo '::endgroup::'
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "${INPUT_USE_BUNDLER}" = "false" ]; then
  BUNDLE_EXEC=""
else
  BUNDLE_EXEC="bundle exec "
fi

echo '::group:: Running haml-lint with reviewdog 🐶 ...'
echo "haml-lint ${INPUT_HAML_LINT_FLAGS} ."

# shellcheck disable=SC2046
# shellcheck disable=SC2086
${BUNDLE_EXEC} haml-lint ${INPUT_HAML_LINT_FLAGS} . \
  | reviewdog -efm="%f:%l [%t] %m" \
      -name="${INPUT_TOOL_NAME}" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc


