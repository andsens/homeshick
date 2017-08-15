#!/bin/bash

# shellcheck disable=2164
function fixture_nodirs() {
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local nodirs="$REPO_FIXTURES/nodirs"
	git init "$nodirs"
	cd "$nodirs"
	git config user.name "$git_username"
	git config user.email "$git_useremail"
	mkdir home
	cd home

	touch .file1
	git add .file1
	git commit -m 'Add .file1 to test listing files'
}

fixture_nodirs > /dev/null
