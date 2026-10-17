# Shared by the HTTP gateway and optional HTTPS gateway.
server_tokens off;
access_log /dev/stdout;
error_log /dev/stderr warn;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "no-referrer" always;

root /usr/share/nginx/html;
index index.html;

# Only gateway liveness: this does not test the Apache dependency.
location = /healthz {
    default_type text/plain;
    return 200 "ok\n";
}

location = /apache {
    return 308 /apache/;
}
location /apache/ {
    # Trailing slash drops the /apache/ prefix when forwarding to Apache.
    proxy_pass http://apache:80/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 2s;
    proxy_read_timeout 5s;
}
location / {
    try_files $uri $uri/ =404;
}
