#!/usr/bin/env bash

list() {
  while IFS= read -d $'\n' -r reponame ; do
    local ref
    local branch
    # repos is a global variable
    # shellcheck disable=SC2154
    ref=$(cd "$repos/$reponame" && git symbolic-ref HEAD 2>/dev/null)
    branch=${ref#refs/heads/}
    local remote_name
    local remote_url
    remote_name=$(cd "$repos/$reponame" && git config "branch.$branch.remote" 2>/dev/null)
    remote_url=$(cd "$repos/$reponame" && git config "remote.$remote_name.url" 2>/dev/null)
    info "$reponame" "$remote_url"
  done < <(list_castle_names)
  return "$EX_SUCCESS"
}
