#!/bin/bash

set -e

# Install bootstrap components
echo "Installing bootstrap components..."
./install_metallb.sh
./install_argocd.sh
echo "Bootstrap components installed successfully!"
