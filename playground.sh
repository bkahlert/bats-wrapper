#!/usr/bin/env bash

mkdir -p build/batsw
rm -rf build/batsw
mkdir -p build/batsw
cd build/batsw || exit 1

BATS_CORE_VERSION=1.5.0
BATS_SUPPORT_VERSION=0.3.0
BATS_ASSERT_VERSION=2.0.0
BATS_FILE_VERSION=0.3.0

# /usr/local/bin
# /usr/local/libexec/bats-core
# /usr/local/lib/bats-core

mkdir -p opt/bats/lib/{support,assert,file}
(cd opt/bats && curl -LfsS "https://github.com/bats-core/bats-core/tarball/v${BATS_CORE_VERSION}" | tar --extract --gunzip --strip-components=1)
(cd opt/bats/lib/support && curl -LfsS "https://github.com/bats-core/bats-support/tarball/v${BATS_SUPPORT_VERSION}" | tar --extract --gunzip --strip-components=1)
(cd opt/bats/lib/assert && curl -LfsS "https://github.com/bats-core/bats-assert/tarball/v${BATS_ASSERT_VERSION}" | tar --extract --gunzip --strip-components=1)
(cd opt/bats/lib/file && curl -LfsS "https://github.com/bats-core/bats-file/tarball/v${BATS_FILE_VERSION}" | tar --extract --gunzip --strip-components=1)
