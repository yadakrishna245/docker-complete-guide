# 📝 Production-Ready Dockerfiles

> Real-world, production-grade Dockerfiles for popular frameworks and languages.

## Available Examples

### 🚀 Application Dockerfiles

| Language/Framework | Image Size | Base Image | Key Features |
|-------------------|-----------|------------|--------------|
| [Node.js](nodejs/Dockerfile) | ~150MB | node:18-alpine | Multi-stage, non-root, healthcheck |
| [Next.js/React](nextjs/Dockerfile) | ~120MB | node:20-alpine | 3-stage, standalone output, static files |
| [Python (FastAPI)](python/Dockerfile) | ~180MB | python:3.11-slim | Non-root, healthcheck, uvicorn |
| [Django](django/Dockerfile) | ~200MB | python:3.12-slim | Gunicorn, collectstatic, PostgreSQL |
| [Go](golang/Dockerfile) | ~10MB | distroless/static | Scratch build, zero OS, CA certs |
| [Rust](rust/Dockerfile) | ~5MB | scratch | Static binary, zero dependencies |
| [Java (Spring Boot)](spring-boot/Dockerfile) | ~250MB | eclipse-temurin:21-jre-alpine | Layered JAR, container-aware JVM |
| [Java (Generic)](java/Dockerfile) | ~200MB | eclipse-temurin:17-jre-alpine | Multi-stage, Maven build |
| [.NET 8](dotnet/Dockerfile) | ~100MB | aspnet:8.0-alpine | AOT-ready, non-root |
| [PHP (Laravel)](laravel/Dockerfile) | ~120MB | php:8.3-fpm-alpine | Nginx + FPM, OPcache, Composer |
| [Ruby (Rails)](rails/Dockerfile) | ~250MB | ruby:3.3-slim | Puma, asset precompile, 3-stage |
| [Nginx](nginx/Dockerfile) | ~25MB | nginx:alpine | Custom config, security headers |

### 🐧 Linux / SysAdmin / DevOps Toolbox

| Image | Base | Use Case |
|-------|------|----------|
| [Ubuntu DevOps](ubuntu-devops/Dockerfile) | ubuntu:24.04 | Full DevOps toolbox (AWS CLI, Docker, kubectl, Terraform, Ansible) |
| [RHEL/Rocky SysAdmin](rhel-sysadmin/Dockerfile) | rockylinux:9 | Enterprise Linux with admin tools (mirrors RHEL 9) |
| [Amazon Linux 2023](amazon-linux/Dockerfile) | amazonlinux:2023 | AWS-native ops (mirrors EC2, eksctl, SSM) |
| [Alpine Debug](alpine-debug/Dockerfile) | alpine:3.19 | Minimal ~15MB network troubleshooting container |
| [Jenkins Agent](jenkins-agent/Dockerfile) | ubuntu:22.04 | CI/CD agent (Java, Node, Python, Docker, Trivy, SonarQube) |

## Production Best Practices Used

All Dockerfiles follow these practices:

- ✅ **Multi-stage builds** — Smallest possible final image
- ✅ **Non-root user** — Never run as root in production
- ✅ **Health checks** — Container self-monitoring
- ✅ **Layer caching** — Dependencies before source code
- ✅ **Specific tags** — No `:latest` in production
- ✅ **Minimal base** — Alpine/slim/distroless where possible
- ✅ **No secrets in image** — Use runtime env vars or secrets manager

## Quick Usage

```bash
# Build any example
cd examples/golang
docker build -t myapp:prod .

# Run with production settings
docker run -d -p 8080:8080 \
  --name myapp \
  --restart unless-stopped \
  -m 512m --cpus="1.0" \
  myapp:prod
```

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
