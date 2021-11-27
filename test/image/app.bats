#!/usr/bin/env bats

@test "should print help if specified" {
  image --stdout-only -i "$BUILD_TAG" --help
  assert_success
  assert_line "Usage: bats [OPTIONS] <tests>"
}

@test "should run tests" {
  copy_fixture test.bats .
  image "$BUILD_TAG" .
  assert_output --regexp '▶▶ TEST RUN
 ℹ working directory: .*
 ℹ bats command line: bats --jobs [0-9]+ --no-parallelize-within-files --recursive --timing .
1..1
ok 1 test in [0-9]+ms'
}

@test "should output completed files separately on redirected STDOUT" {
  mkdir tmp
  copy_fixture test.bats .
  run bash -c "echo \"\$(BATSW_IMAGE='$BUILD_TAG' BATS_TMPDIR='$PWD/tmp' '$BATS_CWD/batsw' .)\""
  assert_success
  assert_output --regexp '▶▶ TEST RUN
 ℹ working directory: .*
 ℹ bats command line: bats --jobs [0-9]+ --no-parallelize-within-files --recursive --timing .
1..1
ok 1 test in [0-9]+ms'
}

@test "should output completed files separately on redirected STDERR" {
  mkdir tmp
  copy_fixture test.bats .
  run bash -c "BATSW_IMAGE='$BUILD_TAG' BATS_TMPDIR='$PWD/tmp' '$BATS_CWD/batsw' . 2>/dev/null"
  assert_success
  assert_output --regexp '1..1'$'\n''ok 1 test in [0-9]+ms'
}
