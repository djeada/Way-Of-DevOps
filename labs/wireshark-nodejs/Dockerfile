# Build once with internet access (or from preloaded images). All labs run offline.
FROM node:22-bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends tcpdump openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY labs/ /app/labs/
COPY setup-cert.js /app/setup-cert.js
COPY docker/run-capture.sh /usr/local/bin/run-capture
RUN chmod 0755 /usr/local/bin/run-capture
ENTRYPOINT ["/usr/local/bin/run-capture"]
