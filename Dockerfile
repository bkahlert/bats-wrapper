FROM docker:20.10.12-alpine3.14

# build time only options
ARG BATS_CORE_VERSION=1.5.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.0.0
ARG BATS_FILE_VERSION=0.3.0
ARG LOGR_VERSION=0.6.2
ARG APP_USER=tester
ARG APP_GROUP=$APP_USER

# build and run time options
ARG DEBUG=0
ARG TZ=UTC
ARG LANG=C.UTF-8
ARG PUID=1000
ARG PGID=1000

# dependencies
# as of 2021-06-21 BusyBox's sed does not seem to properly support curly quantifiers; therefore GNU sed
RUN apk --no-cache --update add \
    bash \
    ca-certificates \
    curl \
    dumb-init \
    docker-cli \
    expect \
    git \
    jq \
    ncurses \
    parallel \
    openssh-client \
    sed \
    shadow \
    sshpass

# app setup
COPY --from=crazymax/yasu:1.17.0 / /
COPY rootfs /
RUN chmod +x \
    /usr/local/sbin/entrypoint.sh \
    /usr/local/bin/entrypoint_user.sh \
 && sed -Ei -e "s/([[:space:]]app_user=)[^[:space:]]*/\1$APP_USER/" \
            -e "s/([[:space:]]app_group=)[^[:space:]]*/\1$APP_GROUP/" \
             /usr/local/sbin/entrypoint.sh \
 && curl -LfsSo /usr/local/bin/logr.sh https://github.com/bkahlert/logr/releases/download/v${LOGR_VERSION}/logr.sh \
 && mkdir -p opt/bats/lib/{support,assert,file} \
 && ( \
    cd opt/bats \
 && curl -LfsS "https://github.com/bats-core/bats-core/tarball/v${BATS_CORE_VERSION}" \
  | tar -xz --strip-components=1 \
    ) \
 && ( \
    mkdir -p opt/bats/lib/support \
 && cd opt/bats/lib/support \
 && curl -LfsS "https://github.com/bats-core/bats-support/tarball/v${BATS_SUPPORT_VERSION}" \
  | tar -xz --strip-components=1 \
    ) \
 && ( \
    mkdir -p opt/bats/lib/assert \
 && cd opt/bats/lib/assert \
 && curl -LfsS "https://github.com/bats-core/bats-assert/tarball/v${BATS_ASSERT_VERSION}" \
  | tar -xz --strip-components=1 \
    ) \
 && ( \
    mkdir -p opt/bats/lib/file \
 && cd opt/bats/lib/file \
 && curl -LfsS "https://github.com/bats-core/bats-file/tarball/v${BATS_FILE_VERSION}" \
  | tar -xz --strip-components=1 \
    ) \
 && ln -s /opt/bats/bin/bats /usr/local/bin/bats \
 && find /opt/bats -type d -name "test" -exec rm -rf {} + \
 && test_functions_path="/opt/bats/lib/bats-core/test_functions.bash" \
 && test_functions=$(cat "$test_functions_path") \
 && test_functions=${test_functions//setup/wrapped_setup} \
 && test_functions=${test_functions//wrapped_setup() {/'wrapped_setup() {'$'\n'"  source '${test_functions_path%/*/*}/wrapper/load.bash'"} \
 && echo "$test_functions" >"$test_functions_path"

# env setup
ENV DEBUG="$DEBUG" \
    TZ="$TZ" \
    LANG="$LANG" \
    PUID="$PUID" \
    PGID="$PGID"

# user setup
RUN groupadd \
    --gid "$PGID" \
    "$APP_GROUP" \
 && useradd \
    --comment "app user" \
    --uid $PUID \
    --gid "$APP_GROUP" \
    --shell /bin/bash \
    "$APP_USER" \
 && mkdir -p ~/.parallel && touch ~/.parallel/will-cite # accept citation notice

# finalization
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/sbin/entrypoint.sh"]
