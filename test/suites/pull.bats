#!/usr/bin/env bats

load ../helper.sh

setup() {
  create_test_dir
  # shellcheck source=../../homeshick.sh
  source "$HOMESHICK_DIR/homeshick.sh"
}

teardown() {
  delete_test_dir
}

BEFORE_PULL_TAG=__homeshick-before-pull__
assert_tag_points_to() {
  # takes castle name as first argument and expected commit hash as second
  (
    castle="$1"
    tag_before="$2"
    cd "$HOME/.homesick/repos/$castle" || return $?
    # show all the tags if the test fails
    {
      echo "all tags in $castle:"
      git show-ref --tags || true
      echo
    } >&2
    tag_after=$(git rev-parse "refs/tags/$BEFORE_PULL_TAG")
    [ "$tag_before" == "$tag_after" ]
  )
}

reset_and_add_new_file() {
  # takes castle name as first argument and commit to reset to as second
  local castle="$1"
  (
    cd "$HOME/.homesick/repos/$castle" || return $?
    git reset --hard "$2" >/dev/null

    git config user.name "Homeshick user"
    git config user.email "homeshick@example.com"

    cat > home/.ignore <<EOF
.DS_Store
*.swp
EOF
    git add home/.ignore >/dev/null
    git commit -m 'Added .ignore file' >/dev/null
  )
  homeshick link --batch --quiet "$castle"
}

expect_new_files() {
  # takes castle name as first argument, and new files as remaining arguments
  local castle="$1"
  shift
  local green='\e[1;32m'
  local cyan='\e[1;36m'
  local white='\e[1;37m'
  local reset='\e[0m'
  # these variables are intended to be parsed by printf
  # shellcheck disable=SC2059
  {
    printf  "$cyan         pull$reset %s\r" "$castle"
    printf "$green         pull$reset %s\n" "$castle"
    printf "$white      updates$reset The castle %s has new files.\n" "$castle"
    printf  "$cyan     symlink?$reset [yN] y\r"
    printf "$green     symlink?$reset [yN] \n"
    for file in "$@"; do
    printf  "$cyan      symlink$reset %s\r" "$file"
    printf "$green      symlink$reset %s\n" "$file"
    done
  } | assert_output -
}

expect_no_new_files() {
  # takes castle name as first argument
  local castle="$1"
  local green='\e[1;32m'
  local cyan='\e[1;36m'
  local reset='\e[0m'
  {
    printf  "$cyan         pull$reset %s\r" "$castle"
    printf "$green         pull$reset %s\n" "$castle"
  } | assert_output -
}

@test 'pull skips castles with no upstream remote' {
  castle 'rc-files'
  castle 'dotfiles'
  # The dotfiles FETCH_HEAD should not exist after cloning
  [ ! -e "$HOME/.homesick/repos/dotfiles/.git/FETCH_HEAD" ]
  (cd "$HOME/.homesick/repos/rc-files" && git remote rm origin)
  run homeshick pull rc-files dotfiles
  [ $status -eq 0 ] # EX_SUCCESS
  # dotfiles FETCH_HEAD should exist if the castle was pulled
  [ -e "$HOME/.homesick/repos/dotfiles/.git/FETCH_HEAD" ]
}

@test 'pull prompts for symlinking if new files are present' {
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD~1 >/dev/null)
  homeshick link --batch --quiet rc-files

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull rc-files <<<y
  assert_success
  expect_new_files rc-files .gitignore
  [ -f "$HOME/.gitignore" ]
}

@test 'pull prompts for symlinking with renamed files' {
  castle 'pull-renamed'
  # reset to before .bashrc-wrong-name was renamed to .bashrc
  (cd "$HOME/.homesick/repos/pull-renamed" && git reset --hard HEAD~2 >/dev/null)
  homeshick link --batch --quiet pull-renamed

  [ ! -e "$HOME/.bashrc" ]
  run homeshick pull pull-renamed <<<y
  assert_success
  expect_new_files pull-renamed .bashrc
  [ -f "$HOME/.bashrc" ]
}

@test 'pull with no new files present' {
  castle 'pull-test'
  (cd "$HOME/.homesick/repos/pull-test" && git reset --hard HEAD~1 >/dev/null)
  homeshick link --batch --quiet pull-test

  [ -f "$HOME/.bashrc" ]
  run homeshick pull --batch pull-test
  assert_success
  expect_no_new_files pull-test
  [ -f "$HOME/.bashrc" ]
}

@test 'pull a recently-pulled castle again' {
  # this checks that we don't try to link files again if the last operation was
  # a pull
  castle 'rc-files'
  (cd "$HOME/.homesick/repos/rc-files" && git reset --hard HEAD~1 >/dev/null)
  homeshick link --batch --quiet rc-files
  homeshick pull rc-files <<<y

  [ -f "$HOME/.gitignore" ]
  run homeshick pull --batch rc-files
  assert_success
  expect_no_new_files rc-files
  [ -f "$HOME/.gitignore" ]
}

@test 'pull with local commits and no new files, merge' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~1
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase false)

  run homeshick pull --batch pull-test
  assert_success
  expect_no_new_files pull-test
}

@test 'pull with local commits and no new files, rebase' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~1
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase true)

  run homeshick pull --batch pull-test
  assert_success
  expect_no_new_files pull-test
}

@test 'pull with local commits and new files, merge' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~2
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase false)

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull pull-test <<<y
  assert_success
  expect_new_files pull-test .gitignore
  [ -f "$HOME/.gitignore" ]
}

