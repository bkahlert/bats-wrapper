#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  echo "setup" >>"$BATS_TEST_TMPDIR/setup.out"
  pwd >"$BATS_TEST_TMPDIR/pwd.out"
}

@test "should run setup files in right order" {
  run cat "$BATS_TEST_TMPDIR/setup.out"
  assert_output test$'\n'bar$'\n'setup
}

@test "should run setup in test dir" {
  run cat "$BATS_TEST_TMPDIR/pwd.out"
  assert_output "$BATS_CWD"
}

@test "should run test in tmp dir" {
  run pwd
  assert_output "${BATS_TEST_TMPDIR//\/\//\/}"
}
