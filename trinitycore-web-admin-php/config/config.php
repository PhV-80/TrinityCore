<?php
// Central configuration file
define('DEV_MODE', true); // Set to false for production

// Debug settings
define('DEBUG_SHOW_PANEL', DEV_MODE); // Show debug panel in browser when DEV_MODE is true
define('DEBUG_LOG_FILE', __DIR__ . '/../logs/debug.log');

// Database settings
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_PREFIX', 'wotlk_');

// Database names (without prefix - prefix will be added dynamically)
define('DB_AUTH', 'auth');
define('DB_CHARACTERS', 'characters');
define('DB_WORLD', 'world');

// Session settings
define('SESSION_NAME', 'trinity_admin');
define('SESSION_LIFETIME', 3600); // 1 hour

// Security settings
define('CSRF_TOKEN_NAME', 'csrf_token');
define('PASSWORD_SALT', 'trinity_core_salt_2024');

// Paths
define('BASE_PATH', __DIR__ . '/..');
define('INCLUDES_PATH', BASE_PATH . '/includes');
define('MODULES_PATH', BASE_PATH . '/modules');
define('PLUGINS_PATH', BASE_PATH . '/plugins');
define('ASSETS_PATH', BASE_PATH . '/assets');

// Create logs directory if it doesn't exist
if (!is_dir(dirname(DEBUG_LOG_FILE))) {
    mkdir(dirname(DEBUG_LOG_FILE), 0755, true);
}
?>