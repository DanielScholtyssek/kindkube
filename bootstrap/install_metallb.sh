#!/bin/bash

set -e

# Install metallb
# see what changes would be made, returns nonzero returncode if different
echo "Checking what changes would be made to kube-proxy..."
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system || true



# actually apply the changes, returns nonzero returncode on errors only
echo "About to apply kube-proxy configuration changes to enable strictARP:"
echo "This will modify the kube-proxy configmap in the kube-system namespace."
echo "Then install MetalLB from the official manifest."
echo ""
read -p "Do you want to apply these changes? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl get configmap kube-proxy -n kube-system -o yaml | \
    sed -e "s/strictARP: false/strictARP: true/" | \
    kubectl apply -f - -n kube-system
    
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml
else
    echo "Changes cancelled."
    exit 1
fi