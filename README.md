# KindKube - Local Kubernetes Development with ArgoCD and MetalLB

A complete local Kubernetes development environment using Kind with ArgoCD for GitOps and MetalLB for load balancing. This setup is specifically designed for **Windows + WSL2 + Podman** environments.

## 🏗️ Architecture

This project runs on:
- **Host**: Windows 11/10
- **Virtualization**: WSL2 (Windows Subsystem for Linux)
- **Container Runtime**: Podman Machine (QEMU-based VM)
- **Kubernetes**: Kind (Kubernetes in Docker)
- **Applications**: ArgoCD + MetalLB

The stack addresses file descriptor limitations common in nested virtualization environments.

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/DanielScholtyssek/kindkube.git
cd kindkube

# 2. Configure Podman machine limits (see kind/README.md)
# 3. Run the bootstrap script
./bootstrap/install_bootstrap.sh

# 4. Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 📁 Project Structure

```
kindkube/
├── bootstrap/
│   ├── install_bootstrap.sh      # Main installer
│   └── argocd/
│       ├── infra-application.yaml      # Infrastructure GitOps
│       ├── apps-application.yaml       # User applications GitOps
│       └── install_argocd.sh           # ArgoCD installer
├── infra/
│   ├── metallb-helm-application.yaml     # MetalLB Helm GitOps
│   ├── metallb-manifests.yaml           # MetalLB manifests GitOps
│   └── metallb/
│       ├── manifests/                   # MetalLB configurations
│       └── values/
│           └── helm-values.yaml        # Helm chart values
├── apps/                               # Your applications
├── kind/
│   ├── kind-config.yaml                # Kind cluster configuration
│   └── README.md                       # Kind setup guide
└── README.md                          # This file
```
# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

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
3. **Setup GitOps**: Configure ArgoCD to deploy from your repository
4. **Deploy Applications**: Add manifests to `apps/` directory and push to GitHub

### GitOps Setup

1. **Apply the ArgoCD Applications**:
```bash
./bootstrap/install_bootstrap.sh
```

2. **Add applications to the `apps/` directory**:
```bash
# Add your Kubernetes manifests to apps/
git add apps/
git commit -m "Add new application"
git push
```

3. **ArgoCD will automatically deploy** any manifests in the `apps/` directory

## 🎯 ArgoCD Applications

### Deployment Order (Sync Waves)

**Wave 0** - Foundation:
- `metallb-helm` - MetalLB installation via Helm chart
- `kindkube-infra` - Infrastructure components

**Wave 1** - Configuration:
- `metallb-manifests` - MetalLB configuration (IP pool, L2 advertisement)

**Wave 2** - Applications:
- `kindkube-user-apps` - Your applications

### What Each Application Does

- **`kindkube-infra`**: Deploys infrastructure configurations from `infra/`
- **`metallb-helm`**: Deploys MetalLB using official Helm chart
- **`metallb-manifests`**: Deploys MetalLB IP pool and L2 advertisement
- **`kindkube-user-apps`**: Deploys your applications from `apps/`

## 📚 Official Documentation

- **Kind**: https://kind.sigs.k8s.io/
- **ArgoCD**: https://argo-cd.readthedocs.io/
- **MetalLB**: https://metallb.universe.tf/

## 🔍 Troubleshooting

### Common Issues

**"too many open files" Error**
- Solution: Configure Podman machine limits (see `kind/README.md`)
- **Reference**: https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
- Cause: Default file limits too low for ArgoCD/MetalLB

**ArgoCD Applications Not Syncing**
- Check sync wave annotations
- Verify Git repository access
- Ensure proper folder structure

**MetalLB Not Assigning IPs**
- Verify IP pool configuration in `infra/metallb/manifests/`
- Check if MetalLB Helm chart is deployed (wave 0)
- Ensure strictARP is enabled in kube-proxy

## 🔄 Development Workflow

1. **Infrastructure Changes**: Add YAML files to `infra/`
2. **MetalLB Configuration**: Update files in `infra/metallb/manifests/`
3. **Application Development**: Add manifests to `apps/`
4. **GitOps**: Commit and push - ArgoCD handles the rest

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./bootstrap/install_bootstrap.sh`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Links

- [Kind GitHub](https://github.com/kubernetes-sigs/kind)
- [ArgoCD GitHub](https://github.com/argoproj/argo-cd)
- [MetalLB GitHub](https://github.com/metallb/metallb)
