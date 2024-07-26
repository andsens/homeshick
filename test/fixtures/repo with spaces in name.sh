#!/usr/bin/env bash

# shellcheck disable=2164
fixture_repo_with_spaces_in_name() {
  local git_username="Homeshick user"
  local git_useremail="homeshick@example.com"
  local namewithspaces="${REPO_FIXTURES}/repo with spaces in name"
  git init "$namewithspaces"
  cd "$namewithspaces"
  git config user.name "$git_username"
  git config user.email "$git_useremail"
  mkdir home
  cd home

  touch .repowithspacesfile

  git add .repowithspacesfile
  git commit -m 'Add file to repo with spaces in name'

  touch ".file with spaces in name"
  git add ".file with spaces in name"

  mkdir ".folder with spaces in name"
  touch ".folder with spaces in name/another file with spaces in its name"
  git add ".folder with spaces in name/another file with spaces in its name"

  touch ".crazy
file␇☺"
  git add ".crazy
file␇☺"
  touch "%printf conver%sionchar%s %%"
  git add "%printf conver%sionchar%s %%"

  git commit -m 'Add file with newline and all kinds of crazy characters in the name'
}

fixture_repo_with_spaces_in_name > /dev/null
