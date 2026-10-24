# DevOps Foundations Quiz

Notes: [Linux, Git, and scripting](../notes/linux_and_scripting.md), [Networking and HTTP](../notes/networking.md), [Virtual machines and VirtualBox](../notes/virtualbox.md), [Inter-process communication](../notes/ipc.md)

Check your understanding of inspecting Linux systems, Git, safe scripts, troubleshooting requests, VM networking and IPC.

#### Q. A web service works with `curl http://127.0.0.1:8080/` on the server, but other machines cannot connect. `ss -lnt` shows the listener as `127.0.0.1:8080`. What is the most likely cause?

* [x] The service is bound only to the loopback interface
* [ ] The service is accepting UDP rather than TCP connections
* [ ] The DNS record for the server has an expired TTL
* [ ] The kernel has run out of ephemeral client ports

> **Explanation:** A listener on `127.0.0.1` accepts connections only from the same host or network namespace. It must listen on a reachable interface (or `0.0.0.0`) before firewalls or DNS even matter. `ss -lnt` lists TCP listeners, so UDP is not the issue.

#### Q. `curl` fails instantly with "Connection refused" when connecting to a server's port 9000. What does this most often indicate?

* [ ] A firewall is silently dropping the client's packets
* [x] Nothing is listening there, or the host rejected it
* [ ] The TLS certificate for the server has expired
* [ ] The HTTP application returned a 5xx response

> **Explanation:** A refusal is an active answer, usually because no process listens on that address and port or something explicitly rejects the connection. Silent filtering typically produces a timeout instead, and TLS or HTTP errors only appear after a connection succeeds.

#### Q. `ping api.internal` succeeds, but an HTTPS request to the same host times out. What can you conclude?

* [ ] The HTTPS service must be healthy, so the client is misconfigured
* [ ] The DNS answer is stale and points the client at the wrong host
* [x] The host answers ICMP, which says nothing about the TCP port or app
* [ ] The TLS certificate chain is invalid and the handshake was dropped

> **Explanation:** A successful ping proves only that ICMP echo works. The TCP port may be filtered, unbound or served by a stalled application. Test the actual port and protocol, for example with `curl --verbose --max-time 5`.

#### Q. `curl --verbose https://shop.example/` prints "Could not resolve host". Which layer failed?

* [x] Name resolution, so no connection or TLS was attempted
* [ ] TLS negotiation, after the TCP connection was established
* [ ] The HTTP application, which rejected the request headers
* [ ] Routing, after the client chose the server's IP address

> **Explanation:** Requests are troubleshot in layers: name resolution, routing, connection, TLS, then HTTP. If the name cannot be resolved, the client never obtains an address, so the later layers never run.

#### Q. An application container calls `http://localhost:5432` to reach a database running in a different container, and the connection fails. Why?

* [ ] Containers cannot open TCP connections to databases
* [x] `localhost` refers to the app container's own namespace
* [ ] Port 5432 is reserved for the container runtime itself
* [ ] The database requires a Unix socket for every client

> **Explanation:** Each container normally has its own network namespace, so `localhost` is the container itself, not the host or a sibling container. Use the other service's reachable name or address, such as a Compose service name.

#### Q. In the web server lab, Apache is stopped while Nginx keeps running as the reverse proxy. Which result is expected for a request to `/apache/`?

* [ ] `404 Not Found`, because the Apache page was removed
* [ ] `200 OK`, because Nginx's `/healthz` still passes
* [x] `502 Bad Gateway`, because the upstream is unreachable
* [ ] `401 Unauthorized`, because the proxy lost its session

> **Explanation:** A gateway that cannot get a valid response from its upstream typically returns 502. Nginx's own `/healthz` checks only Nginx, so the gateway can look healthy while a dependency is down.

#### Q. A dashboard shows a jump in 5xx responses at the load balancer. What is the best first interpretation?

* [ ] Clients are sending malformed requests or invalid credentials
* [x] A server-side component in the serving path is failing
* [ ] Browsers are refusing the site's TLS certificate
* [ ] DNS resolvers are returning the wrong record for the site

> **Explanation:** 5xx codes indicate a server-side failure somewhere along the serving path, while 4xx usually describes a client-side request or access problem. Next, find which component generated the response: proxy, application or dependency.

#### Q. Which transport does HTTP/3 use?

* [ ] TCP with TLS 1.2
* [x] QUIC over UDP
* [ ] SCTP over IP
* [ ] Raw IP datagrams

