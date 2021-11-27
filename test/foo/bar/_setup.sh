#!/usr/bin/env bash

basename "${BASH_SOURCE[0]%/*}" >>"$BATS_TEST_TMPDIR/setup.out"
