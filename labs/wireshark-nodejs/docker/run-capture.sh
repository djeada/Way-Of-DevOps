#!/bin/sh
# Run ONE lab and packet capture entirely inside the container network namespace.
set -eu
num="${1:-}"
case "$num" in
  1|01) num=01; file=01-tcp-handshake.js; filter='tcp port 4101' ;;
  2|02) num=02; file=02-http-get.js; filter='tcp port 4102' ;;
  3|03) num=03; file=03-http-post-json.js; filter='tcp port 4103' ;;
  4|04) num=04; file=04-http-status.js; filter='tcp port 4104' ;;
  5|05) num=05; file=05-udp-echo.js; filter='udp port 4105' ;;
  6|06) num=06; file=06-tcp-vs-udp.js; filter='tcp port 4106 or udp port 4106' ;;
  7|07) num=07; file=07-tcp-framing.js; filter='tcp port 4107' ;;
  8|08) num=08; file=08-local-dns.js; filter='udp port 4108' ;;
  9|09) num=09; file=09-https-tls.js; filter='tcp port 4109' ;;
  10) num=10; file=10-troubleshooting.js; filter='tcp port 4110 or tcp port 4199' ;;
  *) echo 'Usage: run-capture 01..10' >&2; exit 2 ;;
esac
if [ ! -d /captures ]; then echo 'Missing /captures mount. Use supplied host launcher.' >&2; exit 2; fi
mkdir -p /tmp/lab/labs /tmp/lab/certs
cp -a /app/labs/. /tmp/lab/labs/
cp /app/setup-cert.js /tmp/lab/
cd /tmp/lab
if [ "$num" = 09 ]; then node setup-cert.js; fi
outfile="/captures/lab-${num}.pcap"
echo "Capturing isolated loopback for Lab ${num} to ${outfile}"
tcpdump -i lo -n -s 0 -U -w "$outfile" "$filter" >/tmp/tcpdump.log 2>&1 &
cap_pid=$!
cleanup() { kill -INT "$cap_pid" 2>/dev/null || true; wait "$cap_pid" 2>/dev/null || true; }
trap 'cleanup' EXIT INT TERM
sleep 1
if ! kill -0 "$cap_pid" 2>/dev/null; then cat /tmp/tcpdump.log >&2; exit 1; fi
status=0
node "labs/$file" || status=$?
cleanup
trap - EXIT INT TERM
chmod 0644 "$outfile" 2>/dev/null || true
if [ "$status" -ne 0 ]; then cat /tmp/tcpdump.log >&2; exit "$status"; fi
if [ ! -s "$outfile" ]; then cat /tmp/tcpdump.log >&2; exit 1; fi
ls -lh "$outfile"
echo "Lab ${num} complete. Open ${outfile} in Wireshark (do NOT capture host network)."
