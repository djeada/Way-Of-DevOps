# Networking and HTTP

Troubleshoot a request in layers: name resolution, routing, connection establishment, TLS, then the application protocol. A failure at one layer can prevent the later layers from running at all.

## Essential concepts

An IP address identifies an interface or endpoint in a network. A subnet and its routes determine where packets can go. Firewalls filter traffic; NAT translates addresses. DNS maps names to records and caches answers according to their time-to-live and resolver behavior.

TCP provides an ordered byte stream with retransmission. UDP provides datagrams without built-in delivery or ordering guarantees. Applications choose or build the behavior they need on top. HTTP/1.1 and HTTP/2 commonly use TCP; HTTP/3 uses QUIC over UDP.

TLS authenticates the server through certificate validation and protects data in transit. Check the certificate chain, expiry, and expected hostname. Encryption does not decide whether an authenticated application user may access a particular record.

## Follow a web request

A client resolves a hostname, connects to the selected endpoint, negotiates TLS for HTTPS, and sends an HTTP request. A proxy or load balancer may forward it to an application. The application may depend on a database, cache, or another service before returning a response.

Know request methods, headers, status codes, bodies, authentication, timeouts, and connection reuse. A 4xx response usually describes a client-side request or access problem; a 5xx response indicates a server-side failure somewhere along the serving path. Inspect which component generated it.

A reverse proxy forwards inbound requests to application servers. A CDN caches eligible content near users. Cache keys, expiry, and invalidation affect correctness as well as performance. Avoid caching personalized responses under a shared key.

## Diagnose from evidence

On Linux with the relevant tools installed, begin with:

```bash
getent hosts localhost
ip addr
ip route
ss -lnt
```

To inspect a local HTTP server already listening on port 8080:

```bash
curl --verbose --max-time 5 http://127.0.0.1:8080/
```

Connection refused often means no listener or an explicit rejection. A timeout can result from filtering, routing, an unavailable peer, or a stalled application. A successful ping does not prove that a TCP port or HTTP endpoint works. `localhost` refers to the current host or network namespace, which matters inside a container.

Check whether the service listens only on loopback or on a reachable interface, then inspect routes and filtering. Compare from the client and server sides rather than changing several settings at once. Verbose client logs can include sensitive headers; use synthetic requests when sharing evidence.

## Retries and boundaries

Set connection and request timeouts. Retry only where repeated work is safe, with a limit and backoff. Retrying a payment or another state-changing request may require an idempotency key and server-side deduplication.

Use the [Wireshark + Node.js labs](../labs/wireshark-nodejs/README.md) to inspect TCP, UDP, HTTP, DNS, TLS, and framing. Follow the isolated capture instructions when producing shared recordings. For local communication choices, see [IPC](ipc.md).

Reference: [HTTP semantics, RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html).
