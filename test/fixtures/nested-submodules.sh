#!/usr/bin/env bash
(
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local nested_submodules="$REPO_FIXTURES/nested-submodules"
	git init $nested_submodules
	cd $nested_submodules
	git config user.name $git_username
	git config user.email $git_useremail
		cat > info <<EOF
This is level0 of the nested submodule repo
EOF
		git add info
		git commit -m 'Add info file for level0 repo'

	local level1="$REPO_FIXTURES/level1"
	(
		git init $level1
		cd $level1
		git config user.name $git_username
		git config user.email $git_useremail
		cat > info <<EOF
This is level1 of the nested submodule repo
EOF
		git add info
		git commit -m 'Add info file for level1 repo'

		local level2="$REPO_FIXTURES/level2"
		(
			git init $level2
			cd $level2
			git config user.name $git_username
			git config user.email $git_useremail
			cat > info <<EOF
This is level2 of the nested submodule repo
EOF
			git add info
			git commit -m 'Add info file for level2 repo'
		)

		git submodule add $level2 level2
		git commit -m 'level2 submodule added for level1'
	)

	git submodule add $level1 level1
	git commit -m 'level1 submodule added for level0'
) > /dev/null
