# action-haml-lint


[![Test](https://github.com/patch-technology/action-haml-lint/workflows/Test/badge.svg)](https://github.com/patch-technology/action-haml-lint/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/patch-technology/action-haml-lint/workflows/reviewdog/badge.svg)](https://github.com/patch-technology/action-haml-lint/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/patch-technology/action-haml-lint/workflows/depup/badge.svg)](https://github.com/patch-technology/action-haml-lint/actions?query=workflow%3Adepup)
[![release](https://github.com/patch-technology/action-haml-lint/workflows/release/badge.svg)](https://github.com/patch-technology/action-haml-lint/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/patch-technology/action-haml-lint?logo=github&sort=semver)](https://github.com/patch-technology/action-haml-lint/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

---
This action will run [haml-lint](https://github.com/sds/haml-lint) together with [reviewdog](https://github.com/reviewdog/reviewdog) to create a nice report on your pull requests. 

This action was created using the [action-template](https://github.com/reviewdog/action-template) created by the reviewdog team. 

---

### Example
![github-pr-review demo](https://user-images.githubusercontent.com/9164583/81692519-d0d9e900-945e-11ea-9557-59fb3305665e.png)

<!-- TODO: Add image like above for github-pr-check reporter -->

## Inputs

```yaml
inputs:
  github_token:
    description: 'GITHUB_TOKEN'
    default: '${{ github.token }}'
  workdir:
    description: 'Working directory relative to the root directory.'
    default: '.'
  ### Flags for haml-lint
  haml_lint_flags:
    description: 'Additional haml-lint flags'
    default: ''
  ### Flags for rubocop
  rubocop_version:
    description: 'The rubocop version to install. Choose `gemfile` to use the version from your gemfile'
  rubocop_extensions:
    description: 'Rubocop extensions to install'
    default: 'rubocop-rails rubocop-performance rubocop-rspec rubocop-i18n rubocop-rake'
  ### Flags for reviewdog ###
  level:
    description: 'Report level for reviewdog [info,warning,error]'
    default: 'error'
  reporter:
    description: 'Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].'
    default: 'github-pr-check'
  filter_mode:
    description: |
      Filtering for the reviewdog command [added,diff_context,file,nofilter].
      Default is added.
    default: 'added'
  fail_on_error:
    description: |
      Exit code for reviewdog when errors are found [true,false]
      Default is `false`.
    default: 'false'
  reviewdog_flags:
    description: 'Additional reviewdog flags'
    default: ''
```

## Usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  linter_name:
    name: runner / haml-lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: patch-technology/action-haml-lint@v1
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need.
          # GitHub Status Check won't become failure with warning.
          level: warning
          # Change the config file and other haml-lint flags
          haml_lint_flags: -c .haml-config.yml
          # Set the rubocop version to the one from your Gemfile
          rubocop_version: gemfile
```


