#!/bin/bash

function setup_repo_fixtures {
	rm -rf $REPO_FIXTURES

	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"

	# Create the repos for homeshick to use as test repositories
	local rc_files="$REPO_FIXTURES/rc-files"
	(
		git init $rc_files
		cd $rc_files
		git config user.name $git_username
		git config user.email $git_useremail
		mkdir home
		cd home

		cat > .bashrc <<EOF
#!/bin/bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
EOF
		git add .bashrc
		git commit -m '.bashrc file for my new rc-files repo'
	) > /dev/null

	local my_module="$REPO_FIXTURES/my_module"
	(
		git init $my_module
		cd $my_module
		git config user.name $git_username
		git config user.email $git_useremail
		cat > module_foo.conf <<EOF
# my module file
EOF
		git add module_foo.conf
		git commit -m 'module_foo file for new my_module repo'
	) > /dev/null

	local module_files="$REPO_FIXTURES/module-files"
	(
		git init $module_files
		cd $module_files
		git config user.name $git_username
		git config user.email $git_useremail

		git submodule add $my_module
		git commit -m 'my_module (git submodule) added for my new module-files repo'

		mkdir home
		cd home
		ln -s ../my_module .my_module
		git add .my_module
		git commit -m 'Files added for my new module-files repo'
	) > /dev/null

	local dotfiles="$REPO_FIXTURES/dotfiles"
	(
		git init $dotfiles
		cd $dotfiles
		git config user.name $git_username
		git config user.email $git_useremail
		mkdir home
		cd home

		mkdir -p .config/foo.conf
		cat > .config/foo.conf/a.conf <<EOF
#I am just a regular config file 
[A]
LikesIceCream=True
EOF
		cat > .config/bar.dir <<EOF
#And I am just a regular config file with a weird name 
[B]
LikesCucumber=False
EOF
		git add .config
		git commit -m 'Files added for my new dotfiles repo'
		
		mkdir .ssh
		cat > .ssh/known_hosts <<EOF
github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
		git add .ssh
		git commit -m 'Share known_hosts across machines'

	) > /dev/null
}
