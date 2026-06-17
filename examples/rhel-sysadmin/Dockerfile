# RHEL / CentOS Stream SysAdmin Toolbox
# Enterprise Linux with common admin tools

FROM rockylinux:9

RUN dnf update -y && dnf install -y \
    curl wget git vim nano htop \
    net-tools iputils bind-utils nmap tcpdump traceroute \
    openssh-clients telnet \
    jq unzip tar gzip zip \
    python3 python3-pip \
    yum-utils dnf-plugins-core \
    ca-certificates \
    && dnf clean all

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Install Docker CLI
RUN dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    dnf install -y docker-ce-cli && dnf clean all

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip -o tf.zip && \
    unzip tf.zip -d /usr/local/bin/ && rm tf.zip

# Install Ansible
RUN pip3 install --no-cache-dir ansible

WORKDIR /workspace
CMD ["/bin/bash"]
