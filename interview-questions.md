# 🎯 Docker Interview Questions & Answers

> Top Docker questions asked in DevOps, SysAdmin, and Cloud Engineer interviews.

📌 [← Back to README](./README.md)

---

## 📑 Table of Contents

- [🟢 Beginner Level (Q1-10)](#-beginner-level)
- [🟡 Intermediate Level (Q11-25)](#-intermediate-level)
- [🔴 Advanced Level (Q26-45)](#-advanced-level)
- [💡 Scenario-Based Questions (Q46-55)](#-scenario-based-questions)

---

## 🟢 Beginner Level

### 1. What is Docker?
Docker is a containerization platform that packages applications and their dependencies into lightweight, portable containers that can run consistently across any environment.

### 2. What is the difference between a Docker Image and a Container?
- **Image** — A read-only template/blueprint (like a class in OOP)
- **Container** — A running instance of an image (like an object)

### 3. What is a Dockerfile?
A text file containing instructions to build a Docker image. Each instruction creates a layer in the image.

### 4. What is Docker Hub?
A public cloud-based registry for storing and sharing Docker images. It's the default registry for Docker.

### 5. Difference between Docker and Virtual Machines?
| Docker | VM |
|--------|-----|
| Shares host OS kernel | Runs full guest OS |
| Starts in seconds | Starts in minutes |
| MBs in size | GBs in size |
| Process-level isolation | Hardware-level isolation |

### 6. What is the purpose of the `docker run` command?
Creates a new container from an image and starts it. It combines `docker create` + `docker start`.

### 7. How do you list running containers?
```bash
docker ps        # running only
docker ps -a     # all (including stopped)
```

### 8. What is Docker Compose?
A tool for defining and running multi-container applications using a YAML file (`docker-compose.yml`).

### 9. What does `-d` flag do in `docker run`?
Runs the container in **detached mode** (in the background).

### 10. How do you stop and remove a container?
```bash
docker stop container_name
docker rm container_name
# Or force remove a running container:
docker rm -f container_name
```

---

## 🟡 Intermediate Level

### 11. What is the difference between `CMD` and `ENTRYPOINT`?
- **CMD** — Default command, can be overridden at runtime
- **ENTRYPOINT** — Always executes, CMD becomes its arguments

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
# Running: docker run myimage other.py → executes: python other.py
```

### 12. What is Docker layer caching?
Each Dockerfile instruction creates a layer. Docker caches layers and reuses them if the instruction and context haven't changed. This speeds up builds significantly.

**Best practice:** Put frequently changing instructions (like `COPY . .`) at the bottom.

### 13. What are Docker volumes and why are they needed?
Volumes provide persistent storage for containers. Without volumes, data inside a container is lost when the container is removed.

Types:
- **Named volumes** — Managed by Docker (`-v mydata:/app/data`)
- **Bind mounts** — Host directory mapped (`-v ./src:/app/src`)
- **tmpfs** — In-memory only

### 14. What is a multi-stage build?
A Dockerfile technique using multiple `FROM` statements to reduce final image size. Build dependencies stay in the build stage and only the output is copied to the production stage.

### 15. What Docker networking drivers are available?
| Driver | Use Case |
|--------|----------|
| bridge | Default, containers on same host |
| host | No network isolation, uses host network |
| overlay | Multi-host (Docker Swarm) |
| macvlan | Container gets its own MAC address |
| none | No networking |

### 16. How do containers communicate on the same network?
Containers on the same user-defined network can reach each other **by container name** (Docker provides DNS resolution).

```bash
docker network create mynet
docker run --name api --network mynet myapp
docker run --name web --network mynet nginx
# 'web' can access 'api' at http://api:3000
```

### 17. What is the difference between `COPY` and `ADD` in Dockerfile?
- **COPY** — Simple file copy from host to image
- **ADD** — Same as COPY + supports URLs and auto-extracts tar files

**Best practice:** Use `COPY` unless you specifically need ADD's extra features.

### 18. What is `.dockerignore`?
A file that excludes files/directories from the Docker build context. Similar to `.gitignore`. Reduces build time and image size.

### 19. How do you check logs of a container?
```bash
docker logs container_name       # all logs
docker logs -f container_name    # follow (live)
docker logs --tail 100 container_name  # last 100 lines
```

### 20. What restart policies are available?
| Policy | Behavior |
|--------|----------|
| `no` | Never restart (default) |
| `always` | Always restart |
| `on-failure:N` | Restart on failure, max N times |
| `unless-stopped` | Restart unless manually stopped |

### 21. What is the difference between bridge and overlay networks?
- **Bridge** — Single-host networking. Containers on the same Docker host communicate via a virtual bridge.
- **Overlay** — Multi-host networking. Containers across different Docker hosts (Swarm nodes) communicate securely via VXLAN tunneling.

```bash
# Create bridge network (single host)
docker network create --driver bridge my-bridge

# Create overlay network (requires Swarm mode)
docker network create --driver overlay --attachable my-overlay
```

### 22. How does Docker DNS resolution work in user-defined networks?
Docker runs an embedded DNS server at `127.0.0.11` for containers on user-defined networks. Containers can resolve each other by name or network alias. The default `bridge` network does NOT support DNS — only `--link` (deprecated).

```bash
# Create network with aliases
docker run --name db --network mynet --network-alias database postgres
# Other containers on 'mynet' can reach it via 'db' or 'database'
```

### 23. What is the difference between named volumes and bind mounts?
| Feature | Named Volume | Bind Mount |
|---------|-------------|------------|
| Managed by | Docker | User |
| Location | `/var/lib/docker/volumes/` | Any host path |
| Pre-populated | Yes (from image) | No |
| Portability | High | Host-dependent |
| Backup | `docker volume` commands | Standard file tools |

```bash
# Named volume
docker run -v app-data:/app/data myapp

# Bind mount
docker run -v $(pwd)/config:/app/config:ro myapp
```

### 24. How do you backup and restore Docker volumes?
```bash
# Backup: Create a tar archive from volume
docker run --rm -v mydata:/source -v $(pwd):/backup alpine \
  tar czf /backup/mydata-backup.tar.gz -C /source .

# Restore: Extract tar archive into volume
docker run --rm -v mydata:/target -v $(pwd):/backup alpine \
  tar xzf /backup/mydata-backup.tar.gz -C /target
```

### 25. What is the difference between `depends_on` and `healthcheck` in Docker Compose?
- **`depends_on`** — Only controls startup *order*, doesn't wait for the service to be "ready"
- **`healthcheck`** — Defines a command to check if a service is actually healthy

```yaml
services:
  db:
    image: postgres
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  app:
    image: myapp
    depends_on:
      db:
        condition: service_healthy  # Waits for healthcheck to pass
```

---

## 🔴 Advanced Level

### 26. How does Docker achieve isolation?
Docker uses Linux kernel features:
- **Namespaces** — Process isolation (PID, NET, MNT, UTS, IPC, USER)
- **Cgroups** — Resource limits (CPU, memory, I/O)
- **Union filesystems** — Layered file system (OverlayFS)

### 27. What is the Docker daemon?
`dockerd` — A background process that manages Docker objects (containers, images, networks, volumes). It listens for Docker API requests from the Docker client.

### 28. How do you reduce Docker image size?
1. Use minimal base images (`alpine`, `slim`, `distroless`)
2. Multi-stage builds
3. Combine RUN commands (fewer layers)
4. Use `.dockerignore`
5. Remove cache (`--no-cache-dir`, `rm -rf /var/cache`)
6. Don't install unnecessary packages

### 29. What is Docker Swarm vs Kubernetes?
| Feature | Docker Swarm | Kubernetes |
|---------|-------------|------------|
| Complexity | Simple | Complex |
| Scaling | Basic | Advanced (HPA, VPA) |
| Load Balancing | Built-in | Requires Ingress |
| Market Share | Low | Dominant |
| Learning Curve | Easy | Steep |

### 30. How do you secure Docker containers?
1. Run as non-root user (`USER` in Dockerfile)
2. Use minimal base images
3. Scan images for vulnerabilities
4. Use read-only filesystems (`--read-only`)
5. Limit resources (`-m`, `--cpus`)
6. Don't store secrets in images
7. Use specific image tags (not `:latest`)
8. Enable Content Trust (`DOCKER_CONTENT_TRUST=1`)

### 31. What is Docker Content Trust?
A security feature that uses digital signatures to verify image integrity. When enabled, Docker only pulls signed images.

```bash
export DOCKER_CONTENT_TRUST=1
docker pull nginx:latest  # Only pulls if signed
```

### 32. Explain the Docker build process.
1. Docker reads the Dockerfile
2. Creates a temporary container for each instruction
3. Executes the instruction
4. Commits the container as a new layer
5. Removes the temporary container
6. Final image = all layers stacked together

### 33. What is the difference between `docker stop` and `docker kill`?
- **`docker stop`** — Sends SIGTERM (graceful), then SIGKILL after timeout (default 10s)
- **`docker kill`** — Sends SIGKILL immediately (no cleanup)

### 34. How do you run a container as a non-root user?
```dockerfile
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --chown=appuser:appgroup . .
USER appuser
CMD ["node", "server.js"]
```

At runtime, verify: `docker exec container_name whoami` → `appuser`

### 35. What are Linux capabilities in Docker and how do you manage them?
Capabilities split root privileges into granular units. Docker drops most capabilities by default but you can further restrict or add them.

```bash
# Drop all capabilities, add only what's needed
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# View capabilities of a running container
docker inspect --format='{{.HostConfig.CapDrop}}' container_name
```

### 36. What is the difference between Alpine and Distroless base images?
| Feature | Alpine | Distroless |
|---------|--------|-----------|
| Size | ~5MB | ~2-20MB |
| Shell | Yes (ash) | No |
| Package manager | apk | None |
| Debugging | Easy (shell access) | Hard (no shell) |
| Attack surface | Small | Minimal |
| Use case | General purpose | Production-hardened |

```dockerfile
# Alpine
FROM node:20-alpine

# Distroless
FROM gcr.io/distroless/nodejs20-debian12
```

### 37. How do you optimize Docker layer caching in CI/CD?
```dockerfile
# ✅ Good: Dependencies cached separately from code
FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production
COPY . .

# ❌ Bad: Any code change invalidates npm install cache
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci --only=production
```

In CI pipelines, use `--cache-from` to leverage registry-based caching:
```bash
docker build --cache-from=myapp:latest -t myapp:v2 .
```

### 38. How do you set resource limits on containers?
Docker uses cgroups to enforce resource limits:

```bash
# Memory limit (container killed if exceeds)
docker run -m 512m myapp

# CPU limit (max 1.5 cores)
docker run --cpus=1.5 myapp

# CPU shares (relative weight, default 1024)
docker run --cpu-shares=512 myapp

# Memory + swap
docker run -m 512m --memory-swap=1g myapp
```

### 39. What happens when a container exceeds its memory limit (OOM)?
1. The kernel's OOM killer terminates the container's main process
2. Container exits with code `137` (128 + 9 = SIGKILL)
3. Docker logs it as an OOM event

```bash
# Check if a container was OOM killed
docker inspect -f '{{.State.OOMKilled}}' container_name

# View memory usage
docker stats container_name
```

### 40. What are Docker storage drivers and which should you use?
Storage drivers manage the layered filesystem:

| Driver | Platform | Notes |
|--------|----------|-------|
| overlay2 | Linux (default) | Best performance, recommended |
| fuse-overlayfs | Rootless | For rootless Docker |
| btrfs | btrfs filesystem | Snapshot-based |
| zfs | ZFS filesystem | Advanced features |
| vfs | Any | No CoW, slow, testing only |

Check current driver: `docker info | grep "Storage Driver"`

### 41. How do you configure the Docker daemon?
Edit `/etc/docker/daemon.json`:

```json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {"base": "172.20.0.0/16", "size": 24}
  ],
  "insecure-registries": [],
  "live-restore": true,
  "userland-proxy": false
}
```

Reload: `systemctl reload docker` (for some changes) or `systemctl restart docker`

### 42. How do you use Docker in CI/CD pipelines?
```yaml
# GitHub Actions example
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v5
        with:
          push: true
          tags: ghcr.io/myorg/myapp:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

Key practices:
- Use immutable tags (git SHA, not `latest`)
- Scan images before pushing (Trivy, Snyk)
- Use multi-stage builds to keep CI images lean
- Cache layers between builds

### 43. How do you debug a container in production?
```bash
# 1. Exec into running container
docker exec -it container_name /bin/sh

# 2. If no shell (distroless), use debug container
docker debug container_name

# 3. Inspect networking
docker exec container_name netstat -tlnp
docker exec container_name cat /etc/resolv.conf

# 4. Copy files out for analysis
docker cp container_name:/app/logs ./local-logs

# 5. Attach a sidecar with debugging tools
docker run --rm -it --pid=container:target --network=container:target \
  nicolaka/netshoot

# 6. Check resource usage
docker stats container_name
```

### 44. What is Docker overlay networking internals?
Overlay networks use **VXLAN** (Virtual Extensible LAN) to encapsulate container traffic across hosts:

1. Each node gets a VTEP (VXLAN Tunnel Endpoint)
2. Container traffic is encapsulated in UDP packets (port 4789)
3. Serf protocol handles gossip-based node discovery
4. Each overlay network gets its own network namespace
5. `docker_gwbridge` handles external traffic from overlay containers

Required ports for Swarm overlay:
- TCP/UDP 7946 (node discovery)
- UDP 4789 (VXLAN data)
- TCP 2377 (Swarm management)

### 45. How do you scan Docker images for vulnerabilities?
```bash
# Docker Scout (built-in)
docker scout cves myimage:latest

# Trivy (popular open-source scanner)
trivy image myimage:latest

# Snyk
snyk container test myimage:latest

# In Dockerfile — fail build on critical vulns
# CI pipeline step:
trivy image --exit-code 1 --severity CRITICAL myimage:latest
```

Best practices:
- Scan in CI before pushing to registry
- Set up automated scanning on registry (ECR, GCR)
- Use `--ignore-unfixed` to reduce noise
- Pin base image digests for reproducibility

### 46. What is `docker buildx` and how does it improve builds?
BuildKit-based builder with advanced features:

```bash
# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:v1 --push .

# Build with inline cache metadata
docker buildx build --cache-to type=inline -t myapp:v1 .

# Use remote cache
docker buildx build \
  --cache-from type=registry,ref=myrepo/myapp:cache \
  --cache-to type=registry,ref=myrepo/myapp:cache \
  -t myapp:v1 .
```

### 47. How do you implement the sidecar pattern with Docker Compose?
```yaml
services:
  app:
    image: myapp:latest
    volumes:
      - app-logs:/var/log/app

  # Sidecar: log forwarder
  log-shipper:
    image: fluent/fluentd
    volumes:
      - app-logs:/var/log/app:ro
    depends_on:
      - app

  # Sidecar: reverse proxy
  proxy:
    image: envoyproxy/envoy
    ports:
      - "80:80"
    depends_on:
      app:
        condition: service_healthy

volumes:
  app-logs:
```

### 48. How do you handle environment variables securely in Docker Compose?
```yaml
services:
  app:
    image: myapp
    environment:
      - NODE_ENV=production
    env_file:
      - .env              # loaded at compose-up time
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt   # Compose secrets (mounted at /run/secrets/)
```

**Precedence order:** `environment` > `env_file` > Dockerfile `ENV`

Never commit `.env` files — add to `.gitignore`.

### 49. What is `live-restore` in Docker daemon configuration?
When `"live-restore": true` is set in `daemon.json`, containers keep running even if the Docker daemon stops or is upgraded. This is critical for production:

```json
{ "live-restore": true }
```

Without it, a daemon restart kills all containers.

---

## 💡 Scenario-Based Questions

### 50. Your container runs locally but fails in production. How do you debug?
1. Check environment variables (might differ)
2. Compare Docker versions
3. Check resource limits (memory/CPU)
4. Verify network connectivity
5. Check volume mounts and file permissions
6. Review logs: `docker logs container_name`

### 51. How do you handle secrets in Docker?
- ❌ Never put secrets in Dockerfile or image
- ✅ Use environment variables at runtime (`-e` or `--env-file`)
- ✅ Use Docker secrets (Swarm mode)
- ✅ Use AWS Secrets Manager / Parameter Store
- ✅ Use HashiCorp Vault

### 52. How would you set up zero-downtime deployment with Docker?
1. Use a reverse proxy (Nginx/Traefik)
2. Start new container with new version
3. Health check passes
4. Update proxy to point to new container
5. Stop old container
6. Or use Docker Compose rolling updates / Kubernetes

### 53. A container is OOM-killed repeatedly. How do you fix it?
```bash
# 1. Confirm OOM
docker inspect -f '{{.State.OOMKilled}}' container_name

# 2. Check actual memory usage
docker stats --no-stream container_name

# 3. Profile the application inside
docker exec container_name cat /proc/meminfo
docker exec container_name top -bn1

# 4. Solutions (pick based on root cause):
# a) Increase memory limit
docker run -m 1g myapp

# b) Fix memory leak in application
# c) Add swap as a buffer
docker run -m 512m --memory-swap=1g myapp

# d) Set memory reservation (soft limit) for better scheduling
docker run -m 1g --memory-reservation=512m myapp
```

### 54. Containers can't reach each other by name. How do you fix DNS resolution?
```bash
# 1. Are they on the same user-defined network?
docker inspect container_name -f '{{json .NetworkSettings.Networks}}'

# 2. Default bridge doesn't support DNS! Create a user-defined network
docker network create app-net
docker run --name api --network app-net myapi
docker run --name web --network app-net myweb

# 3. Check DNS inside container
docker exec web nslookup api
docker exec web cat /etc/resolv.conf
# Should show: nameserver 127.0.0.11

# 4. If using docker-compose, services auto-join a default network
# and can reach each other by service name
```

### 55. Your Docker image is 1.2GB. How do you reduce it?
```dockerfile
# Before: 1.2GB (using full node image + dev deps)
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
CMD ["node", "server.js"]

# After: ~150MB (multi-stage + alpine + production only)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
RUN npm prune --production
USER node
CMD ["node", "dist/server.js"]
```

Additional steps:
- Add `.dockerignore` (exclude `node_modules`, `.git`, `docs`, tests)
- Use `docker image history myapp` to find large layers
- Consider `distroless` for even smaller production images

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
