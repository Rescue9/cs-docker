#!/bin/bash

set -e

echo "Initializing config..."

# Seed /config if empty
if [ -z "$(ls -A /config 2>/dev/null)" ]; then
    echo "Config is empty, seeding from defaults..."
    cp -r /defaults/. /config/
else
    echo "Config exists, merging updates..."
    rsync -av --ignore-existing /defaults/ /config/
fi

# Fix ownership
chown -R abc:abc /config

# =========================
# Extension installation
# =========================
EXT_FILE="/defaults/extensions.txt"
MARKER="/config/.extensions_installed"

if [ ! -f "$MARKER" ]; then
    echo "Installing default extensions..."

    if [ -f "$EXT_FILE" ]; then
        while read -r ext || [ -n "$ext" ]; do
            [ -z "$ext" ] && continue
            echo "Installing $ext"
            su-exec abc bash -c "code-server --install-extension '$ext'" || true
        done < "$EXT_FILE"
    fi

    touch "$MARKER"
    chown abc:abc "$MARKER"
else
    echo "Extensions already installed, skipping..."
fi

# Start code-server as abc
exec su-exec abc "$@"