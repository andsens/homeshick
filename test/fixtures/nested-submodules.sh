#!/bin/bash
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

	local home="$REPO_FIXTURES/home-for-nested-submodule"
	(
		git init $home
		cd $home
		git config user.name $git_username
		git config user.email $git_useremail
		cat > .info <<EOF
This is level "home" of the nested submodule repo
EOF
		git add .info
		git commit -m 'Add info file for home repo'

		local homesub="$REPO_FIXTURES/home-subdir-for-nested-submodule"
		(
			git init $homesub
			cd $homesub
			git config user.name $git_username
			git config user.email $git_useremail
			cat > .info1 <<EOF
This is level "homesub" of the nested submodule repo
EOF
			git add .info1
			git commit -m 'Add info file for homesub repo'

			local subsub="$REPO_FIXTURES/sub-subdir-for-nested-submodule"
			(
				git init $subsub
				cd $subsub
				git config user.name $git_username
				git config user.email $git_useremail
				cat > .info2 <<EOF
This is level "subsub" of the nested submodule repo
EOF
				git add .info2
				git commit -m 'Add info file for subsub repo'
			)

			git submodule add $subsub .subdir2
			git commit -m 'subsub submodule added for level2'
		)

		git submodule add $homesub .subdir1
		git commit -m 'homesub submodule added for level1'
	)

	git submodule add $home home
	git commit -m 'home submodule added for level0'
) > /dev/null
