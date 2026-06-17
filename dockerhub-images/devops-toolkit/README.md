# 🛠️ DevOps Toolkit

All-in-one DevOps container with every tool you need for CI/CD, cloud ops, and infrastructure management.

## Tools Included

| Tool | Version | Purpose |
|------|---------|---------|
| AWS CLI | v2 | Cloud management |
| Docker CLI | latest | Container operations |
| kubectl | latest | Kubernetes management |
| Helm | v3 | K8s package manager |
| Terraform | 1.7.5 | Infrastructure as Code |
| Ansible | latest | Configuration management |
| Trivy | latest | Security scanning |
| Git, curl, jq, vim, htop, nmap, tcpdump | - | Essential utilities |

## Usage

```bash
# Interactive shell
docker run -it --rm krishna8688/devops-toolkit

# With AWS credentials
docker run -it --rm \
  -v ~/.aws:/root/.aws \
  -v $(pwd):/workspace \
  krishna8688/devops-toolkit

# In CI/CD pipeline
image: krishna8688/devops-toolkit:latest
```

## Image Size
~600MB (includes all tools pre-installed)

## Author
[Krishna Yada](https://github.com/yadakrishna245)
