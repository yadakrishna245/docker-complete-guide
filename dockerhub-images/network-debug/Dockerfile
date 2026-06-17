FROM alpine:3.20

LABEL maintainer="Krishna Yada <yadakrishna245>" \
      description="Lightweight network debugging and troubleshooting container" \
      version="1.0.0"

RUN apk add --no-cache \
    curl wget \
    bind-tools \
    iputils \
    net-tools \
    nmap nmap-ncat \
    tcpdump \
    mtr \
    iperf3 \
    openssl \
    ca-certificates \
    busybox-extras \
    strace lsof \
    jq bash vim htop

WORKDIR /workspace
CMD ["/bin/bash"]
