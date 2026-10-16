# Inter-process communication

Inter-process communication (IPC) lets processes exchange data or coordinate work. Choose a mechanism based on where the processes run, how they handle failure, and whether messages must survive a restart.

## Common mechanisms

- Pipes connect a stream of bytes between processes, such as one command's output and another command's input.
- Unix-domain sockets let processes on the same host communicate through a local socket address, often a filesystem path. File ownership and permissions can restrict access.
- TCP sockets connect processes through host addresses and ports, locally or across a network. Applications still need message framing, timeouts, and authentication as appropriate.
- Shared memory lets processes access a common memory area. They must coordinate access correctly to avoid races or inconsistent data.
- Message queues or brokers decouple senders from consumers. Durability, acknowledgment, ordering, and duplicate delivery depend on the chosen system and configuration.

A reverse proxy can forward a request to an application over a Unix socket. A PostgreSQL client on the database host can also use a Unix socket when configured. Remote clients generally need a network connection.

## Failure and access

A local socket avoids exposing a TCP listener, but does not remove the need for authorization. Check socket permissions, service identities, and container mount boundaries.

TCP is a byte stream: a single write is not guaranteed to correspond to one read. Define framing using lengths, delimiters, or an established protocol. Set timeouts and limits so a blocked peer cannot consume resources indefinitely.

For queued work, design consumers to tolerate retries. Acknowledge work only after its intended result is safely recorded, and use idempotency or deduplication where repeated processing would cause harm.

Practice byte-stream framing in the [Wireshark + Node.js labs](../labs/wireshark-nodejs/README.md). Related: [networking](networking.md).
