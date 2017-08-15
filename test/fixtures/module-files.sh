#!/bin/bash

# shellcheck disable=2164
function fixture_module_files() {
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local module_files="$REPO_FIXTURES/module-files"
	git init "$module_files"
	cd "$module_files"
	git config user.name "$git_username"
	git config user.email "$git_useremail"

	local my_module="$REPO_FIXTURES/my_module"
	(
		git init "$my_module"
		cd "$my_module"
		git config user.name "$git_username"
		git config user.email "$git_useremail"
		cat > module_foo.conf <<EOF
# my module file
EOF
		git add module_foo.conf
		git commit -m 'module_foo file for new my_module repo'
	)


	git submodule add "$my_module"
	git commit -m 'my_module (git submodule) added for my new module-files repo'

	mkdir home
	cd home
	ln -s ../my_module .my_module
	git add .my_module
	git commit -m 'Files added for my new module-files repo'
}

fixture_module_files > /dev/null
