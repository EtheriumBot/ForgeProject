# !!! PLEASE READ THIS BEFORE YOU DO ANYTHING:
# ---------------------------------------------------------------------------------------------------
# !!! This script is only meant to be ran once! But you must run this first to setup Minecraft. !!!
# To run this script, type in terminal the folling command:
# chmod +x setup-mc.sh (run only once, this command allows this script to run)
# ./setup-mc.sh (runninng the actual script)
# Please email xwu053447@hsstu.lpsb.org for any errors encountered during the build
# or create an issue directly on github. Link to the issue page: 
# https://github.com/RSlover52111/ForgeProject/issues
# ---------------------------------------------------------------------------------------------------


#!/usr/bin/env bash
set -e

echo "🔧 Preparing environment for Xpra + Sunshine + Minecraft..."

# -----------------------------
# 1. System update
# -----------------------------
sudo apt-get update
sudo apt-get upgrade -y

# -----------------------------
# 2. Install Xpra + LXDE desktop
# -----------------------------
echo "🖥️ Installing Xpra and desktop environment..."
sudo apt-get install -y \
  xpra lxde-core lxterminal mesa-utils pulseaudio dbus-x11

# -----------------------------
# 3. Install Sunshine dependencies
# -----------------------------
echo "🌞 Installing Sunshine build dependencies..."
sudo apt-get install -y \
  build-essential cmake git pkg-config meson ninja-build \
  python3 python3-pip python3-setuptools python3-wheel \
  curl wget unzip zip \
  ffmpeg libavcodec-dev libavdevice-dev libavfilter-dev \
  libavformat-dev libavutil-dev libswscale-dev libswresample-dev \
  libdrm-dev libx11-dev libxrandr-dev \
  libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev \
  libxi-dev libxxf86vm-dev libxkbcommon-dev libegl1-mesa-dev \
  libasound2-dev libpulse-dev \
  libdbus-1-dev libudev-dev libevdev-dev \
  miniupnpc libcap-dev libva-dev \
  libnotify-dev libayatana-appindicator3-dev \
  doxygen graphviz \
  libgbm-dev \
  libnuma-dev

# -----------------------------
# Fix Doxygen (>=1.10 required)
# -----------------------------
echo "📦 Installing latest Doxygen (>=1.10)..."
wget -q https://www.doxygen.nl/files/doxygen-1.11.0.linux.bin.tar.gz -O /tmp/doxygen.tar.gz
cd /tmp
tar -xzf doxygen.tar.gz
sudo cp doxygen-1.11.0/bin/doxygen /usr/local/bin/
sudo chmod +x /usr/local/bin/doxygen
echo "✅ Doxygen version: $(doxygen --version)"

# -----------------------------
# 4. Clone + build Sunshine
# -----------------------------
if [ ! -d "$HOME/sunshine" ]; then
  echo "📥 Cloning Sunshine..."
  git clone https://github.com/LizardByte/Sunshine.git ~/sunshine
fi

cd ~/sunshine
echo "🔄 Updating submodules..."
git submodule update --init --recursive

echo "🧹 Cleaning old build..." # Optional
rm -rf build
mkdir build && cd build

echo "⚙️ Configuring Sunshine..."
cmake -DSUNSHINE_ENABLE_CUDA=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release ..

echo "🛠️ Building Sunshine..."
echo "⚠️ Warning: This may take up to 30 minutes."
cmake --build . --parallel $(nproc)
echo "✅ Sunshine built successfully! Starting minecraft + sunshine + xpra"

# -----------------------------
# 5. Start services
# -----------------------------

# Start Sunshine in background
echo "🌞 Starting Sunshine..."
nohup ~/sunshine/build/sunshine > /tmp/sunshine.log 2>&1 &
echo "✅ Sunshine started."

# Start Xpra desktop and launch Minecraft inside it
MC_DIR="workspaces/ForgeProject/Forge-Project-1.20.X"
XPRA_DISPLAY=":100"
XPRA_PORT=8080

echo "Looking for Minecraft project folder..."

if [ -d "$MC_DIR" ]; then
  echo "🎮 Found Minecraft project. Launching inside Xpra desktop... Estimated time: 2 minutes"
  xpra start $XPRA_DISPLAY \
  --bind-tcp=0.0.0.0:$XPRA_PORT \
  --html=on \
  --opengl=yes \
  --input-method=raw \
  --exit-with-children \
  --start-child="bash -lc 'cd $MC_DIR && ./gradlew runClient'" :100

  echo ""
  echo "✅ Setup complete!"
  echo "👉 Open Codespaces port 8080 for Xpra web desktop."
  echo "👉 Sunshine is running (default port: 47989). Logs: /tmp/sunshine.log"
else
  echo "⚠️ No Forge project found at $MC_DIR"
  echo "👉 Starting plain Xpra desktop instead..."
  xpra start --bind-tcp=0.0.0.0:8080 --html=on --start=lxsession :100
  echo "Open Codespaces port 8080 for Xpra web desktop. Enter the following commands:"
  echo "cd Forge-Project-1.20.X"
  echo "./gradlew runClient"
fi
