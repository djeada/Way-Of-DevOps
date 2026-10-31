# Version families keep the lesson readable; review/pin digests for deployments.
FROM debian:bookworm-slim AS base
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl krb5-user openssl \
    && rm -rf /var/lib/apt/lists/*
COPY kerberos/krb5.conf /etc/krb5.conf

FROM base AS kdc
RUN apt-get update \
    && apt-get install -y --no-install-recommends krb5-kdc krb5-admin-server \
    && rm -rf /var/lib/apt/lists/*
COPY kerberos/kdc.conf /etc/krb5kdc/kdc.conf
COPY scripts/start-kdc.sh /usr/local/bin/start-kdc
CMD ["sh", "/usr/local/bin/start-kdc"]

FROM base AS web
RUN apt-get update \
    && apt-get install -y --no-install-recommends apache2 libapache2-mod-auth-gssapi \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod ssl headers auth_gssapi authz_user \
    && a2dissite 000-default default-ssl \
    && printf '%s\n' 'Listen 443' > /etc/apache2/ports.conf \
    && printf '%s\n' 'Include /etc/apache2/lab/site.conf' \
       > /etc/apache2/sites-enabled/lab.conf
COPY scripts/start-web.sh /usr/local/bin/start-web
CMD ["sh", "/usr/local/bin/start-web"]

FROM base AS client
RUN useradd --create-home --uid 1000 student
USER student
ENV KRB5CCNAME=FILE:/tmp/krb5cc_1000 \
    CURL_CA_BUNDLE=/run/tls/web.crt
CMD ["sleep", "infinity"]
