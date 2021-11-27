#!/usr/bin/env bats

@test "should change timezone to UTC by default" {
  bats_test <<'BATS' >test.bats
  run date +"%Z"
  trace
BATS
  image "$BUILD_TAG" .
  assert_line --partial UTC
}

@test "should change timezone to specified timezone" {
  bats_test <<'BATS' >test.bats
  run date +"%Z"
  trace
BATS
  image -e "TZ=CEST" "$BUILD_TAG" .
  assert_line --partial CEST
}
