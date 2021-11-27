#!/usr/bin/env bats

@test "should change LANG to C.UTF-8 by default" {
  bats_test <<'BATS' >test.bats
  run echo "> $LANG <"
  trace
BATS
  image "$BUILD_TAG" .
  assert_line --partial "> C.UTF-8 <"
}

@test "should change LANG to specified lang" {
  bats_test <<'BATS' >test.bats
  run echo "> $LANG <"
  trace
BATS
  image -e "LANG=C" "$BUILD_TAG" .
  assert_line --partial "> C <"
}
