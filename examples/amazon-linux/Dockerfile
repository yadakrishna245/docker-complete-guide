# Amazon Linux 2023 — AWS-native Operations Container
# Mirrors EC2 environment for local testing

FROM amazonlinux:2023

RUN dnf update -y && dnf install -y \
    curl wget git vim nano htop \
    net-tools iputils bind-utils nmap traceroute \
    openssh-clients tar gzip unzip jq \
    python3 python3-pip \
    && dnf clean all

# AWS CLI v2 (pre-installed like EC2)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# AWS SSM Agent (for testing SSM locally)
RUN dnf install -y amazon-ssm-agent && dnf clean all || true

# Install eksctl
RUN curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /usr/local/bin

WORKDIR /workspace
CMD ["/bin/bash"]
