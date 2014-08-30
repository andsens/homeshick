#!/usr/bin/env bats

load ../helper

function setup() {
	setup_env
	source $HOMESICK/repos/homeshick/lib/commands/clone.sh
}

@test 'git url basename: git@... .git' {
	[ 'homeshick' = "$(repo_basename 'git@github.com:andsens/homeshick.git')" ]
}

@test 'git url basename: https://... .git' {
	[ 'homeshick' = "$(repo_basename 'https://github.com/andsens/homeshick.git')" ]
}

@test 'git url basename: filepath' {
	[ 'homeshick' = "$(repo_basename '/home/username/homeshick.git')" ]
}

@test 'git url basename: git@... .git (dot in reponame)' {
	[ 'ebnf.vim' = "$(repo_basename 'git@github.com:vim-scripts/ebnf.vim.git')" ]
}

@test 'git url basename: ssh://... .git (dot in reponame)' {
	[ 'ebnf.vim' = "$(repo_basename 'ssh://git@github.com/vim-scripts/ebnf.vim.git')" ]
}

@test 'git url basename: http://... .git (dot in reponame)' {
	[ 'ebnf.vim' = "$(repo_basename 'https://github.com/vim-scripts/ebnf.vim.git')" ]
}

@test 'git url basename: numbers in reponame' {
	[ 'spf13-vim' = "$(repo_basename 'https://github.com/vim-scripts/spf13/spf13-vim.git')" ]
}

@test 'git url basename: git@... (no .git extension)' {
	[ 'homeshick' = "$(repo_basename 'git@github.com:andsens/homeshick')" ]
}

@test 'git url basename: git@... (dot in reponame, no .git extension)' {
	[ 'ebnf.vim' = "$(repo_basename 'git@github.com:vim-scripts/ebnf.vim')" ]
}

@test 'git url basename: filepath (no .git extension)' {
	[ 'homeshick' = "$(repo_basename '/home/username/homeshick')" ]
}

@test 'git url basename: filepath (colon in reponame)' {
	[ 'dotfiles:emacs' = "$(repo_basename '/home/username/dotfiles:emacs.git')" ]
}

@test 'git url basename: filepath (no extension, colon in reponame)' {
	[ 'dotfiles:emacs' = "$(repo_basename '/home/username/dotfiles:emacs.git')" ]
}

@test 'git url basename: filepath (no extension, colon in reponame & path)' {
	[ 'dotfiles:emacs' = "$(repo_basename '/home/user:name/dotfiles:emacs')" ]
}

@test 'git url basename: git@... (no extension, no subfolder)' {
	[ 'repo' = "$(repo_basename 'git@gitolite.example.com:repo')" ]
}

@test 'git url basename: git@... (no extension, no subfolder, colon in reponame)' {
	[ 'dotfiles:emacs' = "$(repo_basename 'git@gitolite.example.com:dotfiles:emacs')" ]
}

@test 'git url basename: ssh:// (no extension, no subfolder)' {
	[ 'repo' = "$(repo_basename 'ssh://git@gitolite.example.com/repo')" ]
}

@test 'git url basename: ssh:// (no extension, no subfolder, colon in reponame)' {
	[ 'dotfiles:emacs' = "$(repo_basename 'ssh://git@gitolite.example.com/dotfiles:emacs')" ]
}

@test 'git url basename: http://... (with portnumber)' {
	[ 'repo' = "$(repo_basename 'https://git.example.com:1234/repos/repo.git')" ]
}

@test 'git url basename: http://... (with portnumber, colon in subfoldername)' {
	[ 'repo' = "$(repo_basename 'https://git.example.com:1234/dotfiles:emacs/repo.git')" ]
}

@test 'git url basename: http://... (with portnumber, colon in reponame)' {
	[ 'repo:emacs' = "$(repo_basename 'https://git.example.com:1234/dotfiles/repo:emacs.git')" ]
}
