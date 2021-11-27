#!/usr/bin/env bats

@test "should run tests" {
  run bash "-c" "echo Hello BATS"
  assert_success
  assert_output "Hello BATS"
}

@test "should load bats-support" {
  run declare -f fail
  assert_success
  assert_line --partial "fail ()"
}

@test "should load bats-assert" {
  run declare -f assert
  assert_success
  assert_line --partial "assert ()"
}

@test "should load bats-file" {
  run declare -f assert_exist
  assert_success
  assert_line --partial "assert_exist ()"
}

@test "should run in BATS_TEST_TMPDIR" {
  run pwd
  assert_success
  assert_output "${BATS_TEST_TMPDIR//\/\//\/}"
}
