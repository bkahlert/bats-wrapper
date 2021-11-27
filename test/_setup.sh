#!/usr/bin/env bash

basename "${BASH_SOURCE[0]%/*}" >>"$BATS_TEST_TMPDIR/setup.out"

# Prints a Bats test with the specified name and the contents of the specified
# file as its content.
# Arguments:
#   1 - test name
#   2 - file name; use `-` to read from STDIN (default: -)
bats_test() {
  echo '#!/usr/bin/env bats'
  echo '@te''st "'"${1?test name missing}"'" {'
  cat "${2:--}"
  echo '}'
}
