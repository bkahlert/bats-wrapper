#!/usr/bin/env bats

setup() {
  export EX_DATAERR=65
}

@test "should print output to STDOUT" {
  image --stdout-only "$BUILD_TAG" --help
  assert_line "Usage: bats [OPTIONS] <tests>"
}

@test "should not print logs by default" {
  copy_fixture test.bats .
  image --stderr-only "$BUILD_TAG" .
  assert_output --regexp '▶▶ TEST RUN
 ℹ working directory: .*
 ℹ bats command line: bats --jobs 4 --no-parallelize-within-files --recursive --timing .'
}

@test "should print logs to STDERR with enabled DEBUG" {
  image --stderr-only --env DEBUG=1 "$BUILD_TAG" --help
  assert_line --partial "updating timezone to UTC"
}

@test "should print logs if errors occur" {
  image --code=$EX_DATAERR --stderr-only --env DEBUG=1 --env PUID=invalid "$BUILD_TAG" --help
  assert_line --partial "invalid user ID invalid"
}

@test "should print logs if errors occur with disabled DEBUG" {
  image --code=$EX_DATAERR --stderr-only --env DEBUG=0 --env PUID=invalid "$BUILD_TAG" --help
  refute_line --partial "updating timezone to UTC"
  assert_line --partial "invalid user ID invalid"
}

@test "should use rich console if terminal is connected" {
  TERM=xterm image --env DEBUG=1 --tty "$BUILD_TAG" --help
  assert_line --partial ''
  refute_line " ⚙ updating timezone to UTC"
}

@test "should use plain console if no terminal is connected" {
  TERM=xterm image --env DEBUG=1 "$BUILD_TAG" --help
  refute_line --partial ''
  assert_line "   updating timezone to UTC"
  assert_line " ✔ updating timezone to UTC"
}


@test "should replace entrypoint with user entrypoint" {
  copy_fixture test.bats .
  image --env DEBUG=1 "$BUILD_TAG" .
  refute_line --partial "entrypoint.sh"
}

@test "should replace user entrypoint with user process" {
  copy_fixture test.bats .
  image --env DEBUG=1 "$BUILD_TAG" .
  refute_line --partial "entrypoint_user.sh"
}
