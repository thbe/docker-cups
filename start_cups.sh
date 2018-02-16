#! /bin/sh
#
# Start docker image that provides a CUPS instance
#

CUPS_PASSWORD=pass

docker run --detach --restart always \
  --cap-add=SYS_ADMIN \
  -e "container=docker" \
  -e CUPS_ENV_HOST="$(hostname)" \
  -e CUPS_ENV_PASSWORD="${CUPS_PASSWORD}" \
  -e CUPS_ENV_DEBUG="${CUPS_DEBUG}" \
  --name cups --hostname cups.fritz.box \
  -p 137:137/udp -p 139:139/tcp -p 445:445/tcp \
  -p 631:631/tcp -p 5353:5353/udp \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v "$(pwd)"/user.env:/opt/cups/user.env:ro \
  thbe/cups
