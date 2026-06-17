# Docker vs Kubernetes

[← Back to README](./README.md) | [Monitoring Guide](./docker-monitoring.md) | [Security Guide](./docker-security.md) | [Swarm Guide](./docker-swarm.md) | [Troubleshooting](./docker-troubleshooting.md)

---

## Table of Contents

- [When to Use Docker Alone vs Kubernetes](#when-to-use-docker-alone-vs-kubernetes)
- [Feature Comparison](#feature-comparison)
- [Docker Compose vs Kubernetes Manifests](#docker-compose-vs-kubernetes-manifests)
- [Docker Swarm vs Kubernetes](#docker-swarm-vs-kubernetes)
- [Migration Path: Docker → Kubernetes](#migration-path-docker--kubernetes)
- [Decision Flowchart](#decision-flowchart)

---

## When to Use Docker Alone vs Kubernetes

### Use Docker (Compose) When:

- Small team (1–5 developers)
- Single host or few servers
- Simple applications (< 10 services)
- Development and testing environments
- Budget constraints (no dedicated ops team)
- Quick prototyping and MVPs
- CI/CD build environments

### Use Kubernetes When:

- Large-scale production deployments
- Multi-team, multi-service architectures (10+ services)
- Need auto-scaling based on traffic/load
- High availability is critical (99.9%+ uptime)
- Multi-cloud or hybrid-cloud deployments
- Complex networking and service mesh requirements
- Rolling updates with zero downtime are mandatory
- You have dedicated DevOps/platform engineering team

---

## Feature Comparison

| Feature | Docker (Compose) | Kubernetes |
|---------|------------------|------------|
| **Orchestration** | Basic (single host) | Advanced (multi-node cluster) |
| **Scaling** | Manual (`docker-compose up --scale`) | Auto-scaling (HPA, VPA, Cluster Autoscaler) |
| **Networking** | Bridge, overlay (Swarm) | CNI plugins (Calico, Flannel, Cilium) |
| **Service Discovery** | DNS-based (compose network) | Built-in DNS, Services, Ingress |
| **Load Balancing** | Basic (round-robin) | Advanced (L4/L7, Ingress controllers) |
| **Storage** | Volumes, bind mounts | PersistentVolumes, StorageClasses, CSI |
| **Deployment** | `docker-compose up` | Rolling updates, Blue/Green, Canary |
| **Self-Healing** | Restart policies | Pod rescheduling, liveness/readiness probes |
| **Secret Management** | Docker secrets (Swarm), env vars | Kubernetes Secrets, external vaults |
| **Config Management** | Environment files, configs | ConfigMaps, Secrets |
| **RBAC** | Limited | Full RBAC with namespaces |
| **Multi-tenancy** | Not supported | Namespaces, resource quotas |
| **Complexity** | Low | High |
| **Learning Curve** | Days | Weeks to months |
| **Resource Overhead** | Minimal | Significant (control plane) |

---

## Docker Compose vs Kubernetes Manifests

### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: myapp:1.0
    ports:
      - "80:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=db
    depends_on:
      - db
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure

  db:
    image: postgres:16
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=secret

volumes:
  db_data:
```

### Kubernetes Equivalent

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: myapp:1.0
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: "production"
            - name: DB_HOST
              value: "db"
---
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 3000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
        - name: db
          image: postgres:16
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password
          volumeMounts:
            - name: db-storage
              mountPath: /var/lib/postgresql/data
      volumes:
        - name: db-storage
          persistentVolumeClaim:
            claimName: db-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: db
spec:
  selector:
    app: db
  ports:
    - port: 5432
```

### Key Differences

| Aspect | Docker Compose | Kubernetes |
|--------|---------------|------------|
| Lines of YAML | ~25 | ~80+ |
| Files needed | 1 | Multiple (or 1 large file) |
| Networking | Automatic between services | Explicit Service objects |
| Storage | Simple volume declaration | PVC + PV + StorageClass |
| Secrets | Env vars or `.env` file | Secret objects (base64) |
| Scaling | `--scale web=3` | `kubectl scale` or HPA |

---

## Docker Swarm vs Kubernetes

| Feature | Docker Swarm | Kubernetes |
|---------|-------------|------------|
| **Setup** | `docker swarm init` (minutes) | Complex (kubeadm, managed services) |
| **Learning Curve** | Easy (Docker CLI) | Steep (new concepts, tools) |
| **Scaling** | Manual | Auto-scaling (HPA) |
| **Rolling Updates** | Supported | Advanced (canary, blue/green) |
| **Networking** | Overlay networks | CNI plugins (more flexible) |
| **Load Balancing** | Built-in (routing mesh) | Ingress controllers |
| **Service Discovery** | Built-in DNS | Built-in DNS + more options |
| **Storage** | Docker volumes | CSI, dynamic provisioning |
| **Monitoring** | Basic | Rich ecosystem (Prometheus) |
| **Community** | Smaller, declining | Massive, growing |
| **Production Adoption** | Limited | Industry standard |
| **Managed Offerings** | Few | EKS, AKS, GKE, etc. |

### When to Choose Swarm

- Already using Docker Compose
- Need simple orchestration fast
- Small cluster (< 10 nodes)
- Team knows Docker but not Kubernetes

### When to Choose Kubernetes

- Large-scale deployments
- Need auto-scaling
- Multi-cloud strategy
- Rich ecosystem integrations needed
- Long-term investment in platform

---

## Migration Path: Docker → Kubernetes

### Step 1: Containerize (Already Done)

Ensure all services have proper Dockerfiles with:
- Multi-stage builds
- Non-root users
- Health checks
- Proper signal handling

### Step 2: Use Docker Compose in Production

Validate your services work together with:
- Named networks
- Volume management
- Environment configuration
- Service dependencies

### Step 3: Convert to Kubernetes Manifests

Use tools to assist the migration:

```bash
# Kompose - convert docker-compose to k8s manifests
kompose convert -f docker-compose.yml

# Review and adjust generated manifests
ls *.yaml
```

### Step 4: Add Kubernetes-Native Features

- Replace `depends_on` with readiness probes
- Add resource requests and limits
- Configure Horizontal Pod Autoscaler
- Set up Ingress for external access
- Use ConfigMaps and Secrets

### Step 5: Set Up CI/CD for Kubernetes

- Build images in CI pipeline
- Push to container registry
- Apply manifests with `kubectl apply` or Helm
- Use GitOps (ArgoCD, Flux)

### Migration Checklist

- [ ] All services containerized with production Dockerfiles
- [ ] Health checks defined for every service
- [ ] Environment config externalized (not baked into images)
- [ ] Stateless services separated from stateful ones
- [ ] Persistent storage needs identified
- [ ] Networking requirements documented
- [ ] Secrets management strategy chosen
- [ ] CI/CD pipeline updated
- [ ] Monitoring and logging adapted
- [ ] Team trained on Kubernetes basics

---

## Decision Flowchart

```
START: Do you need container orchestration?
│
├── NO → Use Docker (single container or docker run)
│
└── YES → How many services?
    │
    ├── < 5 services, single host
    │   └── Use Docker Compose
    │
    └── 5+ services OR multiple hosts
        │
        ├── Need auto-scaling?
        │   ├── NO → Small team? Budget constrained?
        │   │   ├── YES → Docker Swarm
        │   │   └── NO → Kubernetes
        │   └── YES → Kubernetes
        │
        ├── High availability critical?
        │   ├── YES → Kubernetes
        │   └── NO → Docker Swarm or Compose
        │
        └── Multi-cloud / hybrid?
            ├── YES → Kubernetes
            └── NO → Evaluate team expertise
                ├── Docker-only team → Start with Swarm, plan K8s migration
                └── K8s experience → Kubernetes
```

### Quick Decision Summary

| Scenario | Recommendation |
|----------|---------------|
| Solo dev, side project | Docker Compose |
| Small startup, < 5 services | Docker Compose |
| Growing startup, 5-15 services | Docker Swarm → Kubernetes |
| Enterprise, 15+ services | Kubernetes |
| Need auto-scaling | Kubernetes |
| Multi-cloud required | Kubernetes |
| Quick POC / demo | Docker Compose |
| CI/CD environments | Docker Compose |

---

> **Bottom line:** Docker is for building and running containers. Kubernetes is for orchestrating containers at scale. Most teams start with Docker Compose and graduate to Kubernetes as complexity grows.
