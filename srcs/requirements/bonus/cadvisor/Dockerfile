FROM debian:bookworm

ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       wget \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
      amd64|arm64) ;; \
      *) echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac; \
    wget -q \
      "https://github.com/google/cadvisor/releases/download/v0.54.0/cadvisor-v0.54.0-linux-${arch}" \
      -O /usr/local/bin/cadvisor; \
    chmod 755 /usr/local/bin/cadvisor

EXPOSE 8080

CMD ["/usr/local/bin/cadvisor", "-logtostderr", "--url_base_prefix=/cadvisor"]
