# Docker Monitoring Guide

[← Back to README](./README.md) | [Security Guide](./docker-security.md) | [Swarm Guide](./docker-swarm.md) | [Troubleshooting](./docker-troubleshooting.md) | [Docker vs Kubernetes](./docker-vs-kubernetes.md)

---

## Table of Contents

- [Docker Stats Command](#docker-stats-command)
- [Prometheus + Grafana + cAdvisor Stack](#prometheus--grafana--cadvisor-stack)
- [Key Metrics to Monitor](#key-metrics-to-monitor)
- [Log Management](#log-management)
- [Alerting Basics](#alerting-basics)
- [Health Check Patterns](#health-check-patterns)
- [Quick Reference](#quick-reference)

---

## Docker Stats Command

The built-in `docker stats` command provides real-time resource usage for containers.

```bash
# All running containers
docker stats

# Specific containers
docker stats container1 container2

# One-shot (no streaming)
docker stats --no-stream

# Custom format
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# JSON output for scripting
docker stats --no-stream --format '{{json .}}'
```

### Format Placeholders

| Placeholder | Description |
|-------------|-------------|
| `{{.Name}}` | Container name |
| `{{.CPUPerc}}` | CPU percentage |
| `{{.MemUsage}}` | Memory usage / limit |
| `{{.MemPerc}}` | Memory percentage |
| `{{.NetIO}}` | Network I/O |
| `{{.BlockIO}}` | Block I/O |
| `{{.PIDs}}` | Number of PIDs |

---

## Prometheus + Grafana + cAdvisor Stack

A production-ready monitoring stack using Docker Compose:

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=15d'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
```

### Prometheus Configuration

```yaml
# prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'docker'
    static_configs:
      - targets: ['host.docker.internal:9323']
```

### Enable Docker Metrics Endpoint

Add to `/etc/docker/daemon.json`:

```json
{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}
```

---

## Key Metrics to Monitor

### CPU Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `container_cpu_usage_seconds_total` | cAdvisor | Total CPU time consumed |
| `container_cpu_system_seconds_total` | cAdvisor | System CPU time |
| `container_cpu_user_seconds_total` | cAdvisor | User CPU time |
| CPU throttling | cAdvisor | `container_cpu_cfs_throttled_periods_total` |

### Memory Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `container_memory_usage_bytes` | cAdvisor | Current memory usage |
| `container_memory_max_usage_bytes` | cAdvisor | Peak memory usage |
| `container_memory_cache` | cAdvisor | Page cache memory |
| `container_memory_rss` | cAdvisor | RSS memory |

### Network Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `container_network_receive_bytes_total` | cAdvisor | Bytes received |
| `container_network_transmit_bytes_total` | cAdvisor | Bytes transmitted |
| `container_network_receive_errors_total` | cAdvisor | Receive errors |
| `container_network_transmit_errors_total` | cAdvisor | Transmit errors |

### Disk I/O Metrics

| Metric | Source | Description |
|--------|--------|-------------|
| `container_fs_reads_total` | cAdvisor | Disk reads |
| `container_fs_writes_total` | cAdvisor | Disk writes |
| `container_fs_usage_bytes` | cAdvisor | Filesystem usage |
| `container_fs_limit_bytes` | cAdvisor | Filesystem limit |

---

## Log Management

### JSON File Driver (Default)

```bash
# Configure logging driver per container
docker run -d \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  myapp

# View logs
docker logs --tail 100 -f container_name

# Global config in /etc/docker/daemon.json
```

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

### ELK Stack Basics

```yaml
# docker-compose.elk.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.12.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - es_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.12.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5044:5044"
      - "12201:12201/udp"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.12.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  es_data:
```

Send Docker logs to Logstash using the GELF driver:

```bash
docker run -d \
  --log-driver gelf \
  --log-opt gelf-address=udp://localhost:12201 \
  myapp
```

---

## Alerting Basics

### Prometheus Alerting Rules

```yaml
# prometheus/alert.rules.yml
groups:
  - name: container_alerts
    rules:
      - alert: ContainerHighCPU
        expr: rate(container_cpu_usage_seconds_total[5m]) * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Container {{ $labels.name }} high CPU usage"

      - alert: ContainerHighMemory
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Container {{ $labels.name }} memory usage above 85%"

      - alert: ContainerDown
        expr: absent(container_last_seen{name=~".+"})
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container {{ $labels.name }} is down"

      - alert: HighDiskUsage
        expr: container_fs_usage_bytes / container_fs_limit_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Container {{ $labels.name }} disk usage above 90%"
```

### Alertmanager Configuration

```yaml
# alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m

route:
  receiver: 'slack-notifications'
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#docker-alerts'
        send_resolved: true
```

---

## Health Check Patterns

### Dockerfile HEALTHCHECK

```dockerfile
# HTTP health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# TCP health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD nc -z localhost 5432 || exit 1

# Custom script
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh
```

### Docker Compose Health Checks

```yaml
services:
  web:
    image: myapp
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:16
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Inspecting Health Status

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' container_name

# Health check logs
docker inspect --format='{{json .State.Health}}' container_name | jq
```

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `docker stats` | Real-time resource usage for all containers |
| `docker stats --no-stream` | One-shot stats output |
| `docker logs -f <container>` | Follow container logs |
| `docker logs --since 1h <container>` | Logs from last hour |
| `docker inspect <container>` | Full container details |
| `docker system df` | Disk usage summary |
| `docker system events` | Real-time Docker events |
| `docker top <container>` | Running processes in container |
| `docker inspect --format='{{.State.Health.Status}}' <c>` | Health status |
| `docker system info` | System-wide information |
| `docker container ls --filter health=unhealthy` | List unhealthy containers |
| `docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}'` | Formatted stats |

---

> **Tip:** Start with `docker stats` for quick insights, then scale to the full Prometheus + Grafana stack for production workloads.
