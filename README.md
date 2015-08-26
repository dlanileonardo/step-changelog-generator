Changelog Generator Step
-------------------------

[![wercker status](https://app.wercker.com/status/e1ec7279f3af5a298140c2da6eb60f11/s "wercker status")](https://app.wercker.com/project/bykey/e1ec7279f3af5a298140c2da6eb60f11)

## REQUIREMENTS

* `github_token` - Your Github API Token
* `github_user` - Your personal github user
* `github_repo` - Name of repository on github

Options

* `github_name` - Name user will be appear in commits
* `github_email` - Email from user will be appear in commits

## Example Usage

```yml
build:
  steps:
    - dlanileonardo/generate-changelog:
        github_token: $CHANGELOG_GITHUB_TOKEN
        github_user: $CHANGELOG_GITHUB_USER
        github_repo: $CHANGELOG_GITHUB_REPO
        github_name: $CHANGELOG_GITHUB_NAME
        github_email: $CHANGELOG_GITHUB_EMAIL
```

## CHANGELOG
See [CHANGELOG](CHANGELOG.md)

## WARNING

This step will commit a CHANGELOG.md in specified repository.

* This step use gem github-changelog-generator (https://github.com/skywinder/github-changelog-generator)
