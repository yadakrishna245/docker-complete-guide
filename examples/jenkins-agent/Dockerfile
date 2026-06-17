# Jenkins CI/CD Agent
# Pre-loaded with build tools for pipelines

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git openssh-client \
    openjdk-17-jdk maven gradle \
    nodejs npm \
    python3 python3-pip \
    docker.io \
    jq unzip zip ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Trivy (security scanner)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# SonarScanner
RUN curl -sL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip -o sonar.zip && \
    unzip sonar.zip -d /opt && rm sonar.zip && ln -s /opt/sonar-scanner-*/bin/sonar-scanner /usr/local/bin/

WORKDIR /workspace
CMD ["/bin/bash"]