> **Explanation:** HTTP/1.1 and HTTP/2 commonly run over TCP, while HTTP/3 uses QUIC, which runs over UDP and builds its own reliability and encryption on top.

#### Q. A sensor sends readings over UDP. The receiver sees some readings missing and others out of order. What is the correct interpretation?

* [ ] The network is faulty, because UDP retransmits lost datagrams
* [ ] The receiver is misconfigured, since UDP preserves send order
* [x] This is allowed; UDP has no delivery or ordering guarantees
* [ ] The sender must switch to HTTP/2 to keep using UDP datagrams

> **Explanation:** UDP provides datagrams without built-in delivery or ordering guarantees. Applications that need them must add sequence numbers, acknowledgments or retries, or use a transport such as TCP.

#### Q. After changing a DNS A record to a new server, some clients keep connecting to the old address for a while. What best explains this?

* [ ] The old server is forwarding all traffic back to itself
* [x] Resolvers cache the previous answer until its TTL expires
* [ ] A records only change after the TLS certificate is renewed
* [ ] Clients always pin the first IP they ever resolved for a name

> **Explanation:** DNS answers are cached according to their time-to-live and resolver behavior, so clients may keep the old address until cached entries expire. Lowering the TTL ahead of a planned change shortens this window.

#### Q. A site uses HTTPS with a valid certificate. A logged-in user changes `/invoices/1001` to `/invoices/1002` and sees another customer's invoice. What is missing?

* [ ] A stronger TLS cipher suite on the load balancer
* [ ] A longer certificate chain from a public authority
* [x] An application authorization check on each record
* [ ] A shorter DNS TTL for the application's hostname

> **Explanation:** TLS authenticates the server and protects data in transit; it does not decide whether an authenticated user may access a particular record. The application must check that the invoice belongs to the requesting user.

#### Q. A browser rejects `https://api.example.com` with a name mismatch error. The certificate is valid and unexpired but issued only for `www.example.com`. What is the fix?

* [ ] Lower the DNS TTL so browsers refetch the certificate
* [x] Serve a certificate that covers `api.example.com`
* [ ] Switch the API to HTTP/3 so the check is skipped
* [ ] Tell users to disable certificate verification

> **Explanation:** TLS validation checks the chain, expiry and expected hostname. A certificate for a different name fails the hostname check, so the server needs a certificate whose names include the requested host. Disabling verification removes the protection.

#### Q. After enabling a CDN, some users see another user's account page. What is the most likely cause?

* [ ] The CDN's TLS certificate expired during the rollout
* [ ] The origin returned 5xx responses that the CDN retried
* [x] A personalized response was cached under a shared key
* [ ] The DNS TTL was too short for the CDN's edge locations

> **Explanation:** Cache keys and expiry affect correctness as well as performance. If a personalized response is cached under a key shared by many users, the CDN serves it to the wrong people. Mark such responses uncacheable or vary the key appropriately.

#### Q. A client's `POST /payments` request times out and the client wants to retry automatically. What makes the retry safe?

* [x] An idempotency key that the server uses to deduplicate the request
* [ ] An unlimited number of immediate retries until a response arrives
* [ ] Switching the request from `POST` to a cached `GET` on the retry
* [ ] A longer DNS TTL so the retry reaches the same backend server

> **Explanation:** The first attempt may have succeeded before the timeout, so retrying a state-changing request can charge twice. An idempotency key with server-side deduplication makes repeats harmless; retries should also be limited and use backoff.

#### Q. On a systemd-based Linux host, which command shows the logs of the `nginx` service?

* [ ] `du -sh /var/log/nginx`
* [x] `journalctl -u nginx`
* [ ] `ps -ef | grep nginx`
* [ ] `id nginx`

> **Explanation:** `journalctl -u <unit>` reads the systemd journal for one unit, and `systemctl` manages and inspects the unit itself. `du` shows disk usage, `ps` lists processes and `id` shows a user's identity and groups.

#### Q. You edited a file and ran `git add` on it. Now `git diff` prints nothing. How do you review what will be committed?

* [ ] Run `git log --oneline -5`
* [x] Run `git diff --cached`
* [ ] Run `git status --ignored`
* [ ] Run `git revert HEAD`

> **Explanation:** `git diff` compares the working tree with the staging area, so staged changes no longer appear there. `git diff --cached` shows staged changes compared with the last commit.

#### Q. A commit that broke production has already been pushed to the shared `main` branch, and teammates have pulled it. What is the safest way to undo it?

