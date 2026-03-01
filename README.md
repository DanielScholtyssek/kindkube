# KindKube - Local Kubernetes Development with ArgoCD, MetalLB & Contour

A complete local Kubernetes development environment using Kind with ArgoCD for GitOps, MetalLB for load balancing, and Contour for ingress/Gateway API. This setup is specifically designed for **Windows + WSL2 + Podman** environments.

## 🏗️ Architecture

This project runs on:
- **Host**: Windows 11/10
- **Virtualization**: WSL2 (Windows Subsystem for Linux)
- **Container Runtime**: Podman Machine (QEMU-based VM)
- **Kubernetes**: Kind (Kubernetes in Docker)
- **Applications**: ArgoCD + MetalLB + Contour

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

# 5. Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
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
│   ├── argocd/
│   │   ├── contour-project.yaml           # Contour project
│   │   ├── contour-applicationset.yaml    # Contour deployment (provisioner + manifests)
│   │   ├── metallb-project.yaml           # MetalLB project
│   │   ├── metallb-helm-application.yaml   # MetalLB Helm deployment
│   │   ├── metallb-applicationset.yaml    # MetalLB manifests deployment
│   │   └── kindkube-apps-applicationset.yaml # User apps deployment
│   ├── contour/
│   │   ├── provisioner/
│   │   │   └── contour-gateway-provisioner.yaml  # Gateway provisioner
│   │   └── manifests/
│   │       ├── contour-gatewayclass.yaml           # GatewayClass
│   │       ├── contour-gateway.yaml                # Gateway resource
│   │       └── envoy-service-patch.yaml             # MetalLB service patch
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

## 📚 Documentation

### Official Resources
- **[Kind Documentation](https://kind.sigs.k8s.io/)** - Container-based local Kubernetes
- **[ArgoCD Documentation](https://argo-cd.readthedocs.io/)** - Declarative GitOps CD
- **[MetalLB Documentation](https://metallb.universe.tf/)** - Load balancer for bare metal
- **[Contour Documentation](https://projectcontour.io/)** - Ingress controller with Gateway API support

### Project-Specific Documentation
- `kind/README.md` - Detailed Kind setup and troubleshooting
- `bootstrap/` - Installation scripts with explanations
- `infra/contour/` - Contour Gateway API setup
- `infra/metallb/` - MetalLB configuration examples

## 🎯 ArgoCD Applications

### Deployment Order (Sync Waves)

**Wave 0** - Foundation:
- `kindkube-infra` - Infrastructure components (projects, applications)

**Wave 1** - MetalLB:
- `metallb-helm` - MetalLB installation via Helm chart

**Wave 2** - Contour Provisioner:
- `contour-provisioner` - Gateway provisioner with CRDs

**Wave 3** - Contour & MetalLB Configuration:
- `contour-manifests` - Gateway resources and Envoy service patch
- `metallb-manifests` - MetalLB IP pool and L2 advertisement

**Wave 5** - Applications:
- `kindkube-apps` - Your applications

### What Each Application Does

- **`kindkube-infra`**: Deploys infrastructure components from `infra/argocd/`
- **`metallb-helm`**: Deploys MetalLB using official Helm chart
- **`metallb-manifests`**: Deploys MetalLB IP pool and L2 advertisement
- **`contour-provisioner`**: Deploys Contour Gateway provisioner with all CRDs
- **`contour-manifests`**: Deploys GatewayClass, Gateway, and Envoy service patch
- **`kindkube-apps`**: Deploys your applications from `apps/`

## 🌐 Contour Gateway API Setup

### Architecture

The Contour setup uses **dynamic provisioning** with the Gateway API:

1. **Gateway Provisioner** (Wave 2): Installs Contour and Gateway API CRDs
2. **Gateway Resources** (Wave 3): Creates GatewayClass and Gateway
3. **Envoy Service** (Wave 3): LoadBalancer with MetalLB IP assignment

### Access Points

**External Access**: `http://10.89.0.200` (MetalLB assigned IP)
**Internal Access**: Via Gateway API HTTPRoutes

### MetalLB Integration

The Envoy service is automatically patched to:
- **Type**: LoadBalancer
- **IP Assignment**: `10.89.0.200` from `default-pool`
- **Annotations**: MetalLB-specific configuration
- **Labels**: IP sharing enabled

## 🛠️ Development Workflow

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

### Adding Gateway Routes

1. **Create HTTPRoute** in your application namespace:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-app
  namespace: default
spec:
  parentRefs:
  - name: contour
    namespace: projectcontour
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: my-app
      port: 80
```

2. **Deploy via GitOps** - ArgoCD handles the rest

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
- Check if MetalLB Helm chart is deployed (wave 1)
- Ensure strictARP is enabled in kube-proxy

**Contour Gateway Not Working**
- Verify Gateway provisioner is deployed (wave 2)
- Check Gateway resources are created (wave 3)
- Ensure Envoy service has LoadBalancer IP
- Test with `curl http://10.89.0.200`

**CRD OutOfSync Issues**
- Gateway provisioner modifies CRDs after deployment
- ArgoCD shows OutOfSync for `preserveUnknownFields` field
- **Solution**: Configured ignore rules in contour-provisioner application
- **Reference**: See Debug section below

### Debug Resources

**ArgoCD CRD Sync Issues**:
- **Documentation**: https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/2.14-3.0/#removing-default-ignores-of-preserveunknownfields-for-crd
- **Issue**: `spec.preserveUnknownFields` deprecated in favor of `x-kubernetes-preserve-unknown-fields`
- **Solution**: Added ignoreDifferences to contour-provisioner application

**Manual Sync Commands**:
```bash
# Force sync specific application
kubectl patch application <app-name> -n argocd -p '{"operation":{"sync":{"revision":"HEAD"}}}' --type=merge

# Check application status
kubectl get application <app-name> -n argocd -o yaml | grep -A 10 "status:"
```

**Contour Debugging**:
```bash
# Check Gateway resources
kubectl get gateway -n projectcontour
kubectl get gatewayclass

# Check Envoy service
kubectl get svc envoy-contour -n projectcontour -o yaml

# Test Gateway access
curl -v http://10.89.0.200
```

## 🔄 Development Workflow

1. **Infrastructure Changes**: Add YAML files to `infra/`
2. **MetalLB Configuration**: Update files in `infra/metallb/manifests/`
3. **Contour Configuration**: Update Gateway resources in `infra/contour/manifests/`
4. **Application Development**: Add manifests to `apps/`
5. **GitOps**: Commit and push - ArgoCD handles the rest

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
- [Contour GitHub](https://github.com/projectcontour/contour)
