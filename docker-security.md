# 🔒 Docker Security Best Practices

> Complete guide to securing Docker containers, images, and infrastructure.

---

## 📑 Table of Contents

- [Image Security](#image-security)
- [Container Runtime Security](#container-runtime-security)
- [Network Security](#network-security)
- [Secrets Management](#secrets-management)
- [Host Security](#host-security)
- [Scanning Tools](#scanning-tools)
- [CIS Docker Benchmark](#cis-docker-benchmark)
- [Security Checklist](#security-checklist)

---

## Image Security

### Use Minimal Base Images

```dockerfile
# ❌ BAD — Full OS with unnecessary packages (900MB+)
FROM ubuntu:latest

# ✅ GOOD — Minimal Alpine (5MB)
FROM node:18-alpine

# ✅ BEST — Distroless (no shell, no package manager)
FROM gcr.io/distroless/nodejs18-debian12
```

| Base Image | Size | Attack Surface |
|-----------|------|----------------|
| ubuntu | ~77MB | High |
| debian-slim | ~50MB | Medium |
| alpine | ~5MB | Low |
| distroless | ~20MB | Minimal |

### Use Specific Image Tags

```dockerfile
# ❌ BAD — Can change unexpectedly
FROM node:latest

# ✅ GOOD — Pinned version
FROM node:18.19-alpine

# ✅ BEST — Pin with SHA digest
FROM node:18.19-alpine@sha256:abcdef1234567890...
```

### Don't Run as Root

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set ownership
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser
```

### Multi-Stage Builds (Remove Build Tools)

```dockerfile
# Stage 1: Build (has compilers, dev tools)
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production (no build tools, smaller attack surface)
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
CMD ["node", "dist/index.js"]
```

### Don't Store Secrets in Images

```dockerfile
# ❌ BAD — Secret is baked into image layer
ENV API_KEY=super-secret-key
COPY .env /app/.env

# ✅ GOOD — Pass at runtime
# docker run -e API_KEY=secret myapp
# docker run --env-file .env myapp
```

---

## Container Runtime Security

### Read-Only Filesystem

```bash
# Run with read-only filesystem
docker run --read-only nginx

# Allow writing to specific directories only
docker run --read-only --tmpfs /tmp --tmpfs /var/run nginx
```

### Drop All Capabilities, Add Only What's Needed

```bash
# Drop all Linux capabilities
docker run --cap-drop ALL nginx

# Add only specific ones needed
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
```

### Common Capabilities

| Capability | Purpose | Needed? |
|-----------|---------|---------|
| NET_BIND_SERVICE | Bind to ports < 1024 | Usually yes |
| CHOWN | Change file ownership | Rarely |
| SETUID/SETGID | Change user/group | Rarely |
| SYS_ADMIN | Mount, namespace ops | Almost never |
| NET_RAW | Raw sockets | Rarely |

### No New Privileges

```bash
# Prevent privilege escalation
docker run --security-opt=no-new-privileges nginx
```

### Resource Limits (Prevent DoS)

```bash
# Limit memory and CPU
docker run -m 512m --cpus="1.0" \
  --pids-limit 100 \
  --ulimit nofile=1024:1024 \
  nginx
```

### Disable Privileged Mode

```bash
# ❌ NEVER do this in production
docker run --privileged nginx

# ✅ Use specific capabilities instead
docker run --cap-add SYS_PTRACE myapp
```

### Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
```

---

## Network Security

### Use Custom Networks (Not Default Bridge)

```bash
# ❌ Default bridge — no DNS isolation
docker run nginx

# ✅ Custom network — isolated + DNS
docker network create --driver bridge secure-net
docker run --network secure-net nginx
```

### Restrict Inter-Container Communication

```bash
# Disable ICC on the Docker daemon
# /etc/docker/daemon.json
{
  "icc": false
}
```

### Don't Expose Unnecessary Ports

```bash
# ❌ BAD — Exposes to all interfaces
docker run -p 3306:3306 mysql

# ✅ GOOD — Bind to localhost only
docker run -p 127.0.0.1:3306:3306 mysql
```

### Use Internal Networks

```yaml
# docker-compose.yml
networks:
  backend:
    internal: true  # No external access

services:
  db:
    networks:
      - backend  # Only reachable by other containers on this network
```

---

## Secrets Management

### ❌ Bad Practices

```dockerfile
# Never do these:
ENV DB_PASSWORD=mysecret
COPY credentials.json /app/
RUN echo "password123" > /app/config
```

### ✅ Good Practices

```bash
# 1. Environment variables at runtime
docker run -e DB_PASSWORD=secret myapp

# 2. Env file (not committed to git)
docker run --env-file .env.production myapp

# 3. Docker secrets (Swarm mode)
echo "mysecret" | docker secret create db_password -
docker service create --secret db_password myapp

# 4. Mount secrets as files
docker run -v /run/secrets/db_password:/app/secrets/db_password:ro myapp
```

### Using AWS Secrets Manager

```bash
# Fetch secret at container startup (in entrypoint script)
#!/bin/bash
export DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id myapp/db-password \
  --query SecretString --output text)
exec "$@"
```

### Docker Compose Secrets

```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    secrets:
      - db_password
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## Host Security

### Keep Docker Updated

```bash
# Check version
docker version

# Update (Ubuntu/Debian)
sudo apt update && sudo apt upgrade docker-ce

# Update (RHEL/CentOS)
sudo yum update docker-ce
```

### Restrict Docker Daemon Access

```bash
# Only trusted users in docker group
# Docker group = root access to host!
sudo usermod -aG docker trusted_user

# Enable TLS for remote Docker daemon
dockerd --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=server-cert.pem \
  --tlskey=server-key.pem \
  -H=0.0.0.0:2376
```

### Enable Content Trust

```bash
# Only pull signed images
export DOCKER_CONTENT_TRUST=1
docker pull nginx:latest  # Will fail if not signed
```

### Docker Daemon Configuration

```json
// /etc/docker/daemon.json
{
  "icc": false,
  "userns-remap": "default",
  "no-new-privileges": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true
}
```

---

## Scanning Tools

### Trivy (Recommended — Free & Open Source)

```bash
# Install
sudo apt install trivy   # Debian/Ubuntu
brew install trivy       # macOS

# Scan an image
trivy image myapp:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL myapp:latest

# Scan Dockerfile
trivy config Dockerfile

# Scan docker-compose
trivy config docker-compose.yml

# Exit with error if vulnerabilities found (for CI/CD)
trivy image --exit-code 1 --severity CRITICAL myapp:latest
```

### Docker Scout (Built into Docker)

```bash
# Analyze image
docker scout cves myapp:latest

# Quick overview
docker scout quickview myapp:latest

# Recommendations
docker scout recommendations myapp:latest
```

### Snyk

```bash
# Install
npm install -g snyk

# Authenticate
snyk auth

# Scan image
snyk container test myapp:latest

# Scan Dockerfile
snyk iac test Dockerfile
```

### AWS ECR Image Scanning

```bash
# Enable scan on push
aws ecr put-image-scanning-configuration \
  --repository-name my-app \
  --image-scanning-configuration scanOnPush=true

# Manual scan
aws ecr start-image-scan \
  --repository-name my-app \
  --image-id imageTag=latest

# Get results
aws ecr describe-image-scan-findings \
  --repository-name my-app \
  --image-id imageTag=latest
```

### CI/CD Security Scanning (GitHub Actions)

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    format: 'table'
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

---

## CIS Docker Benchmark

The CIS (Center for Internet Security) Docker Benchmark provides security recommendations. Run the audit:

```bash
# Run CIS Docker Benchmark audit
docker run --rm --net host --pid host \
  --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /etc:/etc:ro \
  docker/docker-bench-security
```

### Key CIS Recommendations

| # | Recommendation | Priority |
|---|---------------|----------|
| 1 | Keep Docker updated | Critical |
| 2 | Restrict network access to Docker daemon | Critical |
| 3 | Set container user to non-root | High |
| 4 | Add HEALTHCHECK to containers | High |
| 5 | Don't use privileged containers | Critical |
| 6 | Limit container resources | Medium |
| 7 | Enable Content Trust | Medium |
| 8 | Configure centralized logging | Medium |
| 9 | Use read-only filesystem | Medium |
| 10 | Drop unnecessary capabilities | High |

---

## Security Checklist

### Image Build Time ✅
- [ ] Use minimal base image (alpine/distroless)
- [ ] Pin image versions with tags or SHA
- [ ] Run as non-root user
- [ ] Multi-stage build (no build tools in production)
- [ ] No secrets in image (no .env, no hardcoded keys)
- [ ] Use `.dockerignore`
- [ ] Scan image for vulnerabilities
- [ ] Sign images (Docker Content Trust)

### Runtime ✅
- [ ] Read-only filesystem where possible
- [ ] Drop all capabilities, add only required
- [ ] Set `--no-new-privileges`
- [ ] Limit memory and CPU
- [ ] Set PID limits
- [ ] Use custom networks (not default bridge)
- [ ] Don't use `--privileged`
- [ ] Set restart policies
- [ ] Health checks defined

### Infrastructure ✅
- [ ] Docker daemon up to date
- [ ] TLS enabled for remote access
- [ ] Restrict docker group membership
- [ ] Enable audit logging
- [ ] Regular vulnerability scans in CI/CD
- [ ] Lifecycle policies for old images
- [ ] Secrets via manager (not env vars when possible)

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
