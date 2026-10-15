# 10 Wireshark + Node.js Network Labs

**Audience:** Beginner/intermediate networking, computer science, software-development or cybersecurity students  
**Time:** 60–90 minutes each  
**Tools:** Wireshark and Docker (recommended isolated mode); Node.js 20+, capture permissions and OpenSSL for legacy host mode  
**Internet requirement:** No internet during labs; the optional Docker image requires a one-time image/package download.  
**Dependencies:** No `npm install` required. For privacy-safe sharing, Docker is recommended.

## IMPORTANT — choosing a safe capture mode

**For teaching videos and captures that will be shared, use the [isolated Docker workflow](ISOLATED_DOCKER.md) instead of capturing the host.** It runs both endpoints and packet capture within a Docker container using `--network none`, saves only test-port loopback packets, and lets you open the resulting file in Wireshark on the host. The older workflow below captures the host loopback and is **not guaranteed private**.

```sh
docker build -t wireshark-node-labs:isolated .   # once
./run-isolated.sh 01                              # Linux/macOS
# or: .\run-isolated.ps1 01                      # Windows PowerShell
```

Then open `captures/lab-01.pcap` in Wireshark. **Don't start capturing the host's interfaces.** For code challenges, rebuild the Docker image before rerunning. See [ISOLATED_DOCKER.md](ISOLATED_DOCKER.md) for the security model and caveats.

## Legacy mode: host loopback, not privacy-guaranteed

Use this only when you understand and accept the risk of capturing unrelated host loopback traffic. Do **not** distribute unchecked captures.

## Start here

1. Install Node.js and Wireshark. On Windows, ensure Npcap with loopback capture support is installed.
2. Open Wireshark and choose the **loopback** interface (`lo`, `lo0`, or Npcap Loopback Adapter). If the names differ, find the interface that captures traffic for `127.0.0.1`.
3. Open a terminal in the folder containing this README.
4. Start a new capture in Wireshark, then run any lab, for example:

   ```sh
   node labs/01-tcp-handshake.js
   ```

   Each lab prints a ready message, then waits **3 seconds** before sending test traffic. Start the capture before or immediately after running the command. Programs normally finish automatically after generating traffic. Re-run as needed.
5. Apply the lab's **display filter** in Wireshark (NOT the capture filter box). A basic filter is `tcp.port == 4101` for Lab 1.
6. Save a capture as `lab-01.pcapng` and answer the questions in [LABS.md](LABS.md).

**If you need a longer head start:** run `LAB_DELAY_MS=8000 node labs/01-tcp-handshake.js` on macOS/Linux. In PowerShell, run `$env:LAB_DELAY_MS='8000'; node labs/01-tcp-handshake.js`.

## Lab list

| # | File | Protocol focus | Wireshark display filter |
|---|---|---|---|
| 1 | `labs/01-tcp-handshake.js` | TCP setup / teardown | `tcp.port == 4101` |
| 2 | `labs/02-http-get.js` | HTTP GET and headers | `tcp.port == 4102` |
| 3 | `labs/03-http-post-json.js` | HTTP POST and request body | `tcp.port == 4103` |
| 4 | `labs/04-http-status.js` | HTTP 200 / 404 / 500 | `tcp.port == 4104` |
| 5 | `labs/05-udp-echo.js` | UDP datagrams | `udp.port == 4105` |
| 6 | `labs/06-tcp-vs-udp.js` | TCP vs UDP | `tcp.port == 4106 or udp.port == 4106` |
| 7 | `labs/07-tcp-framing.js` | Byte streams / framing | `tcp.port == 4107` |
| 8 | `labs/08-local-dns.js` | DNS A query and answer | `udp.port == 4108` |
| 9 | `labs/09-https-tls.js` | HTTPS/TLS | `tcp.port == 4109` |
| 10 | `labs/10-troubleshooting.js` | Refused connections / timeout | `tcp.port == 4110 or tcp.port == 4199` |

**Important:** Port filters work regardless of protocol recognition. Wireshark may not automatically recognize HTTP, DNS, or TLS on the unusual ports used here. Use **Analyze → Decode As…** to tell Wireshark that TCP 4102–4104 is HTTP, UDP 4108 is DNS, or TCP 4109 is TLS if necessary. Do not confuse Wireshark's display filter `tcp.port == 4101` with capture-filter syntax such as `tcp port 4101`.

## Lab 9 special setup (legacy host mode only)

Isolated mode generates a disposable certificate and key inside the container automatically. For host mode only, from the root project folder run:

```sh
node setup-cert.js
node labs/09-https-tls.js
```

`setup-cert.js` uses OpenSSL to create a short-lived, locally trusted **demonstration** certificate and private key inside `certs/`. **Never use this key or certificate in production or share the private key.** The HTTPS client explicitly trusts only this generated certificate; TLS verification is NOT globally disabled. Delete the generated `.pem` files to generate a new short-lived certificate when needed.

## How to inspect the captures

- **Isolated mode (recommended):** open `captures/lab-NN.pcap` in Wireshark after `run-isolated.sh` / `run-isolated.ps1` finishes. Do **not** capture a host network interface.
- **Legacy host mode only:** start a capture on your machine's loopback adapter **before** the Node client begins sending data.
- Filter using the port shown above.
- Select a TCP packet, then choose **Analyze → Follow → TCP Stream** to view the reassembled conversation. The visible HTTP contents are unencrypted; TLS application data remains encrypted.
- Use **Statistics → Conversations** for endpoint / byte comparisons.
- Use **Analyze → Expert Information** as a starting point, not as a definitive diagnosis.
- For TCP flags, try `tcp.flags.syn == 1`, `tcp.flags.fin == 1`, or `tcp.flags.reset == 1`, in combination with the lab's port filter.
- Packet boundaries, ACK counts and teardown patterns vary by OS, Wireshark settings, and Node version. There is **no single exact expected packet count** for these exercises.

## Assessment submissions

For each lab, students submit: (a) one `.pcap` isolated capture (or `.pcapng` if explicitly saved in that format), (b) one annotated screenshot or selected packet details, (c) answers to the three investigation questions, and (d) one small code change with an explanation of its effect. All traffic should be generated on machines they own or are authorized to test. Use synthetic data only.

## Teacher resources

- [LABS.md](LABS.md) — all 10 student worksheets with objectives, steps, filters, questions and optional extensions.
- [TEACHER_NOTES.md](TEACHER_NOTES.md) — expected observations, limitations and suggested grading rubric.
- Run `node scripts/self-test.js` for a smoke test of all example programs (generates the Lab 9 certificate if OpenSSL is available).

### Reference documentation

- Wireshark User's Guide: https://www.wireshark.org/docs/wsug_html/
- Wireshark loopback capture: https://wiki.wireshark.org/CaptureSetup/Loopback
- Wireshark Follow Stream: https://www.wireshark.org/docs/wsug_html_chunked/ChAdvFollowStreamSection.html
- Node.js APIs: https://nodejs.org/api/net.html ; https://nodejs.org/api/http.html ; https://nodejs.org/api/dgram.html ; https://nodejs.org/api/dns.html ; https://nodejs.org/api/https.html