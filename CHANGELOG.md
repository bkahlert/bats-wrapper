# Changelog

## [Unreleased]

### Added

*none*

### Changed

*none*

### Deprecated

*none*

### Removed

*none*

### Fixed

*none*

## [0.2.0] - 2026-10-20

### Changed

- Upgrade Docker CLI to 29.9.1 on Alpine 3.24, Bats to 1.14.0,
  bats-assert to 2.2.4, bats-file to 0.4.0, and yasu to 1.20.1.
- Update the bundled Logr from 0.6.2 to 0.6.3, matching the container dependency.
- Upgrade workflow actions and the act test runner to 0.2.89.
- **Compatibility:** empty test suites now fail by default with Bats 1.14.
  Pass `--allow-empty-suite` to `batsw` when an empty suite is intentional.
- **Compatibility:** failed tests now fail the GitHub Action with the original
  test exit code instead of reporting success. Use `continue-on-error: true`
  when later steps need to inspect the action's `status` and `output` outputs.
- GitHub Action boolean inputs now honor `false` instead of enabling the flag.

### Fixed

- Preserve hierarchical Bats setup with a targeted wrapper hook and remove the
  obsolete bats-assert workaround.
- Fix bundled Logr spinner handling with Bash 5.3.
- Write GitHub Action outputs through `GITHUB_OUTPUT`, including on failure,
  and pass inputs through environment variables.
- Run the bundled wrapper against the locally built image, preserve local
  Docker Bake contexts, and remove duplicate builds.
- Correct test report artifact conditions and workflow permissions.
- Load Docker entrypoint helpers independently of `PATH`.


## [0.1.4] - 2021-12-06

### Changed

- upgrade to logr 0.6.2

## [0.1.3] - 2021-12-06

### Changed

- set `$SHELL` of test user to `/bin/bash`


## [0.1.2] - 2021-12-02

### Fixed

- support `--batsw:` style arguments also if script is downloaded and executed directly


## [0.1.1] - 2021-11-30

### Fixed

- correctly pass arguments to GitHub action


## [0.1.0] - 2021-11-29

### Added

- `batsw` self-contained wrapper to run Bats (Bash Automated Testing System) tests

[unreleased]: https://github.com/bkahlert/bats-wrapper/compare/v0.2.0...HEAD

[0.2.0]: https://github.com/bkahlert/bats-wrapper/compare/v0.1.4...v0.2.0

[0.1.4]: https://github.com/bkahlert/bats-wrapper/compare/v0.1.3...v0.1.4

[0.1.3]: https://github.com/bkahlert/bats-wrapper/compare/v0.1.2...v0.1.3

[0.1.2]: https://github.com/bkahlert/bats-wrapper/compare/v0.1.1...v0.1.2

[0.1.1]: https://github.com/bkahlert/bats-wrapper/compare/v0.1.0...v0.1.1

[0.1.0]: https://github.com/bkahlert/bats-wrapper/releases/tag/v0.1.0
