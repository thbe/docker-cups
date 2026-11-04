#!/bin/sh
# Smoke test: build, start, wait for HTTP http://localhost:16631/, check no restart/crash. Usage: ./test.sh
set -eu
IMG=thbe/cups:test; C=t-cups; trap 'docker rm -f $C >/dev/null 2>&1' EXIT
docker build -q --pull --load -t "$IMG" "$(dirname "$0")" >/dev/null
docker run -d --name $C -p 16631:631 "$IMG" >/dev/null
for i in $(seq 1 60); do
  curl -ksf -o /dev/null http://localhost:16631/ && { echo "PASS cups ($i s)"; exit 0; }
  [ "$(docker inspect -f '{{.State.Running}}' $C)" = true ] || break
  sleep 1
done
docker logs $C 2>&1 | tail -20; echo "FAIL cups"; exit 1
