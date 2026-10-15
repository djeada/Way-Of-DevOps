# Instructor Guide — Wireshark + Node.js Labs

## Teaching approach

**Recommended session plan (75 minutes):** 10 minutes protocol recap, 10 minutes code walkthrough, 35 minutes capture / investigation, 10 minutes code extension, 10 minutes discussion and exit ticket. Lab 8 and 9 may need extra time for DNS decoding and TLS certificate setup.

## Privacy-first distribution and screen recording

**Default to the isolated Docker run commands** in [ISOLATED_DOCKER.md](ISOLATED_DOCKER.md), not the legacy host-live-capture instructions. This runs the code and tcpdump inside a container configured with `--network none`, capturing only the container's own loopback. Open the saved `captures/lab-NN.pcap` in Wireshark on the host; never record host Ethernet, Wi-Fi, or ordinary loopback for evidence. Run a sanity check in **Statistics → Endpoints**: packet endpoint IPs should only be `127.0.0.1`.

The lab 8 test DNS A-record (`10.20.30.40`) is synthetic payload data, not a captured endpoint. The generated TLS key for lab 9 is created inside the disposable container and should not be shared. Educators must still inspect pcap files and screen recordings for unintended host UI, filenames, notifications, and personal information. **No container or VM is an absolute privacy guarantee.** The Docker workflow is supplied but has not been runtime-tested in this distribution environment.

## Core setup caveats

- **Legacy mode only:** capture host loopback traffic. Windows typically requires Npcap; on Linux use `lo`, on macOS usually `lo0`. This mode is **not recommended for shareable recordings**.
- Start the Wireshark capture **before** the program transmits. The examples wait 3 seconds. `LAB_DELAY_MS` can extend this pause.
- Port 4101–4110 identifies each lab's service; TCP port 4199 is the intentionally unused destination in Lab 10. Avoid running multiple copies concurrently.
- These demos use TCP/UDP over 127.0.0.1. They do not require internet access or third-party npm packages.
- Because HTTP, TLS and DNS use custom ports, Wireshark may need **Analyze → Decode As…** before it displays protocol-specific fields.
- Follow TCP Stream gives application-level reassembly but its colors and exact layout depend on version and theme.
- Do not insist on fixed TCP packet counts or equal numbers of `write` calls and TCP segments. Modern network stacks, offloading and buffering affect packetization and ACK timing.
- TLS 1.3 encrypts more handshake material than TLS 1.2. A certificate may not appear in plaintext on the wire. The expected outcome is that HTTP application content is not readable without keys.
- Lab 8 uses a small, intentionally restricted *demonstration* DNS implementation: it responds only to ordinary A/IN questions and is not appropriate for production.
- Lab 9 generates a private key on the student's computer. Never request students to submit this key. The example HTTPS client trusts only the local demo certificate and does **not** disable all TLS certificate verification.
- Troubleshooting Lab 10 includes port 4199, which is **usually** closed. If another service is listening, choose a different unused port in the code.

## Expected observations and discussion points

| Lab | Primary expected observation | Common misconception to address |
|---|---|---|
| 1 | SYN → SYN/ACK → ACK before application data; FIN or RST near closure | Every application write is one TCP packet |
| 2 | Readable HTTP GET, Host and User-Agent, status 200 | HTTP itself encrypts content |
| 3 | Readable POST JSON, `Content-Length` and status 201 | `Content-Length` counts packets rather than bytes |
| 4 | Responses 200, 404 and 500 over working TCP connections | HTTP 500 equals TCP transport failure |
| 5 | UDP echo datagrams with no connection setup | UDP is inherently reliable because the echo succeeded |
| 6 | Same numerical port works for UDP and TCP; TCP has setup/control | The same port number means the same protocol |
| 7 | Newline-framed records reconstructed across arbitrary chunks | A `data` event is always one app-level message |
| 8 | DNS question for `course.test`; A answer `10.20.30.40`, TTL 30 seconds | `dns.lookup` and `dns.resolve4` always behave identically |
| 9 | TLS handshake and encrypted application data; plaintext invisible | TLS hides all connection metadata or makes traffic unobservable |
| 10 | Normally RST/refusal at port 4199; timeout for `/slow`; success for `/fast` | A client timeout alone proves the remote service is down |

## Question answer prompts

**Lab 1:** Client source is an OS-assigned ephemeral TCP port; a three-way handshake is SYN, SYN+ACK, ACK. TCP is stream-oriented; writes may combine or split.

**Lab 2:** GET and `/hello?student=Alice`; client headers include Host and User-Agent; server headers include Content-Type and X-Lab. Plain HTTP payload is not encrypted.

**Lab 3:** Content-Length specifies payload **bytes**, not characters or packets; blank line separates headers from body. Real secrets over plain HTTP could be exposed to packet observers.

**Lab 4:** 200 success; 404 requested resource not found; 500 server-side error; all are HTTP responses carried by an established TCP connection.

**Lab 5:** Reply destination comes from source address/port on the incoming UDP datagram. UDP has no connection handshake; packet delivery and order are not guaranteed by the protocol.

**Lab 6:** TCP handles setup/ACKs and orderly close, adding control traffic. Port spaces for TCP and UDP are separate. TCP offers ordered/reliable byte-stream delivery; UDP does not guarantee delivery/ordering.

**Lab 7:** TCP transports a sequence of bytes, so the receiver needs delimiters, fixed-size records or length prefixes. The `data` callback is not a framing boundary.

**Lab 8:** Transaction ID pairs query and response; A record resolves a hostname to IPv4 address; TTL specifies how long a response can be cached (subject to client/resolver policies).

**Lab 9:** The TLS handshake negotiates cryptographic parameters and authenticates the server (subject to certificate validation). Addresses, ports, packet sizes and timing stay visible; details of TLS metadata depend on version. Trusting a self-signed cert is controlled and limited to this local sample.

**Lab 10:** Connection refusal is an immediate transport error when a destination rejects a connection; client timeout is an application/API deadline; HTTP 200 is a valid server response. A timeout is local policy and not itself a wire-level TCP option.

## Suggested rubric (per lab)

| Category | Weight |
|---|---:|
| Correct capture, relevant packets and saved evidence | 30% |
| Accurate packet / protocol interpretation | 35% |
| Working code modification and explanation | 20% |
| Investigation answers and reflection | 15% |
| **Total** | **100%** |

**Differentiation:** Beginners can use provided code unchanged and answer core questions. Intermediate students complete the code modifications. Advanced students annotate a sequence diagram, compare multiple operating systems, and identify limits of drawing conclusions from the visible capture.

**Safety and privacy:** Restrict to locally generated synthetic traffic or authorized teaching networks. Don't capture uninvolved users' traffic. Avoid sample passwords, tokens or real personal data in unencrypted HTTP labs.

**Sources:** Official Wireshark User's Guide, Wireshark loopback capture documentation, and the Node.js API reference; direct links are in `README.md`.