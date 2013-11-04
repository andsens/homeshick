#!/usr/bin/env bash -e

function oneTimeSetUp() {
	source $HOMESICK/repos/homeshick/utils/git.sh
}

function testSSH() {
	assertSame "homeshick" $(repo_basename 'git@github.com:andsens/homeshick.git')
}

function testHTTP() {
	assertSame "homeshick" $(repo_basename 'https://github.com/andsens/homeshick.git')
}

function testFilepath() {
	assertSame "homeshick" $(repo_basename '/home/username/homeshick.git')
}

function testSSHWithDot() {
	assertSame "ebnf.vim" $(repo_basename 'git@github.com:vim-scripts/ebnf.vim.git')
}

function testSSHWithDotWithProtocol() {
	assertSame "ebnf.vim" $(repo_basename 'ssh://git@github.com/vim-scripts/ebnf.vim.git')
}

function testHTTPWithDot() {
	assertSame "ebnf.vim" $(repo_basename 'https://github.com/vim-scripts/ebnf.vim.git')
}

function testNumbers() {
	assertSame "spf13-vim" $(repo_basename 'https://github.com/vim-scripts/spf13/spf13-vim.git')
}

function testSSHNoExtension() {
	assertSame "homeshick" $(repo_basename 'git@github.com:andsens/homeshick')
}

function testSSHWithDotNoExtension() {
	assertSame "ebnf.vim" $(repo_basename 'git@github.com:vim-scripts/ebnf.vim')
}

function testFilepathNoExtension() {
	assertSame "homeshick" $(repo_basename '/home/username/homeshick')
}

function testFilepathWithColon() {
	assertSame "dotfiles:emacs" $(repo_basename '/home/username/dotfiles:emacs.git')
}

function testFilepathNoExtensionWithColon() {
	assertSame "dotfiles:emacs" $(repo_basename '/home/username/dotfiles:emacs.git')
}

function testFilepathNoExtensionWithColonInPath() {
	assertSame "dotfiles:emacs" $(repo_basename '/home/user:name/dotfiles:emacs')
}

function testSSHNoExtensionNoSubfolder() {
	assertSame "repo" $(repo_basename 'git@gitolite.example.com:repo')
}

function testSSHNoExtensionNoSubfolderRepoHasColon() {
	assertSame "dotfiles:emacs" $(repo_basename 'git@gitolite.example.com:dotfiles:emacs')
}

function testSSHWithProtocolNoExtensionNoSubfolder() {
	assertSame "repo" $(repo_basename 'ssh://git@gitolite.example.com/repo')
}

function testSSHWithProtocolNoExtensionNoSubfolderRepoHasColon() {
	assertSame "dotfiles:emacs" $(repo_basename 'ssh://git@gitolite.example.com/dotfiles:emacs')
}

function testHTTPWithPort() {
	assertSame "repo" $(repo_basename 'https://git.example.com:1234/repos/repo.git')
}

function testHTTPWithPortSubfolderHasColon() {
	assertSame "repo" $(repo_basename 'https://git.example.com:1234/dotfiles:emacs/repo.git')
}

function testHTTPWithPortRepoHasColon() {
	assertSame "repo:emacs" $(repo_basename 'https://git.example.com:1234/dotfiles/repo:emacs.git')
}


source $SHUNIT2
