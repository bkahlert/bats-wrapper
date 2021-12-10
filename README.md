# bkahlert/bats-wrapper [![Build Status](https://img.shields.io/github/workflow/status/bkahlert/bats-wrapper/build?label=Build&logo=github&logoColor=fff)](https://github.com/bkahlert/bats-wrapper/actions/workflows/build.yml) [![Repository Size](https://img.shields.io/github/repo-size/bkahlert/bats-wrapper?color=01818F&label=Repo%20Size&logo=Git&logoColor=fff)](https://github.com/bkahlert/bats-wrapper) [![Repository Size](https://img.shields.io/github/license/bkahlert/bats-wrapper?color=29ABE2&label=License&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1OTAgNTkwIiAgeG1sbnM6dj0iaHR0cHM6Ly92ZWN0YS5pby9uYW5vIj48cGF0aCBkPSJNMzI4LjcgMzk1LjhjNDAuMy0xNSA2MS40LTQzLjggNjEuNC05My40UzM0OC4zIDIwOSAyOTYgMjA4LjljLTU1LjEtLjEtOTYuOCA0My42LTk2LjEgOTMuNXMyNC40IDgzIDYyLjQgOTQuOUwxOTUgNTYzQzEwNC44IDUzOS43IDEzLjIgNDMzLjMgMTMuMiAzMDIuNCAxMy4yIDE0Ny4zIDEzNy44IDIxLjUgMjk0IDIxLjVzMjgyLjggMTI1LjcgMjgyLjggMjgwLjhjMCAxMzMtOTAuOCAyMzcuOS0xODIuOSAyNjEuMWwtNjUuMi0xNjcuNnoiIGZpbGw9IiNmZmYiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxOS4yMTIiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4%3D)](https://github.com/bkahlert/bats-wrapper/blob/master/LICENSE)

## About

