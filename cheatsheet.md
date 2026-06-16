# 🐳 Docker Cheatsheet — Quick Reference

> Print this. Pin it. Use it daily.

## Images

| Command | Description |
|---------|-------------|
| `docker images` | List images |
| `docker pull IMAGE:TAG` | Pull image |
| `docker build -t NAME .` | Build image |
| `docker rmi IMAGE` | Remove image |
| `docker image prune` | Remove unused images |
| `docker tag SRC TARGET` | Tag image |
| `docker save -o file.tar IMAGE` | Export image |
| `docker load -i file.tar` | Import image |

## Containers

| Command | Description |
|---------|-------------|
| `docker run -d -p 8080:80 --name web nginx` | Run container |
| `docker ps` | List running |
| `docker ps -a` | List all |
| `docker stop NAME` | Stop |
| `docker start NAME` | Start |
| `docker restart NAME` | Restart |
| `docker rm NAME` | Remove |
| `docker rm -f NAME` | Force remove |
| `docker exec -it NAME bash` | Shell access |
| `docker logs -f NAME` | Follow logs |
| `docker cp file.txt NAME:/path` | Copy to container |

## Docker Run Flags

| Flag | Example | Description |
|------|---------|-------------|
| `-d` | `docker run -d nginx` | Detached |
| `-p` | `-p 8080:80` | Port map |
| `-v` | `-v data:/app` | Volume |
| `-e` | `-e KEY=val` | Env variable |
| `--name` | `--name web` | Name it |
| `--rm` | `--rm` | Auto-remove |
| `-it` | `-it ubuntu bash` | Interactive |
| `-m` | `-m 512m` | Memory limit |
| `--cpus` | `--cpus="1.5"` | CPU limit |
| `--network` | `--network mynet` | Network |
| `--restart` | `--restart unless-stopped` | Restart policy |

## Docker Compose

| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start services |
| `docker-compose down` | Stop & remove |
| `docker-compose down -v` | Stop & remove volumes |
| `docker-compose logs -f` | Follow logs |
| `docker-compose exec SERVICE cmd` | Run command |
| `docker-compose build` | Build images |
| `docker-compose ps` | List services |
| `docker-compose pull` | Pull images |
| `docker-compose restart` | Restart all |

## Volumes

| Command | Description |
|---------|-------------|
| `docker volume ls` | List |
| `docker volume create NAME` | Create |
| `docker volume rm NAME` | Remove |
| `docker volume prune` | Remove unused |

## Networks

| Command | Description |
|---------|-------------|
| `docker network ls` | List |
| `docker network create NAME` | Create |
| `docker network connect NET CONTAINER` | Connect |
| `docker network disconnect NET CONTAINER` | Disconnect |
| `docker network prune` | Remove unused |

## Cleanup

| Command | Description |
|---------|-------------|
| `docker system prune` | Remove unused data |
| `docker system prune -a --volumes` | Remove EVERYTHING unused |
| `docker system df` | Show disk usage |
| `docker container prune` | Remove stopped containers |
| `docker image prune -a` | Remove unused images |

## Dockerfile Quick Reference

```dockerfile
FROM node:18-alpine        # Base image
WORKDIR /app               # Set directory
COPY package*.json ./      # Copy files
RUN npm ci                 # Run command
COPY . .                   # Copy rest
EXPOSE 3000                # Document port
USER node                  # Non-root user
CMD ["node", "index.js"]   # Start command
```

## AWS ECR Quick Commands

```bash
# Login
aws ecr get-login-password --region REGION | docker login --username AWS --password-stdin ACCOUNT.dkr.ecr.REGION.amazonaws.com

# Tag + Push
docker tag myapp:latest ACCOUNT.dkr.ecr.REGION.amazonaws.com/myapp:latest
docker push ACCOUNT.dkr.ecr.REGION.amazonaws.com/myapp:latest
```

---

*Created by [Krishna Yada](https://github.com/yadakrishna245) ⭐*
