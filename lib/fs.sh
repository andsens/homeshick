#!/bin/bash

function castle_exists {
	local action=$1
	local castle=$2
	# repos is a global variable, disable SC2154
	# shellcheck disable=SC2154
	local repo="$repos/$castle"
	if [[ ! -d $repo ]]; then
		err "$EX_ERR" "Could not $action $castle, expected $repo to exist"
	fi
}

function home_exists {
	local action=$1
	local castle=$2
	local repo="$repos/$castle"
	if [[ ! -d $repo/home ]]; then
		err "$EX_ERR" "Could not $action $castle, expected $repo to contain a home folder"
	fi
}

function list_castle_names {
	while IFS= read -d $'\0' -r repo ; do
		local reponame
		reponame=$(basename "${repo%/.git}")
		printf "%s\n" "$reponame"
	done < <(find -L "$repos" -mindepth 2 -maxdepth 2 -name .git -type d -print0 | sort -z)
	return "$EX_SUCCESS"
}

# Converts any path to an absolute path.
# All path parts except the last one must exist.
# A pwd option can be given as the first argument (like -P to resolve symlinks).
# In order to resolve the last part of the path append "/." to it.
function abs_path {
	local path
	local pwd_opt=""
	if [[ $# -eq 1 ]]; then
		path=$1
	else
		pwd_opt=$1
		path=$2
	fi
	local dir
	dir=$(dirname "$path")
	if [[ ! -e $dir ]]; then
		printf "The parent directory '%s' does not exist" "$dir" >&2
		return 1
	fi
	local real_dir
	local base
	real_dir=$(cd "$dir" >/dev/null && printf "%s" "$(pwd "$pwd_opt")")
	base=$(basename "$path")
	if [[ $base = "." ]]; then
		printf "%s\n" "$real_dir"
	elif [[ $base = "/" ]]; then
		printf "/\n"
	elif [[ $real_dir = "/" ]]; then
		printf "/%s\n" "$base"
	else
		printf "%s/%s\n" "$real_dir" "$base"
	fi
}

# Removes unnecessary path parts, such as '/./' and 'somedir/../' and trailing slashes
function clean_path {
	local path=$1

	# Split path into parts
	local parts=()
	local rest=$path
	while [[ $rest != '.' && $rest != '/' ]]; do
		parts+=($(basename "$rest"))
		rest=$(dirname "$rest")
	done
	# reverse $parts, it's a lot easier to follow the code below then
	local new_parts=()
	for (( idx=${#parts[@]}-1 ; idx>=0 ; idx-- )); do
		new_parts+=(${parts[$idx]})
	done
	parts=(${new_parts[@]})

	local left
	local right
	local omit_left
	local omit_right
	# Run through the $parts until we cannot reduce it any longer
	while true; do
		omit_left=false
		omit_right=false
		# Step through pair-wise, with the directory separator ('/') being what we iterate over
		# (the array is reversed)
		# We only do one change, then bail, so we can work on the new path
		for i in "${!parts[@]}"; do
			left=${parts[$i]}
			if [[ $i -ne ${#parts[@]}-1 ]]; then
				# There is no $right for the last element
				right=${parts[$i+1]}
			else
				right=''
			fi
			if [[ $left = '.' ]]; then
				# Remove '/./'
				omit_left=true
				break
			fi
			if [[ $right = '.' ]]; then
				# Remove '/./'
				omit_right=true
				break
			fi
			if [[ $left != '..' && $right == '..' ]]; then
				# Remove 'somedir/../'
				omit_left=true
				omit_right=true
				break
			fi
			if [[ $i -eq 0 && $left = '..' && $path = /* ]]; then
				# On absolute paths, remove '/../somedir'
				omit_left=true
				break
			fi
		done
		new_parts=()
		# Create new_parts, omitting $left and/or $right
		for j in "${!parts[@]}"; do
			[[ $omit_left = true && $j -eq $i ]] && continue
			[[ $omit_right = true && $j -eq $i+1 ]] && continue
			new_parts+=(${parts[$j]})
		done
		parts=(${new_parts[@]})
		if [[ $omit_left = false && $omit_right = false ]]; then
			break
		fi
	done
	# Construct $new_path from $parts
	local new_path=''
	for part in "${parts[@]}"; do
		if [[ -z $new_path ]]; then
			# Prevent leading slash
			new_path="$part"
		else
			new_path="$new_path/$part"
		fi
	done
	# Add leading slash for absolute paths
	if [[ $path = /* ]]; then
		new_path="/$new_path"
	fi
	printf "%s\n" "$new_path"
}

# Determines the relative path from source_dir to target
# As in: "What would the symlink look like if a file in $source_dir linked to $target?"
# $source_dir:
#   Is the directory in which the link resides.
#   It must have a trailing slash.
# $target:
#   Is the relative path from $source_dir to it.
#   It must not have a trailing slash.
# Both paths:
#   Must be absolute.
#   Must be well-formed (no nulbytes or double slashes)
function create_rel_path {
	local source_dir=$1
	local target=$2

	if [[ $source_dir != /* ]]; then
		printf "\$source_dir '%s' is not absolute\n" "$source_dir" >&2
		return 1
	fi
	if [[ $target != /* ]]; then
		printf "\$target '%s' is not absolute\n" "$target" >&2
		return 1
	fi
	if [[ $source_dir != */ ]]; then
		printf "\$source_dir '%s' must have a trailing slash\n" "$source_dir" >&2
		return 1
	fi
	if [[ $target = */ ]]; then
		printf "\$target '%s' must not have a trailing slash\n" "$target" >&2
		return 1
	fi
	if [[ $source_dir = *//* ]]; then
		printf "\$source_dir '%s' is not well-formed\n" "$source_dir" >&2
		return 1
	fi
	if [[ $target = *//* ]]; then
		printf "\$target '%s' is not well-formed\n" "$target" >&2
		return 1
	fi

	# Make sure $prefix has a trailing slash
	local prefix
	prefix=$target/
	# Find the common prefix of $source_dir and $target
	while [[ ! ${source_dir:0:${#prefix}} = "$prefix" ]]; do
		# Remove directory parts from prefix until we find the common directory
		prefix=$(dirname "$prefix")
		# Append the trailing slash, except for "/" (hence the %/)
		prefix=${prefix%/}/
	done
	# The path from the common directory to the target is
	# $target without the prefix
	local target_path
	# Check if $target = $prefix (without the trailing slash)
	if [[ $target = "${prefix%/}" ]]; then
		target_path=''
	else
		target_path=${target##$prefix}
	fi
	# The path from the common directory to the source_dir is
	# $source_dir without the prefix
	local source_dir_path
	source_dir_path=${source_dir##$prefix}

	# Determine the path from the source_dir to the common directory (consists only of ../)
	local common_dir_path=''
	while [[ $source_dir_path != '' && $source_dir_path != '.' ]]; do
		source_dir_path=$(dirname "$source_dir_path")
		if [[ ${#common_dir_path} -eq 0 ]]; then
			common_dir_path=".."
		else
			common_dir_path="$common_dir_path/.."
		fi
	done

	# The relative path is just the path from $source_dir to $common dir to the target
	if [[ -n $common_dir_path && -n $target_path ]]; then
		# Add dir separator if both paths are non-empty
		printf "%s/%s" "$common_dir_path" "$target_path"
	else
		printf "%s%s" "$common_dir_path" "$target_path"
	fi
}
