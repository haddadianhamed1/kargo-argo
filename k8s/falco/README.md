# Falco Security Monitoring

This directory contains the complete Falco security monitoring setup for the Kargo ArgoCD project.

## Overview

Falco is a runtime security tool that detects unexpected behavior in Kubernetes clusters. This setup includes:

- **Falco**: Main security monitoring agents (DaemonSet)
- **Falcosidekick**: Event processing and forwarding
- **Falcosidekick UI**: Web dashboard for viewing security events
- **Redis**: Storage backend for the UI
- **Istio Integration**: External access via ingress

## Installation

### Development Environment
```bash
cd k8s/falco
./install-falco.sh dev
```

### Staging Environment
```bash
cd k8s/falco
./install-falco.sh stg
```

## Access

### Web UI Access
- **Development**: https://falco-dev.hamedstock.com
- **Staging**: https://falco-stg.hamedstock.com
- **Port-forward**: `kubectl port-forward -n falco svc/falco-falcosidekick-ui 2802:2802`

### Login Credentials
- **Username**: `admin`
- **Password**: `admin`

## Testing Falco Events

To verify Falco is working and generating security alerts, run these test commands:

### Basic Container Security Test
```bash
# Creates a test pod that triggers multiple security events
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh -c "whoami; ls /etc; sleep 2"
```

### File System Access Test
```bash
# Test file system access monitoring
kubectl run fs-test --image=alpine --rm -it --restart=Never -- sh -c "ls /; cat /etc/passwd | head -3"
```

### Network Activity Test
```bash
# Test network monitoring (triggers connection events)
kubectl run net-test --image=curlimages/curl --rm -it --restart=Never -- curl -s https://httpbin.org/get
```

### Process Execution Test
```bash
# Test process monitoring
kubectl run proc-test --image=ubuntu --rm -it --restart=Never -- sh -c "ps aux; uname -a"
```

## Expected Security Events

These test commands typically trigger the following Falco rules:

- **Contact K8S API Server From Container** - API server connections
- **Read sensitive file trusted after startup** - Reading `/etc/passwd`
- **Launch Privileged Container** - If running with elevated privileges
- **Terminal shell in container** - Interactive shell access
- **Outbound or Inbound Traffic not to Authorized Server Process** - External network connections

## Monitoring and Troubleshooting

### Check Falco Status
```bash
# Check all Falco components
kubectl get pods -n falco

# Check Falco sensor logs
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco

# Check falcosidekick logs (event processing)
kubectl logs -n falco -l app.kubernetes.io/name=falcosidekick

# Check WebUI logs
kubectl logs -n falco -l app.kubernetes.io/component=ui
```

### Check Istio Integration
```bash
# Check Gateway and VirtualService
kubectl get gateway,virtualservice -n falco

# Check Istio ingress
kubectl get svc -n istio-system istio-ingressgateway
```

### Restart Components
```bash
# Restart WebUI if events not showing
kubectl delete pods -n falco -l app.kubernetes.io/component=ui

# Restart falcosidekick
kubectl delete pods -n falco -l app.kubernetes.io/name=falcosidekick

# Restart Falco sensors
kubectl delete pods -n falco -l app.kubernetes.io/name=falco
```

## Configuration Files

```
k8s/falco/
├── install-falco.sh              # Installation script
├── values.yaml                   # Base Helm values
├── overlays/
│   ├── dev/
│   │   ├── values.yaml           # Dev-specific configuration
│   │   ├── gateway.yaml          # Istio Gateway for dev
│   │   └── virtualservice.yaml   # Istio VirtualService for dev
│   └── stg/
│       ├── values.yaml           # Staging configuration
│       ├── gateway.yaml          # Istio Gateway for staging
│       └── virtualservice.yaml   # Istio VirtualService for staging
└── README.md                     # This file
```

## Features

- ✅ **Real-time Security Monitoring**: Detects suspicious container behavior
- ✅ **Web Dashboard**: User-friendly interface for viewing alerts
- ✅ **Event Storage**: Persistent Redis backend for event history
- ✅ **External Access**: Accessible via Istio ingress with SSL
- ✅ **Environment Separation**: Separate dev/staging configurations
- ✅ **Debug Mode**: Enhanced logging in development environment

## Security Events Coverage

Falco monitors and alerts on:

- File system access patterns
- Network connections from containers
- Process execution in containers
- Privileged operations
- Kubernetes API interactions
- Suspicious container behaviors
- Configuration changes

## Notes

- Falco runs as a DaemonSet on each node for comprehensive monitoring
- Some Falco pods may be pending due to node affinity constraints
- At least 2 running Falco pods provide good cluster coverage
- Events are processed in real-time and stored in Redis
- The WebUI provides search, filtering, and timeline views
