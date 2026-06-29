#!/bin/bash
set -e
set -x

echo "=== Starting build ==="
echo "Timestamp: $(date)"

# Setup paths
REPO_DIR="$(pwd)"
RHEO_VERSION="v0.4.0"
RHEO_CACHE="$REPO_DIR/.rheo-binary"
RHEO_BIN="$RHEO_CACHE/rheo"

# Download rheo binary from GitHub release if not cached
if [ ! -f "$RHEO_BIN" ]; then
  echo "Downloading rheo ${RHEO_VERSION}..."
  mkdir -p "$RHEO_CACHE"
  curl -sL "https://github.com/freecomputinglab/rheo/releases/download/${RHEO_VERSION}/rheo-x86_64-unknown-linux-gnu.zip" -o /tmp/rheo.zip
  unzip -o /tmp/rheo.zip -d "$RHEO_CACHE"
  chmod +x "$RHEO_BIN"
  rm /tmp/rheo.zip
  echo "Rheo downloaded successfully"
else
  echo "Using cached rheo binary"
fi

# Add rheo to PATH
export PATH="$RHEO_CACHE:$PATH"

# Verify rheo is accessible
rheo --version || echo "Warning: rheo --version failed, but continuing..."

# Install @rheo packages into Typst package cache
TYPST_PKG_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/typst/packages"
RHEO_PKGS_DIR="$TYPST_PKG_CACHE/rheo"
if [ ! -d "$RHEO_PKGS_DIR" ]; then
  echo "Cloning rheo-packages..."
  mkdir -p "$TYPST_PKG_CACHE"
  git clone https://github.com/freecomputinglab/rheo-packages.git "$RHEO_PKGS_DIR"
else
  echo "Using cached rheo-packages"
fi

# Build @rheo/sidebar dist if not already built
SIDEBAR_DIST="$RHEO_PKGS_DIR/sidebar/0.1.0/dist"
if [ ! -d "$SIDEBAR_DIST" ]; then
  echo "Building @rheo/sidebar..."
  (cd "$RHEO_PKGS_DIR/sidebar/0.1.0" && pnpm install && pnpm run build)
else
  echo "Using cached @rheo/sidebar dist"
fi

# Compile with rheo
echo "Compiling with rheo..."
rheo compile .

# Verify output
if [ ! -f "build/html/index.html" ]; then
  echo "Error: build/html/index.html not found"
  exit 1
fi

echo "=== Build completed successfully ==="
echo "Generated $(find build/html -name "*.html" | wc -l) HTML files"
