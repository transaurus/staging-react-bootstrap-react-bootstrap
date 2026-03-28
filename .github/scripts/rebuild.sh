#!/usr/bin/env bash
set -euo pipefail

# Rebuild script for react-bootstrap/react-bootstrap
# Runs from the www/ directory of an existing source tree (no clone).
# The build requires root-level node_modules for the src/ alias.
# If root package.json is not present (staging repo only has www/ content),
# we clone the source repo to get the root deps, then copy them in.

echo "[INFO] Node version: $(node -v)"

# --- Package manager: Yarn v1 (classic) ---
if ! command -v yarn &> /dev/null; then
    echo "[INFO] Installing yarn..."
    npm install -g yarn
fi
echo "[INFO] Yarn version: $(yarn --version)"

CURRENT_DIR="$(pwd)"

# --- Install root dependencies (needed for src/ alias) ---
# Check if root package.json is present (staging repo has full tree)
if [ -f "../package.json" ]; then
    echo "[INFO] Root package.json found, installing root dependencies..."
    cd ..
    yarn install --frozen-lockfile
    cd "$CURRENT_DIR"
else
    echo "[INFO] No root package.json, cloning source for root dependencies..."
    TEMP_DIR="/tmp/react-bootstrap-root-$$"
    git clone --depth 1 --branch master https://github.com/react-bootstrap/react-bootstrap "$TEMP_DIR"
    cd "$TEMP_DIR"
    yarn install --frozen-lockfile
    # Copy root node_modules alongside current www/ dir
    cp -r node_modules "$CURRENT_DIR/../node_modules"
    cd "$CURRENT_DIR"
    rm -rf "$TEMP_DIR"
fi

# --- Install www/ dependencies ---
echo "[INFO] Installing www/ dependencies..."
yarn install --frozen-lockfile

# --- Build ---
echo "[INFO] Running build..."
yarn build

echo "[DONE] Build complete."
