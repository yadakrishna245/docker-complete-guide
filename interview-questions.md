# 🎯 Docker Interview Questions & Answers

> Top Docker questions asked in DevOps, SysAdmin, and Cloud Engineer interviews.

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

---

## 🔴 Advanced Level

### 21. How does Docker achieve isolation?
Docker uses Linux kernel features:
- **Namespaces** — Process isolation (PID, NET, MNT, UTS, IPC, USER)
- **Cgroups** — Resource limits (CPU, memory, I/O)
- **Union filesystems** — Layered file system (OverlayFS)

### 22. What is the Docker daemon?
`dockerd` — A background process that manages Docker objects (containers, images, networks, volumes). It listens for Docker API requests from the Docker client.

### 23. How do you reduce Docker image size?
1. Use minimal base images (`alpine`, `slim`, `distroless`)
2. Multi-stage builds
3. Combine RUN commands (fewer layers)
4. Use `.dockerignore`
5. Remove cache (`--no-cache-dir`, `rm -rf /var/cache`)
6. Don't install unnecessary packages

### 24. What is Docker Swarm vs Kubernetes?
| Feature | Docker Swarm | Kubernetes |
|---------|-------------|------------|
| Complexity | Simple | Complex |
| Scaling | Basic | Advanced (HPA, VPA) |
| Load Balancing | Built-in | Requires Ingress |
| Market Share | Low | Dominant |
| Learning Curve | Easy | Steep |

### 25. How do you secure Docker containers?
1. Run as non-root user (`USER` in Dockerfile)
2. Use minimal base images
3. Scan images for vulnerabilities
4. Use read-only filesystems (`--read-only`)
5. Limit resources (`-m`, `--cpus`)
6. Don't store secrets in images
7. Use specific image tags (not `:latest`)
8. Enable Content Trust (`DOCKER_CONTENT_TRUST=1`)

### 26. What is Docker Content Trust?
A security feature that uses digital signatures to verify image integrity. When enabled, Docker only pulls signed images.

```bash
export DOCKER_CONTENT_TRUST=1
docker pull nginx:latest  # Only pulls if signed
```

### 27. Explain the Docker build process.
1. Docker reads the Dockerfile
2. Creates a temporary container for each instruction
3. Executes the instruction
4. Commits the container as a new layer
5. Removes the temporary container
6. Final image = all layers stacked together

### 28. What is the difference between `docker stop` and `docker kill`?
- **`docker stop`** — Sends SIGTERM (graceful), then SIGKILL after timeout (default 10s)
- **`docker kill`** — Sends SIGKILL immediately (no cleanup)

### 29. How would you troubleshoot a container that keeps restarting?
```bash
# 1. Check logs
docker logs container_name

# 2. Check exit code
docker inspect -f '{{.State.ExitCode}}' container_name

# 3. Run without restart policy
docker run --restart=no image_name

# 4. Run interactively to debug
docker run -it image_name /bin/bash

# 5. Check resource limits
docker stats container_name
```

### 30. What is AWS ECR and why use it over Docker Hub?
AWS ECR (Elastic Container Registry) is a private managed registry.

Advantages over Docker Hub:
- No pull rate limits
- Private by default
- IAM-based access control
- Integrated with ECS/EKS/Lambda
- Image vulnerability scanning
- Lifecycle policies for cleanup
- Encrypted at rest

---

## 💡 Scenario-Based Questions

### 31. Your container runs locally but fails in production. How do you debug?
1. Check environment variables (might differ)
2. Compare Docker versions
3. Check resource limits (memory/CPU)
4. Verify network connectivity
5. Check volume mounts and file permissions
6. Review logs: `docker logs container_name`

### 32. How do you handle secrets in Docker?
- ❌ Never put secrets in Dockerfile or image
- ✅ Use environment variables at runtime (`-e` or `--env-file`)
- ✅ Use Docker secrets (Swarm mode)
- ✅ Use AWS Secrets Manager / Parameter Store
- ✅ Use HashiCorp Vault

### 33. How would you set up zero-downtime deployment with Docker?
1. Use a reverse proxy (Nginx/Traefik)
2. Start new container with new version
3. Health check passes
4. Update proxy to point to new container
5. Stop old container
6. Or use Docker Compose rolling updates / Kubernetes

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
