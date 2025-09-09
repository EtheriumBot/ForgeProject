#!/usr/bin/env bash
set -e

# Paths
SUNSHINE_BIN="$HOME/sunshine/build/sunshine"
MC_DIR="$HOME/Forge-Project-1.20.X"

# Kill any old Sunshine processes
pkill -f sunshine || true

# Start Sunshine
echo "🌞 Starting Sunshine on port 47989..."
nohup "$SUNSHINE_BIN" --config-dir "$HOME/.config/sunshine" \
  > /tmp/sunshine.log 2>&1 &

SUNSHINE_PID=$!
sleep 3

if ps -p $SUNSHINE_PID > /dev/null; then
  echo "✅ Sunshine is running (PID: $SUNSHINE_PID)"
  echo "👉 Connect with Moonlight client using your Codespaces URL + port 47989"
else
  echo "⚠️ Sunshine failed to start. Check /tmp/sunshine.log"
  exit 1
fi

# Launch Minecraft
if [ -d "$MC_DIR" ]; then
  echo "🎮 Launching Minecraft..."
  cd "$MC_DIR"
  chmod +x gradlew
  DISPLAY=:0 ./gradlew runClient || echo "⚠️ Failed to run Minecraft."
else
  echo "⚠️ Minecraft project not found at $MC_DIR"
  echo "👉 Please cd manually and run:"
  echo "   ./gradlew runClient"
fi
#!/usr/bin/env bash
set -e

# Paths
SUNSHINE_BIN="$HOME/sunshine/build/sunshine"
MC_DIR="$HOME/Forge-Project-1.20.X"

# Check Sunshine exists
if [ ! -x "$SUNSHINE_BIN" ]; then
  echo "❌ Sunshine binary not found at $SUNSHINE_BIN"
  echo "👉 Did you run ./build-sunshine.sh first?"
  exit 1
fi

# Kill any old Sunshine processes
pkill -f sunshine || true

# Start Sunshine
echo "🌞 Starting Sunshine on port 47989..."
nohup "$SUNSHINE_BIN" --config-dir "$HOME/.config/sunshine" \
  > /tmp/sunshine.log 2>&1 &

SUNSHINE_PID=$!
sleep 3

if ps -p $SUNSHINE_PID > /dev/null; then
  echo "✅ Sunshine is running (PID: $SUNSHINE_PID)"
  echo "👉 Connect with Moonlight client using your Codespaces URL + port 47989"
else
  echo "⚠️ Sunshine failed to start. Check /tmp/sunshine.log"
  exit 1
fi

# Launch Minecraft
if [ -d "$MC_DIR" ]; then
  echo "🎮 Launching Minecraft..."
  cd "$MC_DIR"
  chmod +x gradlew
  DISPLAY=:0 ./gradlew runClient || echo "⚠️ Failed to run Minecraft."
else
  echo "⚠️ Minecraft project not found at $MC_DIR"
  echo "👉 Please cd manually and run:"
  echo "   ./gradlew runClient"
fi
