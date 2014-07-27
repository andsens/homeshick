#!/usr/bin/env bash
(
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local symlinks="$REPO_FIXTURES/symlinks"
	git init $symlinks
	cd $symlinks
	git config user.name $git_username
	git config user.email $git_useremail
	mkdir home
	cd home

	ln -s ../../../../file_in_homedir link_to_homedir_file
	git add link_to_homedir_file
	git commit -m 'Add file to test symlinking'
) > /dev/null
