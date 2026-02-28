# KindKube - Local Kubernetes Development with ArgoCD and MetalLB

A complete local Kubernetes development environment using Kind with ArgoCD for GitOps and MetalLB for load balancing.

## 🚀 Quick Start

```bash
# 1. Setup Podman machine limits (required for ArgoCD/MetalLB)
podman machine ssh
# Follow the steps in kind/README.md Option 1

# 2. Create cluster and install components
kind create cluster --config kind/kind-config.yaml
./install_bootstrap.sh

# 3. Configure MetalLB IP pool
kubectl apply -f config/metallb/ip-pool.yaml
kubectl apply -f config/metallb/l2-advertisement.yaml
```

## 📁 Project Structure

```
kindkube/
├── kind/                    # Kind cluster configuration
│   ├── kind-config.yaml     # Cluster config with file limits
│   └── README.md           # Detailed setup instructions
├── bootstrap/              # Installation scripts
│   ├── install_bootstrap.sh # Main installer
│   ├── install_argocd.sh   # ArgoCD installer
│   └── install_metallb.sh  # MetalLB installer
├── config/                 # Application configurations
│   └── metallb/           # MetalLB IP pool and L2 advertisement
└── apps/                  # Application manifests (for future use)
```

## 🔧 Components

### ArgoCD
- **Version**: Latest stable
- **Namespace**: `argocd`
- **Purpose**: GitOps continuous delivery
- **Configuration**: Default with GPG disabled for local development

### MetalLB
- **Version**: v0.15.3
- **Namespace**: `metallb-system`
- **IP Range**: `192.168.178.100-192.168.178.120`
- **Mode**: Layer 2 advertisement

### Kind
- **Version**: Latest
- **Nodes**: 1 control-plane + 3 workers
- **File Limits**: Increased for ArgoCD/MetalLB compatibility

## ⚙️ Configuration

### File Descriptor Limits
This project addresses the "too many open files" issue common with ArgoCD and MetalLB in Kind clusters. See `kind/README.md` for detailed solutions.

### MetalLB IP Pool
The default IP pool is configured for `192.168.178.100-192.168.178.120`. Modify `config/metallb/ip-pool.yaml` to change this range.

### ArgoCD Access
```bash
# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 📚 Documentation

### Official Resources
- **[Kind Documentation](https://kind.sigs.k8s.io/)** - Container-based local Kubernetes
- **[ArgoCD Documentation](https://argo-cd.readthedocs.io/)** - Declarative GitOps CD
- **[MetalLB Documentation](https://metallb.universe.tf/)** - Load balancer for bare metal

### Project-Specific Documentation
- `kind/README.md` - Detailed Kind setup and troubleshooting
- `bootstrap/` - Installation scripts with explanations
- `config/metallb/` - MetalLB configuration examples

## 🛠️ Development Workflow

1. **Cluster Setup**: Configure Kind with proper limits
2. **Install Components**: Use bootstrap scripts for ArgoCD/MetalLB
3. **Deploy Applications**: Add manifests to `apps/` directory
4. **GitOps**: Configure ArgoCD to sync from your Git repository

## 🔍 Troubleshooting

### Common Issues

**"too many open files" Error**
- Solution: Configure Podman machine limits (see `kind/README.md`)
- **Reference**: https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
- Cause: Default file limits too low for ArgoCD/MetalLB

### Verification Commands
```bash
# Check pod status
kubectl get pods -n argocd
kubectl get pods -n metallb-system

# Check logs
kubectl logs -n argocd deployment/argocd-repo-server
kubectl logs -n metallb-system deployment/controller

# Test MetalLB
kubectl expose deployment argocd-server -n argocd --type=LoadBalancer --port=8080
```

## 🔗 Links

- [Kind GitHub](https://github.com/kubernetes-sigs/kind)
- [ArgoCD GitHub](https://github.com/argoproj/argo-cd)
- [MetalLB GitHub](https://github.com/metallb/metallb)
