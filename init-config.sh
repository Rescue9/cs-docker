#!/bin/bash

set -e

echo "Initializing config..."

# =========================
# Seed config
# =========================
if [ -z "$(ls -A /config 2>/dev/null)" ]; then
    echo "Config empty → seeding defaults..."
    cp -r /defaults/. /config/
else
    echo "Config exists → merging defaults..."
    rsync -av --ignore-existing /defaults/ /config/
fi

chown -R abc:abc /config

# =========================
# PATH
# =========================
SDK_DIR="/config/sdks"
export FLUTTER_HOME="$SDK_DIR/flutter"
export ANDROID_HOME="$SDK_DIR/android"
export ANDROID_SDK_ROOT="$SDK_DIR/android"
export EXT_CACHE="/config/.extension-cache"

export PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$JAVA_HOME/bin"

# =========================
# Locate code-server binary
# =========================
CODE_SERVER_BIN="$(command -v code-server || true)"
if [ -z "$CODE_SERVER_BIN" ] && [ -x /app/code-server/bin/code-server ]; then
    CODE_SERVER_BIN="/app/code-server/bin/code-server"
fi

# =========================
# Extensions (JSON manifest + cache + parallel + retry)
# =========================
MANIFEST="/defaults/extensions.json"
MARKER="/config/.extensions_installed"
EXT_DIR="/config/data/extensions"
EXT_CACHE="/config/.extension-cache"

mkdir -p "$EXT_DIR" "$EXT_CACHE"

install_ext() {
    local ext="$1"
    local retries=3

    if "$CODE_SERVER_BIN" --list-extensions --extensions-dir "$EXT_DIR" | grep -q "^${ext%%@*}$"; then
        echo "✔ Already installed: $ext"
        return 0
    fi

    while [ $retries -gt 0 ]; do
        echo "Installing: $ext"

        if "$CODE_SERVER_BIN" \
            --extensions-dir "$EXT_DIR" \
            --install-extension "$ext" \
            --cache-dir "$EXT_CACHE"; then
            echo "✔ Installed: $ext"
            return 0
        fi

        retries=$((retries-1))
        sleep 2
    done

    echo "❌ Failed: $ext"
}

export -f install_ext
export CODE_SERVER_BIN EXT_DIR EXT_CACHE

if [ ! -f "$MARKER" ]; then
    echo "Installing extensions (parallel)..."

    jq -r '.extensions[]' "$MANIFEST" | \
        parallel -j 4 install_ext {}

    touch "$MARKER"
    chown abc:abc "$MARKER"
else
    echo "Extensions already installed"
fi

# =========================
# SDK INSTALLS (unchanged logic can stay here)
# =========================
if [ ! -d "$FLUTTER_HOME" ]; then
    echo "Installing Flutter..."
    mkdir -p "$SDK_DIR"
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"
fi

if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
    echo "Installing Android SDK..."
    mkdir -p "$ANDROID_HOME/cmdline-tools"

    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/android.zip
    unzip -q /tmp/android.zip -d "$ANDROID_HOME/cmdline-tools"
    mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
    rm /tmp/android.zip

    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0"
fi

# =========================
# Start
# =========================
exec /init