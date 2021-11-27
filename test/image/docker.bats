#!/usr/bin/env bats

@test "should provide Docker client" {
  bats_test <<BATS >test.bats
  run docker --version
  trace
BATS
  image "$BUILD_TAG" .
  assert_line --partial 'Docker version'
  assert_line --partial 'build'
}

@test "should pass-through socket" {
  bats_test <<BATS >test.bats
  run docker run --rm hello-world
  trace
BATS
  image -v /var/run/docker.sock:/var/run/docker.sock "$BUILD_TAG" .
  assert_line --partial 'Hello from Docker!'
}
