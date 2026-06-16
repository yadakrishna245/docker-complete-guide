# 📁 Docker Compose Examples

> Ready-to-use multi-container stacks. Just `docker-compose up -d` and go.

## Available Stacks

| Stack | Directory | Services | Ports |
|-------|-----------|----------|-------|
| **MERN** | [mern-stack/](mern-stack/) | MongoDB + Express + React + Node | 3000, 5000, 27017 |
| **WordPress** | [wordpress/](wordpress/) | WordPress + MySQL + phpMyAdmin | 8080, 8081 |
| **Nginx Proxy** | [nginx-proxy/](nginx-proxy/) | Nginx + Node API + PostgreSQL + Redis | 80 |
| **Monitoring** | [monitoring/](monitoring/) | Prometheus + Grafana + cAdvisor + Node Exporter | 3000, 9090, 8080 |

## How to Use

```bash
# 1. Navigate to the stack you want
cd docker-compose-examples/wordpress

# 2. Start all services
docker-compose up -d

# 3. Check status
docker-compose ps

# 4. View logs
docker-compose logs -f

# 5. Stop everything
docker-compose down

# 6. Stop and remove data
docker-compose down -v
```

## Stack Details

### 🟢 MERN Stack
Full JavaScript stack for web applications.
- **Frontend:** React (port 3000)
- **Backend:** Express/Node.js (port 5000)
- **Database:** MongoDB (port 27017)

### 🟣 WordPress
Quick WordPress setup with admin panel.
- **WordPress:** http://localhost:8080
- **phpMyAdmin:** http://localhost:8081

### 🔵 Nginx Reverse Proxy
Production-like setup with load balancing.
- **Access:** http://localhost (Nginx proxies to API)
- **Database:** PostgreSQL
- **Cache:** Redis

### 📊 Monitoring
Full observability stack for Docker containers.
- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090
- **cAdvisor:** http://localhost:8080

---

*Created by [Krishna Yada](https://github.com/yadakrishna245)*
