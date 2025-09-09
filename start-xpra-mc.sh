#!/usr/bin/env bash
set -euo pipefail

# -------------------------
# start-xpra.sh
# Start xpra HTML5 desktop with llvmpipe (software GL)
# -------------------------

XPRA_DISPLAY=":100"
XPRA_PORT=8080
RUNTIME_DIR="$HOME/.xpra-run"
XPRA_LOG="/tmp/xpra-${XPRA_DISPLAY#*:}.log"

echo "🔧 Starting Xpra + llvmpipe desktop setup..."
echo "Logs: $XPRA_LOG"

# 1) Install required packages
sudo apt-get update
sudo apt-get install -y xpra openbox xterm \
    mesa-utils mesa-utils-extra libgl1 libgl1-mesa-dri \
    openjdk-17-jdk git wget curl || true

# 2) Ensure runtime dir
export XDG_RUNTIME_DIR="$RUNTIME_DIR"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# 3) Stop old sessions & free port
echo "🔁 Stopping any previous xpra sessions..."
xpra stop "$XPRA_DISPLAY" || true

if command -v lsof >/dev/null 2>&1; then
  PID_ON_PORT=$(lsof -ti :"$XPRA_PORT" || true)
  if [ -n "$PID_ON_PORT" ]; then
    echo "⚠️ Port $XPRA_PORT in use by PID(s): $PID_ON_PORT — killing them"
    kill -9 $PID_ON_PORT || true
    sleep 1
  fi
fi

# 4) Wrapper script for inside session
XPRA_START_WRAPPER="$HOME/.xpra_start.sh"
cat > "$XPRA_START_WRAPPER" <<'EOF'
#!/bin/bash
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_LOADER_DRIVER_OVERRIDE=llvmpipe

openbox-session &

# Keep an xterm open
exec xterm -title "xpra-term" -e /bin/sh -lc "echo 'Inside xpra desktop!'; bash"
EOF
chmod +x "$XPRA_START_WRAPPER"

# 5) Start xpra server
echo "🖥️ Launching Xpra on display ${XPRA_DISPLAY}, web port ${XPRA_PORT}..."
nohup xpra start "$XPRA_DISPLAY" \
  --bind-tcp=0.0.0.0:"$XPRA_PORT" \
  --html=on \
  --exit-with-children \
  --start-child="$XPRA_START_WRAPPER" \
  > "$XPRA_LOG" 2>&1 &

sleep 5

# 6) Check renderer
echo "🔎 OpenGL renderer (should be llvmpipe):"
DISPLAY="${XPRA_DISPLAY}" LIBGL_ALWAYS_SOFTWARE=1 glxinfo 2>/dev/null | awk -F: '/OpenGL renderer/{print $2}' || echo " (glxinfo failed, check $XPRA_LOG)"

echo ""
echo "✅ Xpra is running."
echo "👉 Expose port $XPRA_PORT in Codespaces Ports panel (make Public) and open it in your browser."
echo "👉 Once inside the desktop xterm, run:"
echo "     cd Forge-Project-1.20.X"
echo "     ./gradlew runClient"
echo ""
