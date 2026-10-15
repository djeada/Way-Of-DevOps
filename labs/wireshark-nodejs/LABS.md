# Student Lab Worksheets — Wireshark + Node.js

## Common instructions

Every lab takes about **60–90 minutes**. Capture only the sample traffic created by these lab programs, not another person's network communications.

**Recommended workflow for sharable evidence:** (1) Build the image once with `docker build -t wireshark-node-labs:isolated .`. (2) For Lab N, run `./run-isolated.sh NN` (Linux/macOS) or `.\run-isolated.ps1 NN` (Windows), using `01`–`10`. (3) Open `captures/lab-NN.pcap` in Wireshark; **do not start a live capture of the host**. (4) Apply the lab's Wireshark display filter. (5) Inspect packets, use **Analyze → Follow → TCP Stream** if appropriate, and complete the questions. (6) For code modifications, rebuild the image and generate a fresh capture. See [ISOLATED_DOCKER.md](ISOLATED_DOCKER.md).

**Alternative host-only demo (not privacy-guaranteed):** the `node labs/...` commands below are also usable with a live capture on the host's loopback interface, but host loopback capture may include unrelated personal traffic. Do **not** share it unreviewed.

These programs use **nonstandard high ports**. If Wireshark does not decode traffic automatically, use **Analyze → Decode As…** for HTTP, DNS or TLS as appropriate. The isolated workflow produces saved capture files which you open **after** generation; there is no need for live packet capture on the host.

---

## Lab 1 — TCP Three-Way Handshake

**Aim:** Explain how a TCP connection starts, transports data and closes.  
**Duration:** 60 min  
**Isolated run:** `./run-isolated.sh 01` (Windows: `.\run-isolated.ps1 01`)  
**Host-only alternative command:** `node labs/01-tcp-handshake.js`  
**Filter:** `tcp.port == 4101`

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Find the initial packets with `tcp.port == 4101 and tcp.flags.syn == 1`.
3. Identify the client's SYN, the server's SYN-ACK and the client's subsequent ACK.
4. Follow the TCP stream to find `HELLO FROM CLIENT` and `ACK FROM SERVER`.
5. Find any FIN and/or reset packets during teardown; document the flags actually seen.
6. **Code challenge:** Change the client message to `HELLO CLASS` and regenerate the isolated capture after rebuilding the image.

**Questions**
1. Which host/port pair initiated the connection? What was its ephemeral source port?
2. Which TCP flags establish the connection, in what order?
3. Does one application's `write()` guarantee one captured packet? Explain.

**Submit:** pcapng, annotated handshake screenshot, source-port value, answers and modified message.

---

## Lab 2 — HTTP GET and Headers

**Aim:** Explain requests, responses, URLs, headers and HTTP-over-TCP.  
**Duration:** 60 min  
**Isolated run:** `./run-isolated.sh 02` (Windows: `.\run-isolated.ps1 02`)  
**Host-only alternative command:** `node labs/02-http-get.js`  
**Filter:** `tcp.port == 4102` (or `http` after decoding as HTTP)

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Find the `GET /hello?student=Alice HTTP/1.1` request in **Follow TCP Stream**.
3. Locate the `Host` and `User-Agent` headers and identify the 200 response.
4. Observe the response's `Content-Type` and custom `X-Lab` header.
5. **Code challenge:** Change the query parameter value and add a new `X-Student` request header.

**Questions**
1. What are the request method and requested resource?
2. Which headers originate with the client, and which originate with the server?
3. Why can you read the HTTP response text in a TCP stream capture?

**Submit:** pcapng, annotated request/response and answers.

---

## Lab 3 — HTTP POST with JSON

**Aim:** Differentiate HTTP request headers from a request body and inspect JSON transfer.  
**Duration:** 75 min  
**Isolated run:** `./run-isolated.sh 03` (Windows: `.\run-isolated.ps1 03`)  
**Host-only alternative command:** `node labs/03-http-post-json.js`  
**Filter:** `tcp.port == 4103`

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Follow the TCP stream; identify the `POST /orders` request line.
3. Find `Content-Type: application/json` and the JSON request body.
4. Identify the `Content-Length` value and the 201 response.
5. **Code challenge:** Change `quantity` to 5 and add a `customerId` field with a fictional value. Rebuild the image and repeat the isolated capture.

