#!/bin/bash
(
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local rc_files="$REPO_FIXTURES/rc-files"
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

	cat > $NOTHOME/some-file <<EOF
File with some content.
EOF
	ln -s $NOTHOME/some-file symlinked-file
	git add symlinked-file
	git commit -m 'Added a symlinked file'

	mkdir $NOTHOME/some-directory
	ln -s $NOTHOME/some-directory symlinked-directory
	git add symlinked-directory
	git commit -m 'Added a symlinked directory'

	ln -s $NOTHOME/nonexistent dead-symlink
	git add dead-symlink
	git commit -m 'Added a dead symlink'

	# Create a branch with a slash in it.
	# Used for list suite unit test testSlashInBranch()
	git branch branch/with/slash

	cat > .gitignore <<EOF
.DS_Store
*.swp
EOF
	git add .gitignore
	git commit -m 'Added .gitignore file'
) > /dev/null
