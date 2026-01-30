#!/bin/sh
set -e

CONF_FILE=/opt/PyKMIP/server.conf

echo "Starting KMIP server..."
echo "Using certificates:"
openssl x509 -in /opt/certs/root_certificate.pem -noout -dates

exec /usr/local/bin/pykmip-server -f "${CONF_FILE}"
