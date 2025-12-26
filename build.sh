#!/bin/bash
set -e

echo "=== Starting build ==="

# Setup paths - use .cache for caching (automatically cached by Cloudflare Pages)
REPO_DIR="$(pwd)"
RHEO_CACHE="$REPO_DIR/.cache/rheo-bin"
RHEO_BIN="$RHEO_CACHE/rheo"
export CARGO_HOME="$REPO_DIR/.cache/cargo"

# Install Rust toolchain
if ! command -v rustc &> /dev/null; then
  echo "Installing Rust stable toolchain..."

  # Install rustup if not available
  if ! command -v rustup &> /dev/null; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable
    source "$CARGO_HOME/env"
  else
    rustup toolchain install stable --profile minimal
    rustup default stable
  fi
else
  echo "Rust toolchain already available"
fi

# Build or use cached rheo binary
if [ ! -f "$RHEO_BIN" ]; then
  echo "Building rheo from source..."

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    exit 1
  fi

  git clone https://${GITHUB_TOKEN}@github.com/breezykermo/rheo /tmp/rheo
  cd /tmp/rheo
  cargo build --release

  mkdir -p "$RHEO_CACHE"
  cp target/release/rheo "$RHEO_BIN"
  chmod +x "$RHEO_BIN"
  cd "$REPO_DIR"

  echo "Rheo built and cached"
else
  echo "Using cached rheo binary from previous build"
fi

# Download Inter font for typst (for PDF/EPUB generation)
FONTS_DIR="$REPO_DIR/fonts"
if [ ! -d "$FONTS_DIR" ] || [ ! -f "$FONTS_DIR/Inter.ttc" ]; then
  echo "Downloading Inter font..."
  mkdir -p "$FONTS_DIR"
  cd "$FONTS_DIR"
  curl -L https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip -o Inter.zip
  unzip -q Inter.zip
  rm Inter.zip
  cd "$REPO_DIR"
  echo "Inter font downloaded"
else
  echo "Inter font already available"
fi

# Set font path for typst (for PDF/EPUB generation)
export TYPST_FONT_PATHS="$FONTS_DIR"

# Compile with rheo
echo "Compiling with rheo..."
"$RHEO_BIN" compile .

# Copy PDF and EPUB to html folder
echo "Copying PDF and EPUB files..."
cp build/pdf/*.pdf build/html/rheo-docs.pdf
cp build/epub/*.epub build/html/rheo-docs.epub

# Verify output
if [ ! -f "build/html/index.html" ]; then
  echo "Error: build/html/index.html not found"
  exit 1
fi

echo "=== Build completed successfully ==="
echo "Generated $(find build/html -name "*.html" | wc -l) HTML files"
