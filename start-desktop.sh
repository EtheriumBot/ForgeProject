#!/usr/bin/env bash
set -e

echo "🔧 Preparing environment..."

# Update system
sudo apt-get update
sudo apt-get install -y \
  tigervnc-standalone-server tigervnc-common \
  lxde-core lxterminal \
  git python3 python3-pip \
  novnc websockify openjdk-17-jdk

# Kill old sessions
vncserver -kill :1 || true
pkill Xtigervnc || true
pkill -f novnc_proxy || true

# Ensure VNC password
mkdir -p ~/.vnc
if [ ! -f ~/.vnc/passwd ]; then
  echo "codespaces" | vncpasswd -f > ~/.vnc/passwd
  chmod 600 ~/.vnc/passwd
fi

# Install LXDE if missing
sudo apt-get update
sudo apt-get install -y lxde-core lxterminal

# xstartup (minimal working LXDE session)
cat > ~/.vnc/xstartup <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startlxde
EOF
chmod +x ~/.vnc/xstartup

# Install noVNC if missing
if [ ! -d "$HOME/noVNC" ]; then
  git clone https://github.com/novnc/noVNC.git ~/noVNC
  git clone https://github.com/novnc/websockify.git ~/websockify
  ln -s ~/websockify ~/noVNC/utils/websockify
fi

# Start the VNC server
echo "🖥️ Starting VNC..."
vncserver :1 -geometry 1280x720 -depth 24

# Start noVNC proxy
echo "🌐 Starting noVNC..."
nohup ~/noVNC/utils/novnc_proxy \
  --listen 0.0.0.0:8080 \
  --vnc localhost:5901 \
  --web ~/noVNC \
  > /tmp/novnc.log 2>&1 &

# Launch Minecraft in background
echo "🎮 Launching Minecraft client..."
(
  sleep 5
  ls
  cd Forge-Project-1.20.X || true
  chmod +x gradlew
  DISPLAY=:1 ./gradlew runClient || echo "⚠️ Failed to run client."
) &

echo ""
echo "✅ Desktop is running!"
echo "👉 Open port 8080 in your Codespaces Ports panel."
echo "👉 Login with password: codespaces"
