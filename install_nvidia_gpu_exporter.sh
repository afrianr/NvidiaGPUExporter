#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting nvidia_gpu_exporter installation..."

# 1. Dynamically find the download URL for the latest version
echo "Fetching the latest release URL from GitHub..."
# We added 'grep -v "nvml"' and 'head -n 1' to ensure we only get a single URL string
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/utkuozdemir/nvidia_gpu_exporter/releases/latest | grep "browser_download_url" | grep "linux_x86_64.tar.gz" | grep -v "nvml" | cut -d '"' -f 4 | head -n 1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not determine download URL. Check network connectivity."
    exit 1
fi

echo "Downloading from: ${DOWNLOAD_URL}"
cd /tmp
wget -O nvidia_gpu_exporter_latest.tar.gz "${DOWNLOAD_URL}"

echo "Extracting the binary..."
tar -xvzf nvidia_gpu_exporter_latest.tar.gz

# Find the extracted binary directory or file
# The tarball usually extracts a single binary or a folder. Let's find the executable.
EXTRACTED_BIN=$(find . -maxdepth 2 -type f -name "nvidia_gpu_exporter" | head -n 1)

if [ -z "$EXTRACTED_BIN" ]; then
    echo "Error: Could not find extracted binary."
    exit 1
fi

# 2. Install the Binary
echo "Installing binary to /usr/local/bin/..."
mv "$EXTRACTED_BIN" /usr/local/bin/nvidia_gpu_exporter
chmod +x /usr/local/bin/nvidia_gpu_exporter

# Clean up downloaded archive
rm nvidia_gpu_exporter_latest.tar.gz

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
