#!/bin/sh
set -eu
umask 077
test -s /run/keytabs/http.keytab
mkdir -p /run/tls
install -d -o www-data -g www-data -m 755 /var/run/apache2 /var/lock/apache2

if [ ! -s /run/tls/web.crt ] || [ ! -s /run/tls/web.key ]; then
    openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 7 \
        -keyout /run/tls/web.key -out /run/tls/web.crt \
        -subj '/CN=web.lab.test' \
        -addext 'subjectAltName=DNS:web.lab.test,DNS:public.lab.test'
fi
chmod 600 /run/tls/web.key
chmod 644 /run/tls/web.crt
# Workers need to traverse the TLS directory, but cannot read its private key.
chmod 755 /run/tls
apache2ctl -t
# apache2 needs the Debian environment when invoked directly as PID 1.
export APACHE_CONFDIR=/etc/apache2
. /etc/apache2/envvars
exec apache2 -DFOREGROUND
