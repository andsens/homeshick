#!/usr/bin/env bash
set -e

lib_path=$(dirname "${BASH_SOURCE[0]}")/bats/lib

function install_bats_lib {
	mkdir -p "$lib_path/$1"
	curl -L --no-progress-meter "https://api.github.com/repos/bats-core/bats-$1/tarball/$2" | tar xz --strip=1 -C "$lib_path/$1"
}

install_bats_lib support v0.3.0
install_bats_lib assert v2.0.0
install_bats_lib file v0.3.0
