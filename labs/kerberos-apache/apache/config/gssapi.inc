AuthType GSSAPI
AuthName "Kerberos lab"
GssapiCredStore keytab:/run/keytabs/http.keytab
GssapiAllowedMech krb5
GssapiSSLonly On
GssapiLocalName Off
GssapiBasicAuth Off
GssapiUseSessions Off
