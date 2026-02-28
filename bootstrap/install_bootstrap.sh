#!/bin/bash

set -e

# Install bootstrap components
echo "Installing bootstrap components..."

# Install MetalLB
echo "Installing MetalLB..."
./metallb/install_metallb.sh

# Install ArgoCD
echo "Installing ArgoCD..."
./argocd/install_argocd.sh

# Setup ArgoCD GitOps for this repository
echo "Setting up ArgoCD GitOps..."
kubectl apply -f argocd/config-application.yaml
kubectl apply -f argocd/apps-application.yaml

echo "Bootstrap components installed successfully!"
