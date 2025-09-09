#!/usr/bin/env bash
set -e

echo "🔧 Installing Mesa software rendering (llvmpipe) + Xpra..."
sudo apt-get update
sudo apt-get install -y xpra mesa-utils mesa-utils-extra libgl1 libgl1-mesa-dri

# Ensure runtime dir exists for xpra
export XDG_RUNTIME_DIR=$HOME/.xpra-run
mkdir -p $XDG_RUNTIME_DIR

# Kill any old xpra session
xpra stop :100 || true

# Start xpra in background
echo "🖥️ Starting Xpra virtual desktop on port 8080..."
xpra start --bind-tcp=0.0.0.0:8080 --html=on :100 \
    --env="LIBGL_ALWAYS_SOFTWARE=1" \
    --exit-with-children \
    --start-child="lxterminal" &

sleep 5

# Test OpenGL renderer inside xpra
echo "✅ OpenGL Renderer:"
DISPLAY=:100 LIBGL_ALWAYS_SOFTWARE=1 glxinfo | grep "OpenGL renderer" || true

echo "Display opened. You should see a terminal. Type in the following commannd:"
echo "cd Forge-Project-1.20.X"
echo "./gradlew runClient"
