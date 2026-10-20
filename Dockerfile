FROM docker:29.9.1-cli-alpine3.24

# build time only options
ARG BATS_CORE_VERSION=1.14.0
ARG BATS_SUPPORT_VERSION=0.3.0
ARG BATS_ASSERT_VERSION=2.2.4
ARG BATS_FILE_VERSION=0.4.0
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
COPY --from=crazymax/yasu:1.20.1 / /
COPY rootfs /
RUN chmod +x \
    /usr/local/sbin/entrypoint.sh \
    /usr/local/bin/entrypoint_user.sh \
 && sed -Ei -e "s/([[:space:]]app_user=)[^[:space:]]*/\1$APP_USER/" \
            -e "s/([[:space:]]app_group=)[^[:space:]]*/\1$APP_GROUP/" \
             /usr/local/sbin/entrypoint.sh \
 && curl -LfsSo /usr/local/bin/logr.sh https://github.com/bkahlert/logr/releases/download/v${LOGR_VERSION}/logr.sh \
 && sed -i -e "s/jobs -pr 'spinner _spin'/jobs -pr '%spinner _spin'/g" \
           -e 's/| xargs -r kill$/| xargs -r kill 2>\/dev\/null || true/' /usr/local/bin/logr.sh \
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
 && test_runner="/opt/bats/libexec/bats-core/bats-exec-test" \
 && grep -q '^    setup "\$@"$' "$test_runner" \
 && sed -i 's|^    setup "\$@"$|    source /opt/bats/lib/wrapper/load.bash|' "$test_runner"

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
