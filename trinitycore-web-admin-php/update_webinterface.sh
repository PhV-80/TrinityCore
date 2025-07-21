#!/bin/bash
# TrinityCore Webinterface Update Script

# Variablen ggf. anpassen!
REPO_DIR="TrinityCore"
WEB_DIR="/var/www/html/trinitycore-admin"

cd "$REPO_DIR"

echo "[INFO] Prüfe auf Updates im Repository..."
git fetch

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "[INFO] Keine Änderungen gefunden. Webinterface ist aktuell."
    exit 0
fi

echo "[INFO] Änderungen gefunden, führe git pull aus..."
git pull

echo "[INFO] Kopiere Dateien ins Webverzeichnis..."
sudo cp -r trinitycore-web-admin-php . "$WEB_DIR"

echo "[INFO] Setze Besitzer auf www-data..."
sudo chown -R www-data:www-data "$WEB_DIR"

echo "[INFO] Update abgeschlossen."
