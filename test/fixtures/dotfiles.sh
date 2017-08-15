#!/bin/bash

# shellcheck disable=2164
function fixture_dotfiles() {
	local git_username="Homeshick user"
	local git_useremail="homeshick@example.com"
	local dotfiles="$REPO_FIXTURES/dotfiles"
	git init "$dotfiles"
	cd "$dotfiles"
	git config user.name "$git_username"
	git config user.email "$git_useremail"
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
	# Do not put anything in .config/foo
	# it is meant to be a directory
	# only containing other directories
	mkdir -p .config/foo/bar
	touch .config/foo/bar/baz.conf
	git add .config
	git commit -m 'Files added for my new dotfiles repo'

	mkdir .ssh
	cat > .ssh/known_hosts <<EOF
github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
	git add .ssh
	git commit -m 'Share known_hosts across machines'

	local st3_settings="Library/Application Support/Sublime Text 3/Packages/User"
	mkdir -p "$st3_settings"
	cat > "$st3_settings/Preferences.sublime-settings" <<EOF
{
"caret_style": "wide",
"default_line_ending": "unix",
"ensure_newline_at_eof_on_save": true,
"font_face": "Inconsolata-dz",
"rulers": [110],
"shift_tab_unindent": true,
"tab_size": 2
}
EOF
	git add "$st3_settings/Preferences.sublime-settings"
	git commit -m 'Added my Sublime Text 3 settings'

	local dotfiles_vim_submodule="$REPO_FIXTURES/dotfiles_vim_submodule"
	(
		git init "$dotfiles_vim_submodule"
		cd "$dotfiles_vim_submodule"
		git config user.name "$git_username"
		git config user.email "$git_useremail"

		mkdir -p autoload
		cat > autoload/pathogen.vim <<EOF
dummy pathogen autloader file
EOF

		mkdir -p bundles/vim-git
		cat > bundles/vim-git/README.md <<EOF
Just a random README for the dummy vim-git bundle
EOF
		git add autoload bundles
		git commit -m 'vim-git bundle for my vim config'
	)

	cd "$dotfiles"
	git submodule add "$dotfiles_vim_submodule" home/.vim
	git commit -m 'New vim configuration submodule'
}

fixture_dotfiles  > /dev/null