* [ ] `git reset --hard HEAD~1` followed by a force push
* [x] `git revert <commit>` and push the new commit
* [ ] `git commit --amend` and push the amended commit
* [ ] Delete `main` on the remote and push a fresh copy

> **Explanation:** `git revert` records a new inverse commit, so history stays intact for everyone who has already pulled. Resetting, amending or recreating the branch rewrites shared history and disrupts other clones.

#### Q. A developer committed `.env` containing a database password, then deleted the file and added `.env` to `.gitignore`. What must happen next?

* [ ] Nothing, because `.gitignore` removes the file from history
* [ ] Only rename the variable so the old password is not used
* [x] Revoke or replace the password, since it remains in history
* [ ] Make the repository private, which invalidates the secret

> **Explanation:** A `.gitignore` rule only stops untracked files from being added; earlier commits still contain the password, and clones may already have it. Treat it as exposed: revoke or rotate it first, then plan any history cleanup.

#### Q. A script uses `set -e`, but it continues after `curl` fails in the line below. Why?

```bash
set -e
curl -fsS https://example.com/data.json | tee data.json
echo "done"
```

* [ ] `set -e` only applies to commands inside functions
* [x] A pipeline's status comes from `tee` unless `pipefail` is set
* [ ] `curl -f` stops `curl` from ever returning a non-zero exit code
* [ ] `tee` restarts `curl` automatically when it exits early

> **Explanation:** Without `set -o pipefail`, a pipeline's exit status is that of its last command, here `tee`, which succeeded. With `pipefail`, the pipeline fails if any command in it fails, so `set -e` stops the script.

#### Q. The script below is run with no arguments. Where does it write its report?

```bash
#!/usr/bin/env bash
set -euo pipefail
report_dir=${1:-./reports}
mkdir -p -- "$report_dir"
df -h -- "$report_dir" > "$report_dir/disk.txt"
```

* [ ] It exits with an unbound variable error from `set -u`
* [x] `./reports/disk.txt`
* [ ] `./disk.txt` in the current directory
* [ ] It prints to the terminal and writes no file

> **Explanation:** `${1:-./reports}` uses `./reports` when the first argument is unset or empty, and this form is safe under `set -u`. `mkdir -p` creates the directory if needed, so the report lands in `./reports/disk.txt`.

#### Q. Why does a rerunnable script use `mkdir -p -- "$dir"` instead of `mkdir $dir`?

* [x] It succeeds if the directory exists and handles spaces in the name
* [ ] It deletes and recreates the directory to guarantee a clean state
* [ ] It runs the command with root privileges when permission is denied
* [ ] It makes the directory private to the current user automatically

> **Explanation:** `-p` creates parent directories and does not fail when the directory already exists, so the script can run again. Quoting prevents word splitting and globbing of the value, and `--` stops a name starting with `-` being read as an option.

#### Q. A Bash script that started as five commands now parses JSON API responses and has several nested branches. What do the notes recommend?

* [ ] Add more `set` options so Bash catches the parsing errors
* [ ] Move the logic into a scheduled cron entry with no script
* [x] Move it to a language such as Python as the logic grows
* [ ] Split it into many one-line aliases in each user's profile

> **Explanation:** Bash suits short, shell-oriented tasks. When parsing and logic grow, a language such as Python makes structure, error handling and testing easier.

#### Q. Which of these is a type 1 hypervisor?

* [ ] Oracle VirtualBox
* [x] VMware ESXi
* [ ] VMware Workstation
* [ ] Docker Engine

> **Explanation:** A type 1 hypervisor runs directly on hardware, as ESXi and Hyper-V do. VirtualBox and VMware Workstation run on a host operating system (type 2), and Docker Engine runs containers rather than virtual machines.

#### Q. A VirtualBox guest using a NAT adapter runs a web server on port 80, but the host's browser cannot reach it. What is the usual fix while keeping NAT mode?

* [ ] Enable a second NAT adapter on the same guest
* [ ] Increase the guest's memory and CPU allocation
* [x] Add a port-forwarding rule from a host port to 80
* [ ] Take a snapshot and restore it to reset the network

> **Explanation:** NAT mode gives the guest outbound access, but inbound access usually needs explicit port forwarding. Alternatively, a host-only or bridged adapter can make the guest directly reachable.

#### Q. You want the host and several lab VMs to talk on a private network with no external access through that adapter. Which VirtualBox mode fits?

