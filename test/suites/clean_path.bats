#!/usr/bin/env bats

load ../helper

function setup() {
	setup_env
	source "$HOMESHICK_DIR/lib/fs.sh"
}

function test_clean_path() {
	local path=$1
	local expected=$2
	local cleaned
	cleaned=$(clean_path "$path")
	if [[ $cleaned != "$expected" ]]; then
		printf "got '%s'\n" "$cleaned"
		[ "$expected" = "$cleaned" ]
	fi
}

@test 'clean /home/user/somedir' {
	test_clean_path '/home/user/somedir' '/home/user/somedir'
}

@test 'clean home/user/somedir' {
	test_clean_path 'home/user/somedir' 'home/user/somedir'
}

@test 'clean /' {
	test_clean_path '/' '/'
}

@test 'clean ""' {
	test_clean_path '' ''
}

@test 'clean ../' {
	test_clean_path '../' '..'
}

@test 'clean ../somedir' {
	test_clean_path '../somedir' '../somedir'
}

@test 'clean /..' {
	test_clean_path '/..' '/'
}

@test 'clean /../dir' {
	test_clean_path '/../dir' '/dir'
}

@test 'clean somedir/../..' {
	test_clean_path 'somedir/../..' '..'
}

@test 'clean /home/user/somedir/' {
	test_clean_path '/home/user/somedir/' '/home/user/somedir'
}

@test 'clean /home/user/../user/somedir' {
	test_clean_path '/home/user/../user/somedir' '/home/user/somedir'
}

@test 'clean /home/user/../user/somedir/' {
	test_clean_path '/home/user/../user/somedir/' '/home/user/somedir'
}

@test 'clean /home/user/../../user/somedir/' {
	test_clean_path '/home/user/../../user/somedir/' '/user/somedir'
}

@test 'clean /home/user/../anotherdir/../somedir/' {
	test_clean_path '/home/user/../anotherdir/../somedir/' '/home/somedir'
}

@test 'clean /home/user/somedir/..' {
	test_clean_path '/home/user/somedir/..' '/home/user'
}

@test 'clean /home/user/somedir/../' {
	test_clean_path '/home/user/somedir/../' '/home/user'
}

@test 'clean /home/user/somedir/../../' {
	test_clean_path '/home/user/somedir/../../' '/home'
}

@test 'clean /home/user/./somedir' {
	test_clean_path '/home/user/./somedir' '/home/user/somedir'
}

@test 'clean /home/user/.' {
	test_clean_path '/home/user/.' '/home/user'
}

@test 'clean /home/user/./' {
	test_clean_path '/home/user/./' '/home/user'
}

@test 'clean /home/user/./somedir/../anotherdir/.' {
	test_clean_path '/home/user/./somedir/../anotherdir/.' '/home/user/anotherdir'
}

@test 'clean /home/user../../somedir' {
	clean_path '/home/user../../somedir'
	test_clean_path '/home/user../../somedir' '/home/somedir'
}

@test 'clean /home/user../../some dir' {
	clean_path '/home/user../../some dir'
	test_clean_path '/home/user../../some dir' '/home/some dir'
}

@test 'clean /home/user name../../some dir' {
	clean_path '/home/user name../../some dir'
	test_clean_path '/home/user name../../some dir' '/home/some dir'
}
