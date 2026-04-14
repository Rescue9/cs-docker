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
# PATH (runtime-safe)
# =========================
export SDK_DIR="/config/sdks"

export FLUTTER_HOME="$SDK_DIR/flutter"
export ANDROID_HOME="$SDK_DIR/android"
export ANDROID_SDK_ROOT="$SDK_DIR/android"

export PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$JAVA_HOME/bin"

# =========================
# Extensions (FIXED)
# =========================
EXT_FILE="/defaults/extensions.txt"
MARKER="/config/.extensions_installed"
EXT_DIR="/config/data/extensions"

mkdir -p "$EXT_DIR"

if [ ! -f "$MARKER" ]; then
    echo "Installing extensions..."

    if [ -f "$EXT_FILE" ]; then
        while read -r ext || [ -n "$ext" ]; do
            [ -z "$ext" ] && continue
            echo "Installing $ext"

            code-server \
                --extensions-dir "$EXT_DIR" \
                --install-extension "$ext" || true

        done < "$EXT_FILE"
    fi

    touch "$MARKER"
    chown abc:abc "$MARKER"
else
    echo "Extensions already installed"
fi

# =========================
# SDK INSTALL (runtime, correct location)
# =========================

# Flutter
if [ ! -d "$FLUTTER_HOME" ]; then
    echo "Installing Flutter..."
    mkdir -p "$SDK_DIR"
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"
    chown -R abc:abc "$FLUTTER_HOME"
fi

# Android SDK
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

    chown -R abc:abc "$ANDROID_HOME"
fi

# =========================
# Start container
# =========================
exec /init