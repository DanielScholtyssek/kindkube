#!/bin/bash

set -e

# Install bootstrap components
echo "Installing bootstrap components..."

# Install MetalLB
echo "Installing MetalLB..."

# Add Helm repository (for local reference, ArgoCD will use the repo directly)
echo "Adding MetalLB Helm repository..."
helm repo add metallb https://metallb.github.io/metallb
helm repo update

# Enable strictARP in kube-proxy (required for MetalLB)
echo "Enabling strictARP in kube-proxy..."
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# Install ArgoCD
echo "Installing ArgoCD..."
./argocd/install_argocd.sh

# Setup ArgoCD GitOps for this repository
echo "Setting up ArgoCD GitOps..."
kubectl apply -f argocd/infra-application.yaml
kubectl apply -f ../infra/namespace-application.yaml
kubectl apply -f ../infra/metallb-helm-application.yaml
kubectl apply -f ../infra/metallb-manifests.yaml
kubectl apply -f argocd/apps-application.yaml

echo "Bootstrap components installed successfully!"
