#!/bin/sh
set -eu
umask 077
mkdir -p /var/lib/krb5kdc /keytabs

if [ ! -f /var/lib/krb5kdc/principal ]; then
    master_key=$(openssl rand -hex 32)
    kdb5_util create -r LAB.TEST -s -P "$master_key"
    unset master_key
fi

has_principal() {
    kadmin.local -q "getprinc $1" 2>/dev/null | grep -q '^Principal:'
}

# Public, disposable teaching passwords. Never substitute real credentials.
if ! has_principal alice@LAB.TEST; then
    kadmin.local -q 'addprinc +requires_preauth -allow_svr -pw Alice-lab-only! alice@LAB.TEST'
fi
if ! has_principal bob@LAB.TEST; then
    kadmin.local -q 'addprinc +requires_preauth -allow_svr -pw Bob-lab-only! bob@LAB.TEST'
fi
if ! has_principal HTTP/web.lab.test@LAB.TEST; then
    kadmin.local -q 'addprinc -randkey HTTP/web.lab.test@LAB.TEST'
fi
if [ ! -s /keytabs/http.keytab ]; then
    kadmin.local -q 'ktadd -norandkey -k /keytabs/http.keytab HTTP/web.lab.test@LAB.TEST'
fi
if ! has_principal health/kdc.lab.test@LAB.TEST; then
    kadmin.local -q 'addprinc -randkey health/kdc.lab.test@LAB.TEST'
fi
if [ ! -s /var/lib/krb5kdc/health.keytab ]; then
    kadmin.local -q 'ktadd -norandkey -k /var/lib/krb5kdc/health.keytab health/kdc.lab.test@LAB.TEST'
fi
# Debian's www-data group is 33 in the web image; the client gets no keytab mount.
chown root:33 /keytabs /keytabs/http.keytab
chmod 750 /keytabs
chmod 640 /keytabs/http.keytab
exec krb5kdc -n -r LAB.TEST
