#!/usr/bin/env bash
set -e

main() {
  cd "$(dirname "${BASH_SOURCE[0]}")"
  DOC="get_bash.sh - Downloads & compiles bash versions for testing
Usage:
  get_bash.sh VERSION...
"
# docopt parser below, refresh this parser with `docopt.sh get_bash.sh`
# shellcheck disable=2016,1090,1091,2034,2154
docopt() { source ../lib/docopt.sh-0.9.17.sh '0.9.17' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:92}
usage=${DOC:61:31}; digest=2571d; shorts=(); longs=(); argcounts=(); node_0(){
value VERSION a true; }; node_1(){ oneormore 0; }; node_2(){ required 1; }
node_3(){ required 2; }; cat <<<' docopt_exit() {
[[ -n $1 ]] && printf "%s\n" "$1" >&2; printf "%s\n" "${DOC:61:31}" >&2; exit 1
}'; unset var_VERSION; parse 3 "$@"; local prefix=${DOCOPT_PREFIX:-''}
unset "${prefix}VERSION"; if declare -p var_VERSION >/dev/null 2>&1; then
eval "${prefix}"'VERSION=("${var_VERSION[@]}")'; else
eval "${prefix}"'VERSION=()'; fi; local docopt_i=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_i=2; for ((;docopt_i>0;docopt_i--)); do
declare -p "${prefix}VERSION"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=../lib/docopt.sh-0.9.17.sh get_bash.sh`
  eval "$(docopt "$@")"
  versions_path="bash-versions"
  [[ -d "$versions_path" ]] || mkdir "$versions_path"
  local version
  # shellcheck disable=SC2153
  for version in "${VERSION[@]}"; do
    local version_path="$versions_path/bash-$version"
    if [[ ! -x "$version_path/bash" ]]; then
      printf -- 'bash-%s executable not found in %s, downloading & compiling now\n' "$version" "$versions_path"
      local archive_path="$versions_path/bash-$version.tar.gz"
      if [[ -f "$archive_path" ]]; then
        printf -- '%s already exists, skipping download\n' "$archive_path"
      else
        wget -O "$archive_path" "http://ftp.gnu.org/gnu/bash/bash-$version.tar.gz"
      fi
      if [[ -d "$version_path" ]]; then
        printf '%s already exists, skipping extraction\n' "$version_path"
      else
        tar -xz -C "$versions_path" -f "$archive_path"
      fi
      if [[ -f "$version_path/Makefile" ]]; then
        printf 'Makefile already exists, skipping ./configure\n'
      else
        (cd "$version_path" && ./configure)
      fi
      (cd "$version_path" && make)
    else
      printf 'bash-%s is already present\n' "$version"
    fi
  done
}

main "$@"
