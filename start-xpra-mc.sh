# PLEASE READ THIS BEFORE YOU DO ANYTHING.
# --------------------------------------------------------------------------------------------
# Do not run this shell command if you have never run the other shell command. (setup-mc.sh)
# To run this command, type the following code in the terminal:
# chmod +x start-xpra-mc.sh
# ./start-xpra-mc.sh
# Please email xwu053447@hsstu.lpsb.org for any errors encountered during the build.
# --------------------------------------------------------------------------------------------

#!/usr/bin/env bash
set -e

echo "🔧 Incremental rebuild: Sunshine + Minecraft..."

cd ~/sunshine/build

echo "🛠️ Incremental build (only changed files)..."
cmake --build . --parallel $(nproc)
echo "✅ Sunshine rebuilt successfully!"

# -----------------------------
# Start services
# -----------------------------
MC_DIR="$HOME/Forge-Project-1.20.X"

echo "🌞 Starting Sunshine..."
nohup ~/sunshine/build/sunshine > /tmp/sunshine.log 2>&1 &

if [ -d "$MC_DIR" ]; then
  echo "🎮 Launching Minecraft inside Xpra desktop..."
  xpra start --bind-tcp=0.0.0.0:8080 --html=on \
       --start-child="bash -lc 'cd $MC_DIR && ./gradlew runClient'" :100
else
  echo "⚠️ No Forge project found at $MC_DIR, starting plain Xpra desktop..."
  xpra start --bind-tcp=0.0.0.0:8080 --html=on --start=lxsession :100
fi

echo ""
echo "✅ Services started! Open Codespaces port 8080 for Xpra web desktop."
echo "✅ Sunshine is running on default port 47989. Logs: /tmp/sunshine.log"
