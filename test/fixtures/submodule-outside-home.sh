#!/bin/bash

# shellcheck disable=2164
function fixture_submodule_outside_home() {
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local submodule_outside_home_files="$REPO_FIXTURES/submodule-outside-home"
	git init "$submodule_outside_home_files"
	cd "$submodule_outside_home_files"
	git config user.name "$git_username"
	git config user.email "$git_useremail"

	local the_submodule="$REPO_FIXTURES/the-submodule"
	(
		git init "$the_submodule"
		cd "$the_submodule"
		git config user.name "$git_username"
		git config user.email "$git_useremail"
		cat > somefile.conf <<EOF
some kind of file
EOF
		git add somefile.conf
		git commit -m 'added some kind of file to the-submodule'
	)


	git submodule add "$the_submodule"
	git commit -m 'the-submodule (git submodule) added for my new module-files repo'

	mkdir home
	cd home
	ln -s .. root
	git add root
	git commit -m 'recursive symlink added'
}

fixture_submodule_outside_home > /dev/null
