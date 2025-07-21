#!/bin/bash
# Update-Script für das TrinityCore Webinterface
# Ausführen im Verzeichnis, in dem das Webinterface liegt

set -e

echo "[INFO] TrinityCore Webinterface Update"

echo "[INFO] Git Pull..."
git pull

echo "[INFO] Setze Dateirechte..."
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
chmod +x update_webinterface.sh

echo "[INFO] Update abgeschlossen."