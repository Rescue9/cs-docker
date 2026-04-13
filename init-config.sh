#!/bin/bash

set -e

echo "Initializing config..."

# If /config is empty, copy everything
if [ -z "$(ls -A /config 2>/dev/null)" ]; then
    echo "Config is empty, seeding from defaults..."
    cp -r /defaults/* /config/
else
    echo "Config exists, merging updates..."
    rsync -av --update /defaults/data/User/ /config/data/User/
fi

# Fix ownership (important for linuxserver containers)
chown -R abc:abc /config

# Continue with original container startup
exec /init