@test 'pull with local commits and new files, rebase' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~2
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase true)

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull pull-test <<<y
  assert_success
  expect_new_files pull-test .gitignore
  [ -f "$HOME/.gitignore" ]
}

@test 'pull with local commits, fast-forward only' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~2
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase false && git config pull.ff only)

  [ ! -e "$HOME/.gitignore" ]
  # git pull should fail, since the local branch can't be fast-forwarded
  run homeshick pull --batch pull-test
  assert_failure 70 # EX_SOFTWARE
  assert_output -p 'fatal: Not possible to fast-forward, aborting.'
  [ ! -e "$HOME/.gitignore" ]
}

@test 'pull a castle with a git conflict' {
  castle 'pull-test'
  reset_and_add_new_file pull-test HEAD~2
  # don't let git automatically resolve the conflict
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase false && git config pull.ff only)

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull --batch pull-test
  assert_failure 70 # EX_SOFTWARE
  [ ! -e "$HOME/.gitignore" ]
  local red='\e\[1;31m'
  local cyan='\e\[1;36m'
  local reset='\e\[0m'
  {
    echo -ne '^'
    echo -ne "$cyan         pull$reset pull-test\r"
    echo -ne  "$red         pull$reset pull-test\n"
    echo -ne  "$red        error$reset Unable to pull ${HOME//./\.}/\.homesick/repos/pull-test\. Git says:\n"
    echo -ne '.*' # possibly some git advice
    echo -ne 'fatal: Not possible to fast-forward, aborting\.'
    echo -ne '$'
  } | assert_output -e -
}

@test 'pull continues with other castles after a git error' {
  castle 'nodirs'
  castle 'pull-test'
  castle 'module-files'
  reset_and_add_new_file pull-test HEAD~2
  (cd "$HOME/.homesick/repos/pull-test" && git config pull.rebase false && git config pull.ff only)
  (cd "$HOME/.homesick/repos/module-files" && git reset --hard HEAD~1 >/dev/null)
  homeshick link --batch --quiet pull-test module-files

  [ ! -e "$HOME/.my_module" ]
  run homeshick pull nodirs pull-test module-files <<<y
  assert_failure 70 # EX_SOFTWARE
  [ -d "$HOME/.my_module" ]
  local green='\e\[1;32m'
  local red='\e\[1;31m'
  local cyan='\e\[1;36m'
  local white='\e\[1;37m'
  local reset='\e\[0m'
  {
    echo -ne '^'
    echo -ne  "$cyan         pull$reset nodirs\r"
    echo -ne "$green         pull$reset nodirs\n"
    echo -ne  "$cyan         pull$reset pull-test\r"
    echo -ne   "$red         pull$reset pull-test\n"
    echo -ne   "$red        error$reset Unable to pull ${HOME//./\.}/\.homesick/repos/pull-test\. Git says:\n"
    echo -ne '.*' # possibly some git advice
    echo -ne 'fatal: Not possible to fast-forward, aborting\.\n'
    echo -ne  "$cyan         pull$reset module-files\r"
    echo -ne "$green         pull$reset module-files\n"
    echo -ne "$white      updates$reset The castle module-files has new files\.\n"
    echo -ne  "$cyan     symlink\?$reset \[yN\] y\r"
    echo -ne "$green     symlink\?$reset \[yN\] \n"
    echo -ne  "$cyan      symlink$reset \.my_module\r"
    echo -ne "$green      symlink$reset \.my_module"
    echo -ne '$'
  } | assert_output -e -
}

@test 'pull a castle where the marker tag already exists' {
  castle 'rc-files'
  local tag_before
  tag_before=$(
    cd "$HOME/.homesick/repos/rc-files" &&
    git reset --hard HEAD~1 >/dev/null &&
    git tag "$BEFORE_PULL_TAG" HEAD^ &&
    git rev-parse "$BEFORE_PULL_TAG"
  )

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull rc-files <<<y
  assert_success
  # tag should not be touched
  assert_tag_points_to rc-files "$tag_before"
  [ -f "$HOME/.gitignore" ]
}

@test 'pull leaves the marker tag alone' {
  castle 'dotfiles'
  castle 'rc-files'
  local tag_before
  tag_before=$(
    cd "$HOME/.homesick/repos/rc-files" &&
    git reset --hard HEAD~1 >/dev/null &&
    git tag "$BEFORE_PULL_TAG" HEAD^ &&
    git rev-parse "refs/tags/$BEFORE_PULL_TAG"
  )

  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull --batch dotfiles rc-files
  assert_success
  # tag in rc-files should not be touched
  assert_tag_points_to rc-files "$tag_before"
  [ ! -e "$HOME/.gitignore" ]
}

@test 'pull a castle with no local commits' {
  # note: pull should succeed, but doesn't currently try to link
  fixture 'pull-test'
  (cd "$HOME" && git init .homesick/repos/pull-test)
  (
    cd "$HOME/.homesick/repos/pull-test" &&
    git remote add origin "$REPO_FIXTURES/pull-test" &&
    printf '[branch "master"]\n  remote = origin\n  merge = refs/heads/master' >> .git/config
  )

  [ ! -e "$HOME/.bashrc" ]
  [ ! -e "$HOME/.gitignore" ]
  run homeshick pull --batch pull-test
  assert_success
  expect_no_new_files pull-test
  [ ! -e "$HOME/.bashrc" ]
  [ ! -e "$HOME/.gitignore" ]
}
