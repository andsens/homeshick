#!/bin/bash -e

function setup_repo_fixtures {
	teardown_repo_fixtures
	# Create the repos for homeshick to use as test repositories
	local rc_files="$REPO_FIXTURES/rc-files"
	(
		git init $rc_files
		cd $rc_files
		mkdir home
		cd home
		cat > .bashrc <<EOF
#!/bin/bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
EOF
		git add .bashrc
		git commit -m '.bashrc file for my new rc-files repo'
	) > /dev/null
}

function teardown_repo_fixtures {
	rm -rf $REPO_FIXTURES
}
