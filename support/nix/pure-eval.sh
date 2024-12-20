#!/usr/bin/env bash

#
# Works around the fact pure evaluation handling outside of Flakes is inconvenient.
# This ***will*** fill your Nix store with mobile-nixos inputs.
#

set -e
PS4=" $ "

this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)"

path="./."

export NIX_PATH=""

set -x

CMD=(
	nix-instantiate
	--option pure-eval true
	--expr '{ path, ... }@args: import ("${path}") (builtins.removeAttrs (args) ["path"])'
	--arg path "$path"
	# Pass through the system, for convenience
	--arg system "$(nix-instantiate --eval --expr "builtins.currentSystem")"
	"$@"
)

exec "${CMD[@]}"
