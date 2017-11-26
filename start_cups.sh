#! /bin/sh
#
# Start docker image that provides a CUPS instance
#

docker run --detach --restart always \
  --cap-add=SYS_ADMIN \
  -e "container=docker" \
  --name cups --hostname cups.fritz.box \
  -P \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v "$(pwd)"/user.env:/opt/cups/user.env:ro \
  thbe/cups