**Questions**
1. What does `Content-Length` measure: JSON characters, UTF-8 bytes or packet count?
2. How is the request body distinguished from the HTTP headers?
3. What privacy issue would arise if real authentication tokens were sent by HTTP instead of HTTPS?

**Submit:** pcapng, highlighted JSON body, your changed body and answers.

---

## Lab 4 — HTTP Status Codes

**Aim:** Relate application responses to HTTP status codes.  
**Duration:** 60 min  
**Isolated run:** `./run-isolated.sh 04` (Windows: `.\run-isolated.ps1 04`)  
**Host-only alternative command:** `node labs/04-http-status.js`  
**Filter:** `tcp.port == 4104`

**Steps**
1. Generate and open the isolated capture; the program sends three separate requests.
2. Locate `/ok`, `/missing` and `/error` and their response codes.
3. Explain the difference between a successful HTTP request and an application error response.
4. Compare the TCP connections used for each request.
5. **Code challenge:** Modify `/error` to respond 503 instead of 500.

**Questions**
1. What does each of 200, 404 and 500 indicate?
2. Does an HTTP 500 response necessarily imply a TCP connection failure?
3. What is the difference between a transport error and an HTTP application error?

**Submit:** pcapng, a 3-row request/status table and answers.

---

## Lab 5 — UDP Echo

**Aim:** Understand datagram communication and distinguish UDP from TCP.  
**Duration:** 60 min  
**Isolated run:** `./run-isolated.sh 05` (Windows: `.\run-isolated.ps1 05`)  
**Host-only alternative command:** `node labs/05-udp-echo.js`  
**Filter:** `udp.port == 4105`

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Find three outbound messages (`one`, `two`, `three`) and three server replies.
3. Identify the source and destination ports in each datagram.
4. Verify there is no SYN/SYN-ACK/ACK exchange for UDP.
5. **Code challenge:** Change one message to `four` and resend.

**Questions**
1. How does the UDP server determine where to send its reply?
2. Why does UDP have no TCP three-way handshake?
3. Does receiving the three replies in this test prove UDP always delivers messages reliably?

**Submit:** pcapng, annotated UDP datagram and answers.

---

## Lab 6 — TCP versus UDP

**Aim:** Compare connection-oriented and connectionless traffic for similar application data.  
**Duration:** 75 min  
**Isolated run:** `./run-isolated.sh 06` (Windows: `.\run-isolated.ps1 06`)  
**Host-only alternative command:** `node labs/06-tcp-vs-udp.js`  
**Filter:** `tcp.port == 4106 or udp.port == 4106`

**Steps**
1. Generate and open the isolated capture. The server receives comparable `COMPARE-...` payloads over both transports.
2. Filter TCP and UDP separately and compare the conversation sequences.
3. Identify which protocol uses a connection-establishment handshake.
4. Record observed packet counts, acknowledging that counts vary by platform.
5. **Code challenge:** Increase `A`.repeat(100) to `A`.repeat(500) and compare packet lengths.

**Questions**
1. Why does TCP typically generate more control traffic in this local example?
2. Can TCP and UDP use the same numerical port on one host simultaneously?
3. How do reliability and ordering guarantees differ between the protocols?

**Submit:** pcapng and side-by-side protocol comparison with answers.

---

## Lab 7 — TCP Stream Framing

**Aim:** Explain why application messages cannot rely on TCP packet boundaries.  
**Duration:** 75 min  
**Isolated run:** `./run-isolated.sh 07` (Windows: `.\run-isolated.ps1 07`)  
**Host-only alternative command:** `node labs/07-tcp-framing.js`  
**Filter:** `tcp.port == 4107`

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Look at the server console. It uses a buffer and newline delimiters to reconstruct complete messages.
3. Follow the TCP stream and identify `red`, `blue` and `partial`.
4. Note that a `data` event and a network packet do not necessarily match an application message.
5. **Code challenge:** Add a fourth logical message split between two writes; make sure the server reconstructs it correctly.

**Questions**
1. Why does the receiver need message framing?
2. Why is it unsafe to treat each `data` event as a whole record?
3. Name two alternative framing strategies besides newline delimiters.

