#!/usr/bin/env bash

# Executes all `_setup.sh` files in this test's directory tree
# beginning from the test down to the directory the test is located at.
setups() {
  local -a setup_files=()
  local curr_dir=$BATS_TEST_DIRNAME
  while true; do
    [ ! -f "$curr_dir/_setup.sh" ] || setup_files=("$curr_dir/_setup.sh" "${setup_files[@]}")
    case $curr_dir in
      "${BATS_CWD%/}"/*)
        curr_dir=${curr_dir%/*}
        ;;
      "${BATS_CWD%/}")
        break
        ;;
      *)
        die "\$BATS_TEST_DIRNAME '$BATS_TEST_DIRNAME' unexpectedly not located inside of \$BATS_CWD '$BATS_CWD'"
        ;;
    esac
  done
  for setup_file in "${setup_files[@]}" ; do
    # shellcheck disable=SC1090
    source "$setup_file"
  done
}

# shellcheck source=./wrapper.sh
source "$(dirname "${BASH_SOURCE[0]}")/wrapper.sh"

load_lib support
load_lib assert
load_lib file

setups
type setup &>/dev/null && setup

cd "$BATS_TEST_TMPDIR" || die "failed to change directory to $BATS_TEST_TMPDIR"
