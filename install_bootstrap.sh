#!/bin/bash

set -e

# Install bootstrap components
echo "Installing bootstrap components..."
./bootstrap/install_metallb.sh
./bootstrap/install_argocd.sh
echo "Bootstrap components installed successfully!"
