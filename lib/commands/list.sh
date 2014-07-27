#!/bin/bash

function list {
	while IFS= read -d $'\n' -r reponame ; do
		local ref=$(cd "$repos/$reponame"; git symbolic-ref HEAD 2>/dev/null)
		local branch=${ref#refs/heads/}
		local remote_name=$(cd "$repos/$reponame"; git config branch.$branch.remote 2>/dev/null)
		local remote_url=$(cd "$repos/$reponame"; git config remote.$remote_name.url 2>/dev/null)
		info "$reponame" "$remote_url"
	done < <(list_castle_names)
	return $EX_SUCCESS
}
