# Privacy-safe classroom captures — isolated Docker runtime

**Use this mode for any packet capture that will be submitted, screen-recorded, or shared.** The original localhost/host-Wireshark instructions are convenient for demonstration but **not** a guarantee that a host capture contains only classroom data.

## Isolation design

- The application, client, server, and `tcpdump` run in **one disposable Linux container**.
- Docker's `--network none` leaves that container with **only its own loopback (`lo`)**. It has **no container-facing bridge, host, Wi-Fi, Ethernet, or internet connection**, and no published ports.
- `tcpdump -i lo` captures inside that container's network namespace, **never the host's network interface**. Its BPF capture filter restricts the saved file to that lab's test port(s).
- A single host folder, `captures/`, is mounted for **output only**. No home folder, personal documents, Docker socket, or host networking are mounted.
- The container uses a read-only root filesystem, temporary writable `/tmp`, drops all capabilities except `NET_RAW` needed to capture, and has `no-new-privileges` set.
- Lab 9's **disposable** TLS private key is created under the container's temporary `/tmp` directory, **not** copied to the capture folder.
- The source code uses only `127.0.0.1`, a synthetic DNS test name, and example payloads.

**Scope:** These measures isolate network packet contents; they cannot guarantee anonymity in a whole-screen recording. The host desktop may still show usernames, file paths, notifications, other windows, or identifying metadata. Review the capture AND the video before sharing. A privileged Docker daemon or malicious Docker image should not be treated as an absolute security boundary.

## One-time preparation

Docker Engine (Linux) or Docker Desktop set to **Linux containers** (Windows/macOS) must be installed. One-time build generally requires internet access to download the Node image and OS packages; the running labs themselves require none.

In the root of this lab pack:

```sh
docker build -t wireshark-node-labs:isolated .
```

## Run one lab (Linux/macOS)

```sh
./run-isolated.sh 01
```

Or on Windows PowerShell, from the project root:

```powershell
.\run-isolated.ps1 01
```

Change `01` to any lab number through `10`. The command saves `captures/lab-01.pcap` (or the corresponding lab number). Repeat a lab to replace its `.pcap` file.

**Open the saved `.pcap` in Wireshark after the command exits.** Do **not** begin an unrelated live capture on the host machine. Use the per-lab Wireshark *display* filter from `README.md` or `LABS.md`. Wireshark is only a viewer here; packet collection is performed inside the isolated container.

### All labs (Linux/macOS)

```sh
for i in 01 02 03 04 05 06 07 08 09 10; do ./run-isolated.sh "$i"; done
```

### Code challenge workflow

The Docker image contains a snapshot of the lab code. If you modify a file, **rebuild** the image, then run the lab again:

```sh
docker build -t wireshark-node-labs:isolated .
./run-isolated.sh 03
```

## Verify isolation and protect shared captures

1. Use only the provided launchers so the container receives `--network none`, loopback-capture privileges, and a limited output mount. Do not substitute Docker host networking or broad host-directory mounts.
2. Open `captures/lab-01.pcap` in Wireshark. Check **Statistics → Endpoints**. IPv4 source and destination should be `127.0.0.1` only.
3. Confirm the per-lab filter is applied. Lab 8's DNS answer contains the **synthetic data value** `10.20.30.40`; that is an A-record value inside the DNS message, **not a real external endpoint** captured on the wire.
4. If you see a public endpoint or your actual LAN address in a capture, **do not distribute it**. Verify you opened the correct `captures/lab-XX.pcap`, and regenerate using the isolated launcher.
5. Share only the intended `.pcap` files or tightly cropped Wireshark screenshots. Do not share generated TLS private keys, host diagnostic logs, or full desktop recordings without reviewing them.
6. Use only invented names and synthetic application payloads. Code challenges should not incorporate personal or school data.

### Lab 9 / HTTPS

The TLS demo uses an ephemeral locally generated self-signed certificate for `localhost`, and the Node.js client trusts that certificate for this one example only. The key stays inside the temporary container and disappears when it exits. Actual web traffic or external certificate servers are never contacted.

## Alternative: dedicated VM

A VM is also suitable **if its network adapters are disabled/disconnected** or connected strictly to a dedicated *internal* network, with no NAT, bridged adapter, host-only adapter, or shared host directories except a carefully controlled export path. Run the Node examples and capture the VM's `lo` interface **inside** that VM. Do not assume a NAT-configured VM is offline: NAT often allows outbound network access.

## Limits of verification

The 10 Node.js programs have existing functional tests. Container build and `tcpdump` capture must be verified on a Docker-capable classroom machine, because this packaging environment does not provide a Docker runtime. The isolation design relies on standard Docker `--network none` and Linux packet capture behavior.