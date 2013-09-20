homeshick
=========
<img src="http://i.imgur.com/3zAK9.jpg">

homeshick keeps your dotfiles up to date using only git and bash.
It can handle many dotfile repositories at once, so you can beef up your own dotfiles
with bigger projects like [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and still
keep everything organized.

## Contents ##

* [How does it work?](#how-does-it-work)
* [Usage](#usage)
* [Installation](#installation)
* [Commands](#commands)
  * [link](#link)
  * [clone](#clone)
  * [pull](#pull)
  * [check](#check)
  * [list](#list)
  * [track](#track)
  * [generate](#generate)
  * [refresh](#refresh)
  * [cd](#cd)
* [Tutorial](#tutorial)
  * [Bootstrapping](#bootstrapping)
  * [Adding other machines](#adding-other-machines)
  * [Refreshing](#refreshing)
  * [Updating your castle](#updating-your-castle)
  * [Repos with no home](#repos-with-no-home--)
* [Automatic deployment](#automatic-deployment)
* [homeshick and homesick](#homeshick-and-homesick)

# How does it work? #
Symlinking.
On the simplest level, all homeshick really does is look for files and folders
in your cloned repositories and symlink them to your home directory.
The symlinked files must however reside in a folder named `home`.
This way you can prevent homeshick from cluttering your home folder with
files that are only *included* from elsewhere.
Each repo is referred to as a *castle*.

# Usage #

homeshick is used via subcommands, so simply typing `homeshick` will yield a helpful message
that tersely explains all of the things you can do with it.

Most subcommands accept castlenames as arguments.
You can also run a subcommand on all castles by not specifying any arguments.

# Installation #
homeshick is installed as a castle, this way it can keep itself updated.
In order to create the castle, simply clone it to the appropriate location.
```
git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
```

To avoid having to call homeshick with such a long path, you can alias it in your `.bashrc`:
```
printf '\nalias homeshick="source $HOME/.homesick/repos/homeshick/bin/homeshick.sh"' >> $HOME/.bashrc
```
If you use csh or tcsh, you can update your `.cshrc` like this:
```
printf '\nalias homeshick source "$HOME/.homesick/repos/homeshick/bin/homeshick.csh"' >> $HOME/.cshrc
```
To get the alias working right away, you will have to rerun your `.bashrc` with `source $HOME/.bashrc`, or your `.cshrc` with `source $HOME/.cshrc`.

*Note: The reason you should use alias="source ..." and not a simple invocation like alias="$HOME/..."
is because of the [cd](#cd) command. homeshick cannot change the working directory of your current shell
if it is invoked as a subprocess.*

You can skip the [commands](#commands) part and go to the [tutorial](#tutorial)
if you prefer getting to know homeshick by using it.

## Commands ##

### link ###
This command symlinks all files that reside in the `home` folders of your castles into your home folder.
You will be prompted if there are any files or folders that would be overwritten.

If the castle does not contain a home folder it will simply be ignored.

### clone ###
The `clone` command clones a new git repository to `.homesick/repos`.
The clone command accepts a github shorthand url, so if you want to clone
oh-my-zsh you can type `homeshick clone robbyrussell/oh-my-zsh`

### pull ###
The `pull` command runs a `git pull` on your castle and any of its submodules.
If there are any new dotfiles to be linked, homeshick will prompt you whether you want to link them.

### check ###
`check` determines the state of a castle.
* There may be updates on the remote, meaning it is *behind*.
* Your castle can also contain unpushed commits, meaning it is *ahead*.
* When everything is in sync, `check` will report that your castle is *up to date*.

### list ###
You can see your installed castles by running the `list` command.

### track ###
If you have a new dotfile that you want to put in one of your castles, you can ask
homeshick to do the moving and symlinking for you.
To track your `.bashrc` and `.zshrc` in your `dotfiles` castle
run `homeshick track dotfiles .bashrc .zshrc`,
the files are automatically added to the git index.

### generate ###
`generate` creates a new castle.
All you need to do now is call [`track`](#track) to fill it with your dotfiles.

### refresh ###
Run this command to check if any of your repositories have not been updated the last week.
This goes very well with your rc scripts (check out the [tutorial](#tutorial) for more about this).

### cd ###
After you have used the [`track`](#track) command, you will want to commit the changes and push them.
Instead of `cd`'ing your way into the repository simply type `homeshick cd dotfiles`;
homeshick will place you right inside the `home/` directory of your `dotfiles` castle.
From there you can run whatever git commands you like on your castle.

*Tip: `cd -` places you in your previous directory, so if you did not change directories
after running `homeshick cd dotfiles` you can simply type `cd -` to get back to where you left off.*

## Tutorial ##

### Bootstrapping ###

In the installation section above, you added a `homeshick` alias to your `.bashrc` file (substitute `.cshrc` for `.bashrc` if you are a csh or tcsh user).

Let's create your first castle to hold this file. You use the [generate](#generate) command to do that:
`homeshick generate dotfiles`. This creates an empty castle, which you can now populate.
Put the `.bashrc` file into your `dotfiles` castle with `homeshick track dotfiles .bashrc`.

Assuming you have a repository at the other end, let's now enter the castle, commit the changes,
add your github remote and push to it.
```
homeshick cd dotfiles
git commit -m "Initial commit, add .bashrc"
git remote add origin git@github.com/username/dotfiles
git push -u origin master
cd -
```
*Note: The `.homesick/` folder is not a typo, it is named as such because of compatibility with
[homesick](#homeshick-and-homesick), the ruby tool that inspired homeshick*

### Adding other machines ###
To get your custom `.bashrc` file onto other machines you [install homeshick](#installation) and
[`clone`](#clone) your castle with: `$HOME/.homesick/repos/homeshick/bin/homeshick clone username/dotfiles`
homeshick will ask you immediately whether you want to symlink the newly cloned castle.
If you agree to that and also agree to it overwriting the existing `.bashrc` you can run
`source $HOME/.bashrc` to get your `homeshick` alias running.

### Refreshing ###
You can run [`check`](#check) to see whether your castles are up to date or need pushing/pulling.
This is a task that is easy to forget, which is why homeshick has the [`refresh`](#refresh) subcommand.
It examines your castles to see when they were pulled the last time and prompts you to pull
any castles that have not been pulled over the last week.
You can put this into your `.bashrc` file to run the check everytime you start up the shell:
`printf '\nhomeshick --quiet refresh' >> $HOME/.bashrc`.
*(The `--quiet` flag makes sure your terminal is not spammed with status info on every startup)*

If you prefer to update your dotfiles every other day, simply run `homeshick refresh 2` instead.

### Updating your castle ###
To make changes to one of your castles you simply use git.
For example, if you want to update your `dotfiles` castle
on a machine where you have a nice tmux configuration:

```
homeshick add dotfiles .tmux.conf
homeshick cd dotfiles
git commit -m "Added awesome tmux configuration"
git push origin master
cd -
```


### Repos with no `home/` :'-( ###
What do you do if you encounter a really cool repository that goes well with
your existing setup, but it has no `home/` folder and needs to be linked to a
very specific place in your `$HOME` folder?

Let's say you want to add [vundle](#https://github.com/gmarik/vundle) to your Vim configuration.
The documentation says it needs to be installed to `~/.vim/bundle/vundle`, but you are not
very interested in forking the repository solely for the purpose of changing the directory layout
so that all files are placed four directories deeper in `home/.vim/bundle/vundle/`.

homeshick can solve this problem in two ways:

1. Add vundle as a submodule to your dotfiles. This is definitely the quick and easy way.

        homeshick cd dotfiles
        cd ..
        git submodule add https://github.com/gmarik/vundle.git home/.vim/bundle/vundle
2. Clone vundle with homeshick and symlink to the repo from the appropriate folder in your dotfiles:

        homeshick clone gmarik/vundle
        cd ~/.homeshick/repos/dotfiles/home
        mkdir .vim/bundle
        cd .vim/bundle
        ln -s ../../../../vundle vundle # symlink to the location of the cloned vundle repository
        homeshick link dotfiles
We use a relative path for the symlink in case we log in with different username on other machines.  
When running the [`link`](#link) command, homeshick will create a symlink at `~/.vim/bundle/vundle`
pointing at the symlink we just created. This means there will be a symlinked directory at
`~/.vim/bundle/vundle`, which contains the files of the cloned vundle repository  
*Note: You can see how homeshick decides what to do when encountering different symlink situations
by looking at the [linking table](wiki/Linking-table).*

The advantage of the second option is that you have more finegrained control over your repositories
and can manage each of them individually
(e.g. you want to [`refresh`](#refresh) your own dotfiles every week,
but you don't want to wait for all the submodules in your repository to refresh as well).

The downside of not using submodules is that you will need to add the additional repositories
with `homeshick clone` on every machine.
However, you can use the [automatic deployment](#automatic-deployment) script to avoid having
to do this manually.

## Automatic deployment ##
After having launched ec2 instances a lot, I got tired of installing zsh, tmux etc.
Check out [this gist](https://gist.github.com/2913223).

In one line you can run a script which installs your favorite shell and multiplexer.
It also installs homeshick, which then clones and symlinks your castle(s).
To clone via ssh instead of https, you will need a private key.

You may however not trust the current server with agent forwarding,
which is why the script contains variables to hold the unencrypted deploy key of your castles
(available in the admin section of your repo).
They will be added to the ssh-agent in order for git to be able to clone. Enjoy!


# homeshick and homesick #
The original goal of homeshick was to mimick the functionality of
[homesick](https://github.com/technicalpickles/homesick) so that it could be a drop-in replacement.
Since its inception however homeshick has deviated quite a bit from the ruby-version.
All of the original commands are still available, but have been simplified and enhanced with interactive
prompts like symlinking new files after a castle has been updated.
