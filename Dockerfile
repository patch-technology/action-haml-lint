FROM ruby:3.1-alpine

ENV REVIEWDOG_VERSION=v0.14.1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3006
RUN apk --no-cache add git

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}

# hadolint ignore=DL3006
RUN gem install haml_lint 'rubocop:~>1.31.2' rubocop-rails rubocop-performance rubocop-rake rubocop-rspec

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
