#!/usr/bin/env bash

# shellcheck disable=2164
fixture_pull_renamed() {
  local git_username="Homeshick user"
  local git_useremail="homeshick@example.com"
  local repo="$REPO_FIXTURES/pull-renamed"
  git init "$repo"
  cd "$repo"
  git config user.name "$git_username"
  git config user.email "$git_useremail"
  mkdir home
  cd home

  cat > .bashrc-wrong-name <<EOF
#!/usr/bin/env bash
PS1='\[33[01;32m\]\u@\h\[33[00m\]:\[33[01;34m\]\w\'
EOF
  git add .bashrc-wrong-name
  git commit -m '.bashrc file for my new repo'

  git mv .bashrc-wrong-name .bashrc
  git commit -m 'fixed .bashrc file name'

  cat >> .bashrc <<EOF
export IMPORTANT_VARIABLE=1
EOF
  git add .bashrc
  git commit -m 'Modified .bashrc to set IMPORTANT_VARIABLE'
}

fixture_pull_renamed  > /dev/null
