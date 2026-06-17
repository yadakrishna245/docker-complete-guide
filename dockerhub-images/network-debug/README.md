# 🌐 Network Debug

Lightweight (~20MB) network troubleshooting container for Docker and Kubernetes.

## Tools Included
curl, wget, dig, nslookup, ping, traceroute, mtr, nmap, ncat, tcpdump, iperf3, openssl, strace, lsof

## Usage

```bash
# Debug from host
docker run -it --rm krishna8688/network-debug

# Debug inside a container's network
docker run -it --rm --network container:myapp krishna8688/network-debug

# Debug a Docker network
docker run -it --rm --network mynetwork krishna8688/network-debug

# K8s debug pod
kubectl run debug --image=krishna8688/network-debug -it --rm -- bash
```

## Common Commands Inside

```bash
# DNS lookup
dig myservice.default.svc.cluster.local

# Test TCP port
ncat -zv mydb 5432

# Trace route
mtr google.com

# Capture traffic
tcpdump -i eth0 port 80
```

## Author
[Krishna Yada](https://github.com/yadakrishna245)
