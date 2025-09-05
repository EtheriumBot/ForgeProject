#!/usr/bin/env bash
set -e

echo "🔧 Preparing environment..."

# Update system and install dependencies
sudo apt-get update
sudo apt-get install -y \
  xpra xserver-xorg-video-dummy \
  lxde-core lxterminal openjdk-17-jdk \
  git wget

# Kill old xpra sessions
xpra stop :100 || true

# Start xpra with HTML5 support on port 8080
echo "🖥️ Starting Xpra server on display :100..."
xpra start :100 \
  --start=lxsession \
  --bind-tcp=0.0.0.0:8080 \
  --html=on \
  --daemon=no &

# Give xpra a moment to start
sleep 5

echo ""
echo "✅ Desktop is running with Xpra!"
echo "👉 Open port 8080 in your Codespaces Ports panel (you may also need to set it to Public)."
echo "👉 Then open it in your browser — you’ll get the Xpra web client!"

# Launch Minecraft client inside xpra
echo "🎮 Launching Minecraft client..."
(
  cd Forge-Project-1.20.X || true
  chmod +x gradlew
  DISPLAY=:100 ./gradlew runClient || echo "⚠️ Failed to run client."
) &
