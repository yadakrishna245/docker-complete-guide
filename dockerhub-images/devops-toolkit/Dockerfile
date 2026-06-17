FROM ubuntu:24.04

LABEL maintainer="Krishna Yada <yadakrishna245>" \
      description="All-in-one DevOps toolkit with AWS, Docker, K8s, Terraform, Ansible" \
      version="1.0.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git vim nano htop \
    net-tools iputils-ping dnsutils nmap tcpdump traceroute \
    openssh-client jq unzip tar gzip zip \
    python3 python3-pip python3-venv \
    ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2
RUN curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscli.zip && \
    unzip -q awscli.zip && ./aws/install && rm -rf aws awscli.zip

# Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli && rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -sLO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Helm
RUN curl -sL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Terraform
RUN curl -sL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip -o tf.zip && \
    unzip -q tf.zip -d /usr/local/bin/ && rm tf.zip

# Ansible
RUN python3 -m venv /opt/ansible && /opt/ansible/bin/pip install ansible && \
    ln -s /opt/ansible/bin/ansible /usr/local/bin/ansible && \
    ln -s /opt/ansible/bin/ansible-playbook /usr/local/bin/ansible-playbook

# Trivy (security scanner)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

WORKDIR /workspace
CMD ["/bin/bash"]
