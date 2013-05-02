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
	) > /dev/null
}

function teardown_repo_fixtures {
	rm -rf $REPO_FIXTURES
}
