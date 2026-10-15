#!/bin/sh
set -eu
cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then echo 'Usage: ./run-isolated.sh 01..10' >&2; exit 2; fi
if ! docker image inspect wireshark-node-labs:isolated >/dev/null 2>&1; then echo 'Build first: docker build -t wireshark-node-labs:isolated .' >&2; exit 1; fi
mkdir -p captures
docker run --rm --network none --cap-drop ALL --cap-add NET_RAW --security-opt no-new-privileges --read-only --tmpfs /tmp:rw,nosuid,nodev,size=64m --pids-limit 64 --mount "type=bind,source=$(pwd)/captures,target=/captures" wireshark-node-labs:isolated "$1"
