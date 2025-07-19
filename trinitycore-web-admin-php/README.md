# TrinityCore Web Administration Panel (PHP)

Eine modulare PHP-Webanwendung zur Verwaltung eines TrinityCore 3.3.5 Servers mit Login/Registrierung und erweiterbaren Plugins.

## Features

- **Authentifizierung**: Login und Registrierung für Spieler
- **Dashboard**: Server-Status und Statistiken in Echtzeit
- **Spieler-Verwaltung**: Account- und Charakterverwaltung
- **Datenbank-Browser**: Durchsuchen von Quests, Kreaturen, NPCs, Items
- **Plugin-System**: Erweiterbare Module (Arsenal, Quest Browser, etc.)
- **Responsive Design**: Optimiert für Desktop und Mobile
- **WoW-inspiriertes Design**: Dunkles Theme mit goldenen Akzenten

## Voraussetzungen

- Apache2 Webserver
- PHP 7.4 oder höher
- MySQL/MariaDB
- TrinityCore 3.3.5 Server
- PDO MySQL Extension

## Installation

### 1. Dateien kopieren

Kopieren Sie alle Dateien in Ihr Apache2 Web-Verzeichnis:

```bash
sudo cp -r trinitycore-web-admin-php /var/www/html/trinitycore-admin
sudo chown -R www-data:www-data /var/www/html/trinitycore-admin
sudo chmod -R 755 /var/www/html/trinitycore-admin
```

### 2. Datenbankkonfiguration

Bearbeiten Sie `config/database.php` und passen Sie die Datenbankeinstellungen an:

```php
const DB_HOST = 'localhost';
const DB_USER = 'ihr_mysql_benutzer';
const DB_PASS = 'ihr_mysql_passwort';
```

### 3. Apache2 Konfiguration

Erstellen Sie eine Virtual Host Konfiguration:

```apache
<VirtualHost *:80>
    ServerName trinitycore-admin.ihre-domain.de
    DocumentRoot /var/www/html/trinitycore-admin
    
    <Directory /var/www/html/trinitycore-admin>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/trinitycore-admin_error.log
    CustomLog ${APACHE_LOG_DIR}/trinitycore-admin_access.log combined
</VirtualHost>
```

### 4. .htaccess erstellen

Erstellen Sie eine `.htaccess` Datei im Hauptverzeichnis:

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
```

### 5. Datenbank-Tabelle für Logs erstellen

Führen Sie folgendes SQL aus:

```sql
USE auth;
CREATE TABLE wotlk_account_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    details TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_account_id (account_id),
    INDEX idx_timestamp (timestamp)
);
```

## Verwendung

### Erste Schritte

1. Öffnen Sie `http://ihre-domain.de/trinitycore-admin` im Browser
2. Registrieren Sie sich mit einem neuen Account
3. Melden Sie sich an und nutzen Sie das Dashboard

### Navigation

- **Dashboard**: Übersicht über Server-Status und Statistiken
- **Spieler**: Account-Verwaltung und -Berechtigungen
- **Charaktere**: Charakterdurchsuchung und -verwaltung
- **Datenbank**: Durchsuchen von Quests, Items, Kreaturen, etc.
- **Plugins**: Zusätzliche Module verwalten

## Projektstruktur

```
trinitycore-web-admin-php/
├── config/
│   └── database.php          # Datenbankkonfiguration
├── includes/
│   └── functions.php         # Allgemeine Funktionen
├── assets/
│   ├── css/                  # Stylesheets
│   ├── js/                   # JavaScript
│   └── images/               # Bilder
├── modules/                  # Hauptmodule
├── plugins/                  # Plugin-System
├── index.php                 # Login/Register
├── dashboard.php             # Hauptdashboard
├── logout.php                # Logout
└── README.md
```

## Datenbankverbindungen

Die Anwendung verbindet sich mit drei TrinityCore-Datenbanken:

- **auth**: Account-Verwaltung und Authentifizierung
- **characters**: Charakterdaten und Spielerinformationen
- **world**: Spielwelt-Daten (Quests, Items, Kreaturen, etc.)

## Sicherheit

- CSRF-Schutz für alle Formulare
- Sichere Session-Verwaltung
- SQL-Injection-Schutz durch PDO
- XSS-Schutz durch Input-Sanitization
- Rate Limiting (kann in Apache2 konfiguriert werden)

## Anpassungen

### Design anpassen

Bearbeiten Sie die CSS-Variablen in `assets/css/main.css`:

```css
:root {
    --primary-color: #c79c6e;    /* Hauptfarbe */
    --accent-color: #ffd700;     /* Akzentfarbe */
    --dark-bg: #1a1a1a;          /* Hintergrund */
}
```

### Neue Module hinzufügen

1. Erstellen Sie eine neue PHP-Datei in `modules/`
2. Fügen Sie die Navigation in `dashboard.php` hinzu
3. Erstellen Sie entsprechende CSS/JS-Dateien

## Troubleshooting

### Häufige Probleme

1. **Datenbankverbindung fehlgeschlagen**
   - Überprüfen Sie die Einstellungen in `config/database.php`
   - Stellen Sie sicher, dass der MySQL-Benutzer die richtigen Rechte hat

2. **Session-Probleme**
   - Überprüfen Sie die PHP-Session-Einstellungen
   - Stellen Sie sicher, dass das Verzeichnis beschreibbar ist

3. **404-Fehler**
   - Aktivieren Sie mod_rewrite: `sudo a2enmod rewrite`
   - Überprüfen Sie die .htaccess-Datei

### Logs überprüfen

```bash
# Apache2 Logs
sudo tail -f /var/log/apache2/trinitycore-admin_error.log

# PHP Logs
sudo tail -f /var/log/php/error.log
```

## Lizenz

MIT License - Siehe LICENSE-Datei für Details.

## Support

Bei Problemen oder Fragen:
1. Überprüfen Sie die Logs
2. Stellen Sie sicher, dass alle Voraussetzungen erfüllt sind
3. Testen Sie die Datenbankverbindung manuell

## Changelog

### Version 1.0.0
- Initiale Version
- Login/Register System
- Dashboard mit Server-Status
- Grundlegende Spieler- und Charakterverwaltung
- Datenbank-Browser
- Plugin-System-Grundlage
