# ==============================================
# Dockerfile for KMIP server (multi-arch)
# ==============================================

FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV CERT_DIR=/opt/certs
ENV PYKMIP_HOME=/opt/PyKMIP

# --------------------------
# System dependencies
# --------------------------
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-dev \
        openssl \
        ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------------
# Python dependencies
# --------------------------
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir cryptography

# --------------------------
# Copy PyKMIP source
# --------------------------
COPY . ${PYKMIP_HOME}

# --------------------------
# Install PyKMIP
# --------------------------
RUN cd ${PYKMIP_HOME} && python3 setup.py install

# --------------------------
# KMIP directories
# --------------------------
RUN mkdir -p \
    ${CERT_DIR} \
    /opt/policies

RUN cp ${PYKMIP_HOME}/examples/policy.json /opt/policies/

# --------------------------
# Generate fresh certs AT BUILD TIME
# --------------------------
RUN python3 ${PYKMIP_HOME}/bin/create_certificates.py \
      --cert-dir ${CERT_DIR} \
      --key-size 4096 \
      --days 3650 && \
    echo "=== Certificate validity ===" && \
    openssl x509 -in ${CERT_DIR}/root_certificate.pem -noout -dates

# --------------------------
# Server configuration
# --------------------------
COPY server.conf ${PYKMIP_HOME}/server.conf

# --------------------------
# Entrypoint
# --------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5696

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