* [ ] Bridged
* [ ] NAT
* [x] Host-only
* [ ] Internal

> **Explanation:** Host-only creates a private network between the host and guests with no external access through that interface. Internal networking excludes the host too, bridged places guests on the physical network, and NAT is for outbound access.

#### Q. A VM has a host-only adapter for the lab and a second NAT adapter that was enabled during setup. What is true about its isolation?

* [ ] It is fully isolated, because the host-only adapter takes priority
* [x] It can still reach external networks through the NAT adapter
* [ ] It can be reached directly from any device on the physical LAN
* [ ] It loses all connectivity, because two adapters always conflict

> **Explanation:** Multiple adapters change the isolation model, and each enabled adapter adds its own reachability. The NAT adapter provides outbound access even though the host-only adapter does not. Inspect every adapter when you need isolation.

#### Q. The host disk holding a VM's files fails. The VM had several snapshots. What can you recover from the snapshots?

* [ ] Everything, because snapshots are independent full backups
* [ ] Only the most recent snapshot, which is stored in the cloud
* [x] Nothing, because snapshots depend on the VM's storage chain
* [ ] All data except changes since the last scheduled snapshot

> **Explanation:** A snapshot depends on the VM's own disk files and is not an independent backup. Keep important work and backups outside the disposable guest and its host storage.

#### Q. A reverse proxy and an application run on the same host. You want them to communicate without exposing a TCP listener. Which mechanism fits, and what controls who can connect?

* [x] A Unix-domain socket, restricted by file ownership and permissions
* [ ] A UDP socket on loopback, restricted by the DNS TTL of the host
* [ ] A shared memory area, restricted by the application's log level
* [ ] A message broker, restricted by the order messages are acknowledged

> **Explanation:** A Unix-domain socket uses a local address, often a filesystem path, so file ownership and permissions limit access. It avoids a TCP listener but still needs authorization, and container mount boundaries matter too.

#### Q. A client makes two `write()` calls on a TCP socket, each sending one JSON object. The server's single `read()` returns both objects joined together. What does this show?

* [ ] The server's network card dropped a packet boundary marker
* [x] TCP is a byte stream, so the protocol must define framing
* [ ] The client must switch to UDP to get reliable JSON delivery
* [ ] Node.js merged the writes because the socket was not encrypted

> **Explanation:** TCP delivers an ordered stream of bytes; one write does not guarantee one read. Define message boundaries with length prefixes, delimiters or an established protocol.

#### Q. A queue consumer charges a card and crashes before acknowledging the message. The broker redelivers it and the customer is charged twice. Which change best prevents this?

* [ ] Acknowledge each message immediately when it is received
* [ ] Run more consumer replicas so crashes affect fewer messages
* [x] Make processing idempotent, such as deduplicating by order ID
* [ ] Increase the queue's maximum message size to fit the charge

> **Explanation:** Brokers can deliver a message more than once, so consumers must tolerate retries. Acknowledge only after the result is safely recorded, and deduplicate repeated work. Acknowledging on receipt would lose the order if the consumer crashed.

#### Q. In the SQS lab, a consumer receives a message but crashes before calling `DeleteMessage` with the receipt handle. What happens to the message?

* [ ] It is deleted, because receiving a message acknowledges it
* [x] It becomes visible again after the visibility timeout
* [ ] It moves to the end of the queue with a new message ID
* [ ] It is returned to the sender as a failed delivery report

> **Explanation:** Receiving a message hides it only temporarily. If it is not deleted with its receipt handle before the visibility timeout ends, it becomes receivable again, so consumers must handle repeated processing.

#### Q. Two worker processes update the same shared memory region and occasionally produce corrupted totals. What is missing?

* [ ] A TCP framing protocol between the two workers
* [x] Synchronization such as a lock around each update
* [ ] A larger shared memory region for both processes
* [ ] A Unix socket permission check on each update

> **Explanation:** Shared memory lets processes access a common area, but they must coordinate access to avoid races and inconsistent data. A lock or other synchronization primitive makes each update atomic with respect to the other process.

#### Q. In Wireshark, which text belongs in the display filter bar to show Lab 1 traffic on port 4101?

* [x] `tcp.port == 4101`
* [ ] `tcp port 4101`
* [ ] `port:4101/tcp`
* [ ] `filter tcp 4101`

> **Explanation:** Display filters use field syntax such as `tcp.port == 4101`. `tcp port 4101` is capture-filter (BPF) syntax, which belongs in the capture filter box, not the display filter.
