#!/bin/bash

function setup_repo_fixtures {
	teardown_repo_fixtures
	# Create the repos for homeshick to use as test repositories
	local rc_files="$REPO_FIXTURES/rc-files"
	(
		git init $rc_files
		cd $rc_files
		git config user.name "Bar"
		git config user.email "Bar@bar.com"
		mkdir home
		cd home
		cat > .bashrc <<EOF
#!/bin/bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
EOF
		git add .bashrc
		git commit -m '.bashrc file for my new rc-files repo'
	) > /dev/null

	local deep_files="$REPO_FIXTURES/deep-files"
	(
		git init $deep_files
		cd $deep_files
		git config user.name "Bar"
		git config user.email "Bar@bar.com"
		mkdir -p home/.config/foo.conf
		cd home/.config
		cat > foo.conf/a.conf <<EOF
#I am just a regular config file 
[A]
LikesIceCream=True
EOF
		cat > bar.dir <<EOF
#And I am just a regular config file with a weird name 
[B]
LikesCucumber=False
EOF
		cd ..
		git add .config
		git commit -m 'Files added for my new deep-files repo'

		mkdir .ssh
		cat > .ssh/known_hosts <<EOF
github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
		git add .ssh
		git commit -m 'Share known_hosts across machines'

	) > /dev/null
}

function teardown_repo_fixtures {
	rm -rf $REPO_FIXTURES
}
