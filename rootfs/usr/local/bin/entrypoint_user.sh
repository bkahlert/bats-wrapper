#!/usr/bin/env bash

source logr.sh

# Run the specified tests concurrently and recursively using Bats.
# Arguments:
#   * - bats arguments
bats() {
  local -a opts=()
  opts+=("--jobs" "$(nproc 2>/dev/null || echo 4)")
  opts+=("--no-parallelize-within-files")
  opts+=("--recursive")
  opts+=("--timing")
  opts+=("$@")

  logr info "bats command line: bats ${opts[*]}" >&2
  exec "$(which bats)" "${opts[@]+"${opts[@]}"}"
}

# Prepares the Bats environment and
# runs the specified tests using the included Bats wrapper.
# Arguments:
#   * - bats arguments
# bashsupport disable=BP2001,BP5006
main() {
  local -a opts=()
  while (($#)); do
    case "$1" in
      -o | --output)
        if [ "${2-}" ] && [ "${2:0:1}" != "-" ]; then
          mkdir -p "$2"
          opts+=("$1" "$2")
          shift 2
        else
          [ "${2-}" ] || logr error "value of $1 missing"
        fi
        ;;
      *)
        opts+=("$1")
        shift
        ;;
    esac
  done

  [ -e "$TMPDIR" ] || mkdir -p "$TMPDIR" || die "'$TMPDIR' could not be created"

  echo "${esc_hpa0-}${esc_green-}▶▶${esc_reset-} ${esc_bold-}TEST RUN${esc_reset-}" >&2
  logr info "working directory: $PWD" >&2

  # Checks for tests starting with capital X.
  # If such exist, focus on them and ignore the others.
  local highlighted_tests_args=('--filter' '^[Xx]')
  local highlighted_tests=0
  local highlighted_cmdline=(bats --count "${highlighted_tests_args[@]}" "${opts[@]+"${opts[@]}"}")
  if ! highlighted_tests=$(TERM=dumb "${highlighted_cmdline[@]}" 2>/dev/null); then
    logr warn "failed to find highlighted tests; command line used: ${highlighted_cmdline[*]}"
  fi

  if [ "$highlighted_tests" = "0" ]; then
    bats "${opts[@]+"${opts[@]}"}"
  else
    bats "${highlighted_tests_args[@]}" "--no-tempdir-cleanup" "${opts[@]+"${opts[@]}"}"
  fi
}

main "$@"

# ./bats --jobs 12 --no-parallelize-within-files --recursive --timing --count --filter ^[Xx] test
