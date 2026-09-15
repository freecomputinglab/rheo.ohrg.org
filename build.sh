#!/bin/bash
set -e
set -x

echo "=== Starting build ==="
echo "Timestamp: $(date)"

# Setup paths
REPO_DIR="$(pwd)"
RHEO_VERSION="v0.6.3"
RHEO_CACHE="$REPO_DIR/.rheo-binary/$RHEO_VERSION"
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

# @rheo packages are prewarmed automatically by the rheo CLI (0.5.0+),
# so no manual clone or sidebar build is needed here.

# Compile with rheo
echo "Compiling with rheo..."
rheo compile .

# Verify output
if [ ! -f "build/html/index.html" ]; then
  echo "Error: build/html/index.html not found"
  exit 1
fi

# Cloudflare Pages only publishes build/html, but rheo writes the PDF and EPUB
# to build/pdf and build/epub. Copy them alongside the HTML under the names
# pages/index.typ links to.
PDF_SRC="$(find build/pdf -maxdepth 1 -name '*.pdf' | head -1)"
EPUB_SRC="$(find build/epub -maxdepth 1 -name '*.epub' | head -1)"

if [ -z "$PDF_SRC" ]; then
  echo "Error: no PDF found under build/pdf"
  exit 1
fi
if [ -z "$EPUB_SRC" ]; then
  echo "Error: no EPUB found under build/epub"
  exit 1
fi

cp "$PDF_SRC" build/html/rheo-docs.pdf
cp "$EPUB_SRC" build/html/rheo-docs.epub

echo "=== Build completed successfully ==="
echo "Generated $(find build/html -name "*.html" | wc -l) HTML files"
echo "Published $(basename "$PDF_SRC") as rheo-docs.pdf and $(basename "$EPUB_SRC") as rheo-docs.epub"
