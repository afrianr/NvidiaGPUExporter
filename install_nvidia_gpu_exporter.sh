#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting nvidia_gpu_exporter installation..."

# 1. Download and Extract the Binary
echo "Downloading the latest nvidia_gpu_exporter release..."
cd /tmp
wget https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/latest/download/nvidia_gpu_exporter_linux_x86_64.tar.gz

echo "Extracting the binary..."
tar -xvzf nvidia_gpu_exporter_linux_x86_64.tar.gz

# 2. Install the Binary
echo "Installing binary to /usr/local/bin/..."
mv nvidia_gpu_exporter /usr/local/bin/
chmod +x /usr/local/bin/nvidia_gpu_exporter

# Clean up downloaded archive
rm nvidia_gpu_exporter_linux_x86_64.tar.gz

# 3. Create the Systemd Service File
echo "Creating systemd service file at /etc/systemd/system/nvidia_gpu_exporter.service..."
cat << 'EOF' > /etc/systemd/system/nvidia_gpu_exporter.service
[Unit]
Description=Nvidia GPU Exporter
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/nvidia_gpu_exporter
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# 4. Enable and Start the Service
echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "Enabling nvidia_gpu_exporter to start on boot..."
systemctl enable nvidia_gpu_exporter

echo "Starting nvidia_gpu_exporter service..."
systemctl start nvidia_gpu_exporter

echo "Installation complete!"
echo "Checking service status..."
systemctl status nvidia_gpu_exporter --no-pager -l
