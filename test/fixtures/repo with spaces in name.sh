#!/usr/bin/env bash
(
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local namewithspaces="${REPO_FIXTURES}/repo with spaces in name"
	git init "$namewithspaces"
	cd "$namewithspaces"
	git config user.name $git_username
	git config user.email $git_useremail
	mkdir home
	cd home

	touch .repowithspacesfile

	git add .repowithspacesfile
	git commit -m 'Add file to repo with spaces in name'
) > /dev/null
