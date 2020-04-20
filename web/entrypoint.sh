#!/usr/bin/env sh
set -e

gen_self_signed() {
  echo "[WRN] No certificates found, generating self signed cert with key"
  openssl req -x509 -nodes -days 1780 -newkey rsa:4096 \
    -keyout /etc/ssl/certs/tea.key \
    -out /etc/ssl/certs/tea_bundle.crt \
    -subj "/C=DE/ST=Berlin/L=Germany/O=TeaSpeak/OU=TeaWeb/CN=localhost/emailAddress=noreply@teaspeak.de"

  if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
    echo "[INF] No Diffie-Hellman pem found, generating new with 2048 byte"
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
  fi
}

if [ "$1" = "nginx" ]; then
  if [ ! -f /etc/ssl/certs/tea.key ] && [ ! -f /etc/ssl/certs/tea_bundle.crt ]; then
    gen_self_signed
  elif [ ! -f /etc/ssl/certs/tea.key ] || [ ! -f /etc/ssl/certs/tea_bundle.crt ]; then
    echo "[ERR] Only found a key or crt-bundle file but both files are REQUIRED!"
    exit 1
  fi
fi

exec "$@"