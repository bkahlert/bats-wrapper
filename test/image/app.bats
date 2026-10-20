#!/usr/bin/env bats

@test "should print help if specified" {
  image --stdout-only -i "$BUILD_TAG" --help
  assert_success
  assert_line "Usage: bats [OPTIONS] <tests>"
}

@test "should run tests" {
  bats_test <<<'run echo "foo"; assert_output "foo"' >test.bats
  image "$BUILD_TAG" .
  assert_output --regexp '▶▶ TEST RUN
 ℹ working directory: .*
 ℹ bats command line: bats --jobs [0-9]+ --no-parallelize-within-files --recursive --timing --no-tempdir-cleanup .
1..1
ok 1 test--[A-Za-z0-9]+ in [0-9]+ms'
}

@test "should run mounted tests with default user and temporary directory" {
  bats_test <<'BATS' >test.bats
  [ "$(id -u)" -eq 1000 ]
  [ -w /tmp ]
  run touch "$BATS_TEST_TMPDIR/writable"
  assert_success
BATS
  IMAGE_PUID='' IMAGE_PGID='' image -v "$PWD":/code:ro -w /code "$BUILD_TAG" .
  assert_line " ℹ working directory: /code"
  assert_line --regexp '^ok 1 test--[A-Za-z0-9]+ in [0-9]+ms$'
}

@test "should load installed logging helper regardless of PATH order" {
  bats_test <<<'run echo "foo"; assert_output "foo"' >test.bats
  echo 'exit 99' >logr.sh
  chmod +x logr.sh
  image -v "$PWD":/code:ro -w /code \
    -e PATH=/code:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    "$BUILD_TAG" .
  assert_line " ℹ working directory: /code"
  assert_line --regexp '^ok 1 test--[A-Za-z0-9]+ in [0-9]+ms$'
}

@test "should output completed files separately on redirected STDOUT" {
  mkdir tmp
  bats_test <<<'run echo "foo"; assert_output "foo"' >test.bats
  run bash -c "echo \"\$(BATSW_IMAGE='$BUILD_TAG' BATS_TMPDIR='$PWD/tmp' '$BATS_CWD/batsw' .)\""
  assert_success
  assert_output --regexp '▶▶ TEST RUN
 ℹ working directory: .*
 ℹ bats command line: bats --jobs [0-9]+ --no-parallelize-within-files --recursive --timing --no-tempdir-cleanup .
BATS_RUN_TMPDIR: .*
1..1
ok 1 test--[A-Za-z0-9]+ in [0-9]+ms'
}

@test "should output completed files separately on redirected STDERR" {
  mkdir tmp
  bats_test <<<'run echo "foo"; assert_output "foo"' >test.bats
  run bash -c "BATSW_IMAGE='$BUILD_TAG' BATS_TMPDIR='$PWD/tmp' '$BATS_CWD/batsw' . 2>/dev/null"
  assert_success
  assert_output --regexp '1..1'$'\n''ok 1 test--[A-Za-z0-9]+ in [0-9]+ms'
}
