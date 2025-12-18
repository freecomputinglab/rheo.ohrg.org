#!/bin/bash
# This script encodes the readable JavaScript source to base64
# Run this whenever you update sidebar-toggle-source.js

base64 -w 0 pages/sidebar-toggle-source.js > pages/sidebar-toggle.js.b64
echo "eval(atob('$(cat pages/sidebar-toggle.js.b64)'));" > pages/sidebar-toggle.js
rm pages/sidebar-toggle.js.b64
echo "Encoded pages/sidebar-toggle-source.js -> pages/sidebar-toggle.js"
