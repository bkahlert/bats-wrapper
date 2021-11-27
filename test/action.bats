#!/usr/bin/env bats

setup() {
  cp -R action.yml "$BATS_TEST_TMPDIR"
  cp -R logr.sh "$BATS_TEST_TMPDIR"
  cp -R batsw "$BATS_TEST_TMPDIR"
  cp -R .git "$BATS_TEST_TMPDIR"
  copy_fixture test.bats "$BATS_TEST_TMPDIR"
}

actw() {
  local wrapper_name=${FUNCNAME[0]}
  local -a args=() wrapper_args=()
  while (($#)); do
    case $1 in
      --${wrapper_name?}:*)
        wrapper_args+=("${1#--${wrapper_name?}:}")
        ;;
      *)
        args+=("$1")
        ;;
    esac
    shift
  done
  set -- "${args[@]}"

  local -a opts=()
  opts+=("-e" "TESTING=${TESTING-}")
  opts+=("-e" "RECORDING=${RECORDING-}")
  opts+=("-e" "TERM=${TERM-}")
  opts+=("-e" "BATS_TMPDIR=${BATS_TMPDIR-}")

  # Adds the given arguments to the opts array
  opts() { eval 'opts+=("$@")'; }
  [ ! -t 0 ] || opts+=("--interactive")
  [ ! -t 1 ] || [ ! -t 2 ] || [ "${TERM-}" = dumb ] || opts+=("--tty")
  [ ! -v ACTW_ARGS ] || eval opts "$ACTW_ARGS"
  opts+=("${wrapper_args[@]}")
  opts+=("--rm")
  opts+=("--name" "$wrapper_name--$(head /dev/urandom | LC_ALL=C.UTF-8 tr -dc A-Za-z0-9 2>/dev/null | head -c 3)")
  opts+=("${ACTW_IMAGE:-efrecon/act:${ACTW_IMAGE_TAG:-v0.2.24}}")

  docker run \
    -e DEBUG="${DEBUG-}" \
    -e TZ="$(date +"%Z")" \
    -e PUID="$(id -u)" \
    -e PGID="$(id -g)" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$PWD":"$PWD" \
    -w "$PWD" \
    "${opts[@]+"${opts[@]}"}" \
    "$@"
}

# Note: --env arguments are not passed to the act wrapper but to act itself which
#       provides the corresponding environment variables inside the workflow
act() {
  export BATSW_ARGS
  BATSW_ARGS=$(
    cat <<BATSW_ARGS
-v "$PWD/logr.sh":/usr/local/bin/logr.sh
BATSW_ARGS
  )

  actw \
    --bind \
    --env TESTING="${TESTING-}" \
    --env RECORDING="${RECORDING-}" \
    --env TERM="${TERM-}" \
    --env BATS_TMPDIR="${BATS_TMPDIR-}" \
    --env BATSW_IMAGE_TAG=edge \
    --env BATSW_ARGS="${BATSW_ARGS-}" \
    --platform ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest \
    "$@"
}

@test "should run action" {
  # TODO
  skip

  local workflows="$BATS_TEST_TMPDIR/.github/workflows"
  mkdir -p "$workflows"
  cat <<WORKFLOW >"$workflows/act-test.yml"
name: test workflow
on: [push,workflow_dispatch]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Run Bats tests
        id: bats
        uses: ./
        with:
          tests: test
WORKFLOW

  run act -j test
  assert_output --partial '[test workflow/test]   ⚙  ::set-output:: status=0
[test workflow/test]   ⚙  ::set-output:: output=TODO'
  assert_output --partial '[test workflow/test]   ✅  Success - Run Bats tests'
}
