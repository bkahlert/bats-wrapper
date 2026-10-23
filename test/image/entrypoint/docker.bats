#!/usr/bin/env bats
# shellcheck disable=SC2218

@test "should reuse the Docker socket group" {
  socket_image 0
}

@test "should create a missing Docker socket group" {
  socket_image 65532
}

@test "should keep the primary group matching the Docker socket" {
  socket_image 2001
}

@test "should keep a distinct app group as the primary group" {
  socket_image 65532 app-group
}

socket_image() {
  local -r socket_gid="$1"
  local -r app_group="${2:-tester}"
  bats_test <<'BATS' >test.bats
  run id -u
  assert_output '2000'
  run id -g
  assert_output '2001'
  run stat -c '%u:%g %a' /var/run/docker.sock
  assert_output "0:${SOCKET_GID} 660"
  [ -r /var/run/docker.sock ]
  [ -w /var/run/docker.sock ]
BATS
  IMAGE_PUID="echo 2000" IMAGE_PGID="echo 2001" image \
    --env "SOCKET_GID=$socket_gid" --env "APP_GROUP=$app_group" \
    --entrypoint bash "$BUILD_TAG" -ec '
      if [ "$APP_GROUP" != tester ]; then
        groupmod --new-name "$APP_GROUP" tester
        sed -i "s/app_group=tester/app_group=$APP_GROUP/" /usr/local/sbin/entrypoint.sh
      fi
      ssh-agent -a /var/run/docker.sock >/dev/null
      chown "0:$SOCKET_GID" /var/run/docker.sock
      chmod 0660 /var/run/docker.sock
      exec /usr/local/sbin/entrypoint.sh .
    '
}
