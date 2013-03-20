homeshick
=========
<div style="float: right"><img src="http://i.imgur.com/3zAK9.jpg"></div>
homshick is a dependency-free stand-in for [homesick](https://github.com/technicalpickles/homesick)

# homeshick vs. homesick #
The original goal of homeshick was to mimick its functionality so that it could be a drop-in replacement.  
Since its inception however homeshick has deviated quite a bit from the ruby-version.
All of the original commands are still available but have been enhanced with a few additions
like looking for new files after pulling and checking remotes for updates.

One particular advantage homeshick has over homesick is
the ability to install it easily without root privileges.
To install a gem, not having root privileges makes the job a lot harder.
With homeshick you simply run the two commands listed below and you are done!

# Installation #
homeshick will be installed as your first castle. After that you can easily update it with `homeshick pull homeshick`.  
In order to create the castle, simply download the install script and run it through bash.
```
curl -sL https://raw.github.com/andsens/homeshick/master/install.sh | bash
```

You can make homeshick accessible as an alias like this
```
printf '\nalias homesick="$HOME/.homeshick"' >> .bashrc
```

# Automatic deployment #
After having launched ec2 instances a lot, I got tired of installing zsh, tmux etc.
Check out [this gist](https://gist.github.com/2913223).

In one line you can run a script which installs your favorite shell and multiplexer.
It also installs homeshick, which then clones and symlinks your castle(s).
To clone via ssh instead of https, you will need a private key.

You may however not trust the current server with agent forwarding,
which is why the script contains variables to hold the unencrypted deploy key of your castles
(available in the admin section of your repo).
They will be added to the ssh-agent in order for git to be able to clone. Enjoy!
