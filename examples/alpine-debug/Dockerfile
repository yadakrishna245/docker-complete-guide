# Alpine Network Debug / Troubleshooting Container
# Minimal image (~15MB) with essential networking tools

FROM alpine:3.19

RUN apk add --no-cache \
    curl wget busybox-extras \
    bind-tools iputils net-tools nmap tcpdump \
    openssl ca-certificates \
    jq bash vim \
    strace lsof htop

WORKDIR /workspace
CMD ["/bin/bash"]
