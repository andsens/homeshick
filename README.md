homeshick
=========
homeshick keeps your dotfiles up to date using only git and bash.
It can handle many dotfile repositories at once, so you can beef up your own dotfiles
with bigger projects like [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and still
keep everything organized.

For detailed [installation instructions](https://github.com/andsens/homeshick/wiki/Installation), [tutorials](https://github.com/andsens/homeshick/wiki/Tutorials) and [tips](https://github.com/andsens/homeshick/wiki/Automatic-deployment) & [tricks](https://github.com/andsens/homeshick/wiki/Symlinking) have a look at the [wiki](https://github.com/andsens/homeshick/wiki).

Quick install
-------------

homeshick is installed to your own home directory and does not require root privileges to be installed.

```sh
git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
```

To invoke homeshick from sh and its derivates (bash, zsh, fish etc.) source the `homeshick.sh` script from your rc-script:
```sh
printf '\nsource "$HOME/.homesick/repos/homeshick/homeshick.sh"' >> $HOME/.bashrc
```
csh and derivatives (i.e. tcsh):
```sh
printf '\nalias homeshick source "$HOME/.homesick/repos/homeshick/bin/homeshick.csh"' >> $HOME/.cshrc
```
