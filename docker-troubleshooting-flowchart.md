# 🔧 Docker Troubleshooting Flowcharts

> Visual decision trees to quickly diagnose and fix common Docker issues.

---

## 🚫 Container Won't Start

```mermaid
flowchart TD
    A[Container won't start] --> B{Check: docker ps -a}
    B -->|Status: Created| C[Never started]
    B -->|Status: Exited| D{Check exit code}
    
    C --> C1[docker logs container_name]
    C1 --> C2{Error visible?}
    C2 -->|Yes| C3[Fix the error in code/config]
    C2 -->|No| C4[Try: docker run -it image bash]
    
    D -->|Exit 0| E[App finished normally<br/>Check CMD in Dockerfile]
    D -->|Exit 1| F[Application error<br/>Check: docker logs container_name]
    D -->|Exit 125| G[Docker daemon error<br/>Check Docker service status]
    D -->|Exit 126| H[Command cannot run<br/>Check permissions/entrypoint]
    D -->|Exit 127| I[Command not found<br/>Check CMD/ENTRYPOINT path]
    D -->|Exit 137| J[OOM Killed<br/>Increase memory: -m 1g]
    D -->|Exit 143| K[SIGTERM received<br/>Container was stopped gracefully]
```

---

## 🌐 Network Issues

```mermaid
flowchart TD
    A[Container network issue] --> B{What's the problem?}
    
    B -->|Can't reach internet| C{docker exec container ping 8.8.8.8}
    C -->|Timeout| D[Check Docker DNS<br/>docker exec container cat /etc/resolv.conf]
    D --> D1[Fix: docker run --dns 8.8.8.8 image]
    C -->|Works| E[DNS issue — can ping IP but not hostname]
    E --> E1[Fix: docker run --dns 8.8.8.8 image]
    
    B -->|Containers can't talk| F{Same network?}
    F -->|No| G[Fix: Put on same network<br/>docker network connect mynet container]
    F -->|Yes| H{Using default bridge?}
    H -->|Yes| I[Default bridge has NO DNS<br/>Fix: Use custom network]
    H -->|No / Custom| J[Check: docker exec container nslookup other_container]
    J --> J1[Verify container name matches]
    
    B -->|Port not accessible| K{docker port container}
    K -->|No ports| L[Fix: Run with -p flag<br/>docker run -p 8080:80 image]
    K -->|Port mapped| M[Check host firewall<br/>Check if port already in use]
    M --> M1[netstat -tlnp OR ss -tlnp]
```

---

## 💾 Volume / Data Issues

```mermaid
flowchart TD
    A[Volume/Data problem] --> B{What's the issue?}
    
    B -->|Data lost after restart| C{Using volumes?}
    C -->|No| D[Fix: Add volume<br/>docker run -v mydata:/app/data image]
    C -->|Yes| E[Check volume mount path<br/>docker inspect container]
    
    B -->|Permission denied| F{Who owns the files?}
    F --> F1[docker exec container ls -la /path]
    F1 -->|Root owns, app is non-root| F2[Fix in Dockerfile:<br/>RUN chown -R appuser:appuser /path]
    F1 -->|UID mismatch| F3[Fix: Match host UID<br/>docker run -u $(id -u):$(id -g) image]
    
    B -->|Volume not showing data| G[Check mount path is correct]
    G --> G1[docker inspect -f '{{.Mounts}}' container]
    G1 --> G2{Path correct?}
    G2 -->|No| G3[Fix the -v path]
    G2 -->|Yes| G4[Check if container writes to that path]
```

---

## 🖼️ Image Build Fails

```mermaid
flowchart TD
    A[Docker build fails] --> B{Where does it fail?}
    
    B -->|COPY/ADD fails| C[File not found]
    C --> C1[Check .dockerignore<br/>Check path relative to Dockerfile]
    
    B -->|RUN command fails| D{What type of error?}
    D -->|Package not found| E[Wrong base image or package name<br/>alpine uses apk, debian uses apt]
    D -->|Permission denied| F[Add: USER root before the RUN<br/>Switch back after]
    D -->|Network error| G[Check internet access<br/>Try: docker build --network host]
    
    B -->|FROM fails| H[Image not found]
    H --> H1[Check image name/tag<br/>docker pull image:tag manually]
    
    B -->|Out of space| I[docker system prune -a<br/>Or increase disk space]
    
    B -->|Very slow| J[Layer caching issue]
    J --> J1[Move COPY package*.json BEFORE COPY . .]
```

---

## 🔄 Container Keeps Restarting

```mermaid
flowchart TD
    A[Container restart loop] --> B[docker logs --tail 50 container]
    B --> C{Error visible?}
    
    C -->|Yes - App crash| D[Fix app code/config]
    C -->|Yes - Port in use| E[Change port or stop conflicting container]
    C -->|Yes - File not found| F[Check volumes and WORKDIR]
    C -->|Yes - OOM| G[Increase memory limit: -m 1g]
    C -->|No error visible| H{Check exit code}
    
    H --> I[docker inspect -f '{{.State.ExitCode}}' container]
    I -->|137| J[Out of memory → increase -m]
    I -->|1| K[App error → run interactively to debug]
    I -->|0| L[App exits normally → check CMD keeps running]
    
    L --> L1[CMD must be a long-running process<br/>Not a script that exits]
```

---

## 🐌 Container Running Slow

```mermaid
flowchart TD
    A[Container is slow] --> B[docker stats container]
    B --> C{What's high?}
    
    C -->|CPU > 90%| D[CPU bottleneck]
    D --> D1[Increase --cpus limit<br/>Or optimize app code]
    
    C -->|Memory near limit| E[Memory pressure]
    E --> E1[Increase -m limit<br/>Check for memory leaks]
    
    C -->|I/O high| F[Disk bottleneck]
    F --> F1[Use volumes instead of bind mounts<br/>Use tmpfs for temp files]
    
    C -->|All normal| G[Not a Docker issue]
    G --> G1[Profile the app itself<br/>Check network latency between services]
```

---

## 🧹 Disk Space Full

```mermaid
flowchart TD
    A[Docker disk space full] --> B[docker system df]
    B --> C{What's using space?}
    
    C -->|Images| D[docker image prune -a<br/>Removes all unused images]
    C -->|Containers| E[docker container prune<br/>Removes stopped containers]
    C -->|Volumes| F[docker volume prune<br/>⚠️ Removes unused volumes - check first!]
    C -->|Build Cache| G[docker builder prune<br/>Clears build cache]
    
    D --> H[Still full?]
    E --> H
    F --> H
    G --> H
    H -->|Yes| I[Nuclear option:<br/>docker system prune -a --volumes]
    H -->|No| J[✅ Space recovered]
```

---

## 🔍 Quick Diagnostic Commands

```bash
# System overview
docker system df              # Disk usage
docker system info            # System info
docker system events          # Real-time events

# Container diagnosis
docker inspect container      # Full details
docker logs container         # Logs
docker stats container        # Resource usage
docker top container          # Running processes
docker diff container         # File changes
docker port container         # Port mappings

# Network diagnosis
docker network ls             # List networks
docker network inspect net    # Network details
docker exec container ping host  # Test connectivity
docker exec container nslookup service  # Test DNS

# Image diagnosis
docker history image          # Layer history
docker inspect image          # Image details
```

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
