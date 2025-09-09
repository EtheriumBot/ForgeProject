#!/usr/bin/env bash
set -e

echo "🔧 Installing Xpra + LXDE..."

# Update system
sudo apt-get update
sudo apt-get install -y \
  xpra lxde-core lxterminal \
  openjdk-17-jdk git

# Kill old xpra sessions
xpra stop :100 || true

# Free up port 8080 if something is using it
echo "🔧 Checking port 8080..."
PID=$(lsof -ti:8080 || true)
if [ -n "$PID" ]; then
  echo "⚠️ Port 8080 is busy (PID: $PID), killing it..."
  kill -9 $PID
fi

# Start Xpra with web client on 8080
echo "🖥️ Starting Xpra..."
xpra start :100 \
    --start=lxsession \
    --bind-tcp=0.0.0.0:8080 \
    --html=on \
    --daemon=no &

# Auto-launch Minecraft in background
echo "🎮 Launching Minecraft client..."
(
  sleep 10
  cd Forge-Project-1.20.X || true
  chmod +x gradlew
  DISPLAY=:100 ./gradlew runClient || echo "⚠️ Failed to run client."
) &

echo ""
echo "✅ Xpra is running!"
echo "👉 In Codespaces, expose port 8080 (TCP)."
echo "👉 Open it in your browser — it should show an LXDE desktop."
