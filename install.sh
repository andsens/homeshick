#!/bin/bash
pushd $HOME > /dev/null
repos='.homesick/repos'
mkdir -p $repos
git clone git://github.com/andsens/homeshick.git homesick/repos/homeshick
ln -s $repos/homeshick/home/.homeshick $HOME/.homeshick
popd > /dev/null
