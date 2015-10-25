function __fish_homeshick_strip_options
    set cmd (commandline -opc)
    if [ (count $cmd) -lt 2 ]
        return 1
    end
    for item in $cmd[2..-1]
        if [ (echo $item | sed 's/^\(.\).*/\1/') = "-" ]
            continue
        end
        echo $item
    end
end

function __fish_homeshick_needs_command
    set cmd (__fish_homeshick_strip_options)
    if [ (count $cmd) -eq 0 ]
        return 0
    end
    return 1
end

function __fish_homeshick_using_command
    set cmd (__fish_homeshick_strip_options)
    if [ (count $cmd) -eq 0 ]
        return 1
    end
    if [ $argv[1] = $cmd[1] ]
        return 0
    else
        return 1
    end
end

function __fish_homeshick_list_castles
    set repos "$HOME/.homesick/repos"
    for repo in (find -L $repos -mindepth 2 -maxdepth 2 -type d -name .git -exec dirname \{\} \;)
        basename $repo
    end
end

# general options
complete -f -c homeshick -s q -l quiet -d 'Suppress status output'
complete -f -c homeshick -s s -l skip -d 'Skip files that already exist'
complete -f -c homeshick -s f -l force -d 'Overwrite files that already exist'
complete -f -c homeshick -s b -l batch -d 'Batch-mode: Skip interactive prompts / Choose the default'
complete -f -c homeshick -s v -l verbose -d 'Verbose-mode: Detailed status output'

# cd
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a cd -r -d 'Enter a castle'
complete -f -c homeshick -n '__fish_homeshick_using_command cd' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# clone
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a clone -r -d 'Clone URI as a castle for homeshick'

# generate
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a generate -r -d 'Generate a castle repo'

# list
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a list -d 'List cloned castles'

# check
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a check -d 'Check a castle for updates'
complete -f -c homeshick -n '__fish_homeshick_using_command check' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# refresh
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a refresh -d 'Check if a castle needs refreshing'
complete -f -c homeshick -n '__fish_homeshick_using_command refresh' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# pull
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a pull -d 'Update a castle'
complete -f -c homeshick -n '__fish_homeshick_using_command pull' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# link
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a link -d 'Symlink all dotfiles from a castle'
complete -f -c homeshick -n '__fish_homeshick_using_command link' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# track
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a track -d 'Add a file to a castle'
complete -c homeshick -n '__fish_homeshick_using_command track' -a '(__fish_homeshick_list_castles)' -d 'Castle'

# help
complete -f -c homeshick -n '__fish_homeshick_needs_command' -a help -d 'Show usage of task'
complete -f -c homeshick -n '__fish_homeshick_using_command help' -a 'cd clone generate list check refresh pull link track' -d 'Task'
