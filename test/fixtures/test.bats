#!/usr/bin/env bats

@test "test" {
  run echo "foo"
  assert_output "foo"
}
