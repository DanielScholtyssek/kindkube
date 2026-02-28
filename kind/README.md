# Kind Cluster Setup for ArgoCD

## File Descriptor Limits Issue

When running ArgoCD in Kind clusters, you may encounter "too many open files" errors. This is because the default file descriptor limits are too low for ArgoCD's repo-server.

## Solution Options

### ✅ Option 1 (Best): Increase limits in Podman machine

If you're using Podman machine:

1. SSH into your Podman machine:
```bash
podman machine ssh
```

2. Inside the VM, check current limits:
```bash
ulimit -n
cat /proc/sys/fs/file-max
```

3. Set system-wide limits:
```bash
sudo sysctl -w fs.file-max=2097152
sudo sysctl -w fs.inotify.max_user_watches=524288
sudo sysctl -w fs.inotify.max_user_instances=512
echo 'fs.file-max = 2097152' | sudo tee -a /etc/sysctl.conf
echo 'fs.inotify.max_user_watches = 524288' | sudo tee -a /etc/sysctl.conf
echo 'fs.inotify.max_user_instances = 512' | sudo tee -a /etc/sysctl.conf
```

4. Set user process limits:
```bash
echo '* soft nofile 1048576' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 1048576' | sudo tee -a /etc/security/limits.conf
echo 'root soft nofile 1048576' | sudo tee -a /etc/security/limits.conf
echo 'root hard nofile 1048576' | sudo tee -a /etc/security/limits.conf
```

5. Set systemd limits (important!):
```bash
sudo mkdir -p /etc/systemd/system.conf.d
echo '[Manager]' | sudo tee /etc/systemd/system.conf.d/limits.conf
echo 'DefaultLimitNOFILE=1048576' | sudo tee -a /etc/systemd/system.conf.d/limits.conf
```

6. Restart the Podman machine:
```bash
exit
podman machine stop
podman machine start
```

7. Recreate your Kind cluster:
```bash
kind delete cluster
kind create cluster --config kind/kind-config.yaml
```

### Option 2: Use provided Kind config

Use the `kind-config.yaml` in this directory which includes:
- Increased kubelet max-open-files limits
- Mounts for host system limits
- Proper port mappings for services