**Submit:** pcapng, console output and a diagram mapping application records to the stream.

---

## Lab 8 — Local DNS Query and Answer

**Aim:** Investigate DNS packet structure and the purpose of resource records.  
**Duration:** 75–90 min  
**Isolated run:** `./run-isolated.sh 08` (Windows: `.\run-isolated.ps1 08`)  
**Host-only alternative command:** `node labs/08-local-dns.js`  
**Filter:** `udp.port == 4108`

**Steps**
1. Generate the isolated DNS capture and open it in Wireshark; no public DNS query is made.
2. In Wireshark, choose **Analyze → Decode As…**, associate **UDP port 4108** with **DNS** if it is not recognized automatically.
3. Inspect the query for `course.test`, record type A and class IN.
4. Inspect the answer `10.20.30.40` and the 30-second TTL.
5. **Code challenge:** Change the answer address from `10.20.30.40` to `10.20.30.41`; rebuild the image, then confirm it in a fresh isolated capture.

**Questions**
1. What is the DNS transaction ID used for?
2. What does an A record contain?
3. What does the Time to Live (TTL) value mean for DNS caching?

**Submit:** pcapng, annotated DNS question/answer and answers.

---

## Lab 9 — HTTPS and TLS

**Aim:** Identify a TLS handshake and distinguish ciphertext from visible HTTP payloads.  
**Duration:** 90 min  
**Setup:** `node setup-cert.js` (requires OpenSSL)  
**Isolated run:** `./run-isolated.sh 09` (Windows: `.\run-isolated.ps1 09`)  
**Host-only alternative command:** `node labs/09-https-tls.js`  
**Filter:** `tcp.port == 4109` (or `tls` after Decode As…)

**Steps**
1. Create a short-lived self-signed certificate with the setup command.
2. Open the saved HTTPS capture in Wireshark.
3. Use **Analyze → Decode As…** to identify TCP port 4109 as TLS if necessary.
4. Find the ClientHello / ServerHello exchange and subsequent encrypted application data. Some TLS handshake fields are themselves encrypted in TLS 1.3.
5. Compare this capture with the readable HTTP body from Lab 2 or 3.
6. **Code challenge:** Change the encrypted response text and verify that the text is readable in the Node client console but is not visible as plaintext on the wire without decryption keys.

**Questions**
1. What is the main purpose of the TLS handshake?
2. Which information is still visible on the wire even though HTTP content is encrypted?
3. Why is trusting a local self-signed certificate appropriate only within this controlled exercise?

**Submit:** pcapng, handshake annotations and HTTP-vs-HTTPS comparison.

---

## Lab 10 — Network Troubleshooting

**Aim:** Distinguish refused TCP connections, client-side timeouts and successful HTTP exchanges.  
**Duration:** 90 min  
**Isolated run:** `./run-isolated.sh 10` (Windows: `.\run-isolated.ps1 10`)  
**Host-only alternative command:** `node labs/10-troubleshooting.js`  
**Filter:** `tcp.port == 4110 or tcp.port == 4199`

**Steps**
1. Generate and open the isolated capture using the **Isolated run** command above.
2. Inspect the attempt to connect to TCP port 4199 (normally closed); look for a connection refusal and any associated RST.
3. Inspect `/slow`: the server delays the response longer than the client's 150 ms timeout; observe when the client closes the connection.
4. Inspect `/fast`: the request normally succeeds with HTTP 200.
5. Use Wireshark **Analyze → Expert Information** as supporting evidence, but base conclusions on actual packets and console messages.
6. **Code challenge:** Raise the `/slow` timeout to 1000 ms, repeat the test and explain the change.

**Questions**
1. What difference do you observe between a refused TCP connection and an HTTP timeout?
2. Is a client's local timeout value directly transmitted in the TCP packets?
3. What evidence would you gather before concluding that a real server is down?

**Submit:** pcapng, comparison table for refused / timed out / successful, and a short troubleshooting report.

---

## Final mini-project (optional)

Create a local Node.js API with `GET /health` and `POST /messages`; capture both requests, explain the TCP lifecycle and HTTP fields, then add HTTPS using Lab 9 as a model. Submit two isolated pcap captures, a short network diagram and a 3-minute presentation. Use fabricated sample data only.