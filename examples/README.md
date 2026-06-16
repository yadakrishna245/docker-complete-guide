# 📁 Example Dockerfiles

> Production-ready Dockerfiles for popular frameworks. Copy and customize for your project.

## Available Examples

| Framework | Dockerfile | Key Features |
|-----------|-----------|--------------|
| **Node.js** | [nodejs/Dockerfile](nodejs/Dockerfile) | Multi-stage build, Alpine, non-root user, health check |
| **Python** | [python/Dockerfile](python/Dockerfile) | Slim base, pip caching, non-root user, health check |
| **Java** | [java/Dockerfile](java/Dockerfile) | Maven multi-stage, JRE-only production, Spring Boot |
| **Nginx** | [nginx/Dockerfile](nginx/Dockerfile) | Static site + reverse proxy config |

## How to Use

```bash
# 1. Copy the Dockerfile to your project
cp examples/nodejs/Dockerfile ./Dockerfile

# 2. Customize for your app (change CMD, EXPOSE, etc.)

# 3. Build
docker build -t my-app:latest .

# 4. Run
docker run -d -p 3000:3000 my-app:latest
```

## Best Practices Used in All Examples

- ✅ Multi-stage builds (smaller images)
- ✅ Non-root user (security)
- ✅ Layer caching (fast builds)
- ✅ Health checks
- ✅ Minimal base images (Alpine/Slim)

---

*Created by [Krishna Yada](https://github.com/yadakrishna245)*
