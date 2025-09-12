# PLEASE READ THIS BEFORE YOU DO ANYTHING:
# --------------------------------------------------------------------------------------------
# Do not run this shell command if you have never run the other shell script (setup-mc.sh) or
# if the other command did not work.
# To run this script, type the following code in the terminal:
# chmod +x start-xpra-mc.sh
# ./start-xpra-mc.sh
# Please email xwu053447@hsstu.lpsb.org for any errors encountered during the build
# or create an issue directly on github. Link to the issue page: 
# https://github.com/RSlover52111/ForgeProject/issues
# --------------------------------------------------------------------------------------------

#!/usr/bin/env bash
set -e

echo "🎮 Launching Minecraft with Sunshine streaming..."

MC_DIR="workspaces/ForgeProject/Forge-Project-1.20.X"
XPRA_DISPLAY=":100"
XPRA_PORT=8080

# -----------------------------
# 0. Ensure Xpra is installed
# -----------------------------
if ! command -v xpra &> /dev/null; then
  echo "📦 Installing Xpra..."
  sudo apt-get update
  sudo apt-get install -y xpra
fi

# -----------------------------
# 1. Clean up old sessions
# -----------------------------
echo "🧹 Cleaning old Xpra and Sunshine sessions..."
xpra stop $XPRA_DISPLAY || true
pkill -f sunshine || true
sleep 2

# -----------------------------
# 2. Start Xpra virtual desktop + Minecraft
# -----------------------------
echo "🖥️ Starting Xpra display on $XPRA_DISPLAY ..."
export DISPLAY=$XPRA_DISPLAY
xpra start $XPRA_DISPLAY \
  --bind-tcp=0.0.0.0:$XPRA_PORT \
  --html=on \
  --opengl=yes \
  --input-method=raw \
  --exit-with-children \
  --start-child="bash -lc 'cd $MC_DIR && ./gradlew runClient'" &

# Give Xpra & Minecraft some time to boot
sleep 15

# -----------------------------
# 3. Start Sunshine capturing Xpra
# -----------------------------
echo "🌞 Starting Sunshine (capturing $DISPLAY)..."
DISPLAY=$XPRA_DISPLAY nohup ~/sunshine/build/sunshine > /tmp/sunshine.log 2>&1 &

# -----------------------------
# 4. Done
# -----------------------------
echo ""
echo "✅ Setup complete!"
echo "👉 Open Codespaces port $XPRA_PORT for Xpra web desktop."
echo "👉 Sunshine is running on port 47989, capturing display $XPRA_DISPLAY."
echo "👉 Logs: /tmp/sunshine.log"
