#!/bin/bash
set -e
repos=$HOME/.homesick/repos
mkdir -p $repos
git clone git://github.com/andsens/homeshick.git $repos/homeshick
ln -s $repos/homeshick/home/.homeshick $HOME/.homeshick