**Bats Wrapper** is a self-contained wrapper to run tests based on the Bash testing framework [Bats](https://github.com/bats-core/) with some differences:
- To facilitate testing of Dockerfiles the Docker command line tools is pre-installed and   
  `docker buildx bake` is called if `$DOCKER_BAKE` is set (with its contents as the arguments).
- The environment variable `TESTING` is set to `1` while running tests.
- The following arguments are set by default:
  - `--jobs` (with the number of processors or `4` or they cannot be determined) 
  - `--no-parallelize-within-files`
  - `--no-tempdir-cleanup`
  - `--recursive`
  - `--timing`
- The following extensions are loaded by default (and patched to support the `nounset` shell option):
  - [bats-support](https://github.com/bats-core/bats-support)
  - [bats-assert](https://github.com/bats-core/bats-assert)
  - [bats-file](https://github.com/bats-core/bats-file)
- Helper script with the name `_setup.sh` are automatically sourced  
  (with the `_setup.sh` located in the same directory as the `bats` test file sourced last)
  ```text
  📁work             ⬅︎ you are here  
  ├─📁src
  └─📁test
    ├─🔧_setup.sh    … automatically sourced
    ├─📄foo.bats
    └─📁bar
      ├─🔧_setup.sh  … automatically sourced
      └─📄baz.bats
  ```
- The working directory for each test is `$BATS_TEST_TMPDIR`.
- To focus on a single or a couple of tests an *alternative to the `--filter` option*
  is to prefix a test name with `x` or `X`:  
  ```bash
  @test "foo" {
    ...
  }

  @test "Xbar" {
    ...
  }
  ```
  The above example will only execute `Xbar` without you having to change the command line.
- Several extensions are provided:
  - `copy_fixture` to handle fixtures 
  - `expect` for tests that require interaction
  - Check [wrapper.sh](rootfs/opt/bats/lib/wrapper/wrapper.sh) for all extensions.

[![recorded terminal session demonstrating the Bats wrapper](docs/demo.svg "Bats Wrapper Demo")  
*Bats Wrapper Demo*](../../raw/master/docs/demo.svg)

## Docker image

### Build locally

```shell
git clone https://github.com/bkahlert/bats-wrapper.git
cd bats-wrapper

# Build image and output to docker (default)
docker buildx bake

# Build multi-platform image
docker buildx bake image-all
```

### Image

* [Docker Hub](https://hub.docker.com/r/bkahlert/bats-wrapper/) `bkahlert/bats-wrapper`
* [GitHub Container Registry](https://github.com/users/bkahlert/packages/container/package/bats-wrapper) `ghcr.io/bkahlert/bats-wrapper`

Following platforms for this image are available:

* linux/amd64
* linux/arm64/v8

## Usage

The Docker container passes all arguments to the wrapped Bash testing framework [Bats](https://github.com/bats-core/)
and therefore inherits [all its supported options](https://bats-core.readthedocs.io/en/stable/usage.html).

### Docker image

```shell
docker run -it --rm \
  -e TERM="$TERM" \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  bkahlert/bats-wrapper [OPTIONS] TEST [TEST...]
```

### Wrapper

The Bats Wrapper `batsw` needs nothing but a working Docker installation and either [`curl`](https://curl.se/download.html)
, [`wget`](http://wget.addictivecode.org/FrequentlyAskedQuestions.html#download),
or [`wget2`](https://gitlab.com/gnuwget/wget2#downloading-and-building-from-tarball):

#### curl

```shell
curl -LfsS https://git.io/batsw | "$SHELL" -s -- [OPTIONS] TEST [TEST...]
```

#### wget

```shell
wget -qO- https://git.io/batsw | "$SHELL" -s -- [OPTIONS] TEST [TEST...]
```

#### wget2

```shell
wget2 -nv -O- https://git.io/batsw | "$SHELL" -s -- [OPTIONS] TEST [TEST...]
```

### GitHub Action

The Bats Wrapper can also be used to run your Bats based tests right inside your GitHub workflow.

#### Usage Example

```yml
jobs:
  docs:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Run Bats tests
        id: bats
        uses: bkahlert/bats-wrapper@v0.1.4
        with:
          tests: test
```

All [described options](#usage) can be used to customize the test run. Please consult [action.yml](action.yml) for detailed information. 

## Image Configuration

This image can be configured using the following options of which all but `APP_USER` and `APP_GROUP` exist as both—build argument and environment variable.  
You should go for build arguments if you want to set custom defaults you don't intend to change (often). Environment variables will overrule any existing
configuration on each container start.

- `APP_USER` Name of the main user (default: `bats`)
- `APP_GROUP` Name of the main user's group (default: `bats`)
- `DEBUG` Whether to log debug information (default: `0`)
- `TZ` Timezone the container runs in (default: `UTC`)
- `LANG` Language/locale to use (default: `C.UTF-8`)
- `PUID` User ID of the `libguestfs` user (default: `1000`)
- `PGID` Group ID of the `libguestfs` group (default: `1000`)

```shell
# Build single image with build argument TZ
docker buildx bake --build-arg TZ="$(date +"%Z")"

# Build multi-platform image with build argument TZ
docker buildx bake image-all --build-arg TZ="$(date +"%Z")"

# Start container with environment variable TZ
docker run --rm \
  -e TZ="$(date +"%Z")" \
  -v "$(pwd):$(pwd)" \
  -w "$(pwd)" \
  bats-wrapper:local
```

## Testing

```shell
git clone https://github.com/bkahlert/bats-wrapper.git
cd bats-wrapper

# Use Bats wrapper to build the Docker image and run the tests
chmod +x ./batsw
DOCKER_BAKE="--set '*.tags=test'" BATSW_IMAGE=test:latest \
  ./batsw --batsw:-e --batsw:BUILD_TAG=test test
```

## Troubleshooting

- To avoid permission problems with generated files, you can use your local user/group ID (see `PUID`/`PGID`).
- If you need access to Docker, its command line interface is already installed.  
  You can control your host instance by mounting `/var/run/docker.sock`.

```shell
docker run -it --rm \
  -e PUID="$(id -u)" \
  -e PGID="$(id -g)" \
  -e TERM="$TERM" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":"$PWD" \
  -w "$PWD" \
  bkahlert/bats-wrapper:edge
```

## Contributing

Want to contribute? Awesome! The most basic way to show your support is to star the project, or to raise issues. You can also support this project by making
a [Paypal donation](https://www.paypal.me/bkahlert) to ensure this journey continues indefinitely!

Thanks again for your support, it is much appreciated! :pray:

## License

MIT. See [LICENSE](LICENSE) for more details.
