#!/usr/bin/env bash

BEFORE_PULL_TAG=__homeshick-before-pull__
pull() {
  [[ ! $1 ]] && help_err pull
  local castle=$1
  # repos is a global variable
  # shellcheck disable=SC2154
  local repo="$repos/$castle"
  pending 'pull' "$castle"
  castle_exists 'pull' "$castle"
  if ! repo_has_upstream "$repo"; then
    ignore 'no upstream' "Could not pull $castle, it has no upstream"
    return "$EX_SUCCESS"
  fi

  # this tag is exceedingly unlikely to already exist, but if it does, error
  # out and let the user resolve it
  (cd "$repo" && git rev-parse --verify "refs/tags/$BEFORE_PULL_TAG" &>/dev/null) && \
    err "$EX_DATAERR" "Pull marker tag ($BEFORE_PULL_TAG) already exists in $repo. Please resolve this before pulling."
  # make a tag at the current commit, so we can compare against it below
  (cd "$repo" && git tag --no-sign "$BEFORE_PULL_TAG" 2>&1)
  # remove the tag if one of the git operations fails
  trap 'cd "$repo" && git tag -d "$BEFORE_PULL_TAG" &>/dev/null' EXIT

  local git_out
  git_out=$(cd "$repo" && git pull 2>&1) || \
    err "$EX_SOFTWARE" "Unable to pull $repo. Git says:" "$git_out"

  version_compare "$GIT_VERSION" 1.6.5
  if [[ $? != 2 ]]; then
    git_out=$(cd "$repo" && git submodule update --recursive --init 2>&1) || \
      err "$EX_SOFTWARE" "Unable update submodules for $repo. Git says:" "$git_out"
  else
    git_out=$(cd "$repo" && git submodule update --init 2>&1) || \
      err "$EX_SOFTWARE" "Unable update submodules for $repo. Git says:" "$git_out"
  fi
  success
  trap - EXIT
  return "$EX_SUCCESS"
}

symlink_new_files() {
  local updated_castles=()
  while [[ $# -gt 0 ]]; do
    local castle=$1
    shift
    local repo="$repos/$castle"
    local git_out
    git_out=$(cd "$repo" && git diff --name-only --diff-filter=AR "$BEFORE_PULL_TAG" HEAD -- home 2>/dev/null | wc -l 2>&1)
    local result=$?
    # Remove the tag before doing anything else
    (cd "$repo" && git tag -d "$BEFORE_PULL_TAG" &>/dev/null)
    if [[ $result -ne 0 ]]; then
      continue  # Ignore errors, this operation is not mission critical
    fi
    if [[ ! -d $repo/home ]]; then
      continue;
    fi
    if [[ $git_out -gt 0 ]]; then
      updated_castles+=("$castle")
    fi
  done
  ask_symlink "${updated_castles[@]}"
  return "$EX_SUCCESS"
}
