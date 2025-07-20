<?php
/**
 * General Functions
 * Allgemeine Hilfsfunktionen für die TrinityCore Web Admin
 */

require_once __DIR__ . '/../config/config.php';
require_once 'config/database.php';
require_once __DIR__ . '/debug.php';

/**
 * Gibt im DEV-Modus einen Hinweis in die HTML-Ausgabe
 */
function devModeBanner() {
    if (DEV_MODE) {
        echo '<div style="background:#c00;color:#fff;padding:8px 16px;font-weight:bold;text-align:center;">DEBUG-MODUS AKTIV: Fehlerausgabe & Logging sind aktiviert!</div>';
    }
}

/**
 * Start session if not already started
 */
function startSession() {
    if (session_status() == PHP_SESSION_NONE) {
        session_start();
    }
}

/**
 * Check if user is logged in
 */
function isLoggedIn() {
    startSession();
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

/**
 * Get current user ID
 */
function getCurrentUserId() {
    startSession();
    return $_SESSION['user_id'] ?? null;
}

/**
 * Get current username
 */
function getCurrentUsername() {
    startSession();
    return $_SESSION['username'] ?? null;
}

/**
 * Hash password for TrinityCore (SHA1)
 */
function hashPassword($password) {
    return strtoupper(sha1($password));
}

/**
 * Verify password against TrinityCore hash
 */
function verifyPassword($password, $hash) {
    return strtoupper(sha1($password)) === $hash;
}

/**
 * Sanitize input
 */
function sanitizeInput($input) {
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

/**
 * Generate CSRF token
 */
function generateCSRFToken() {
    startSession();
    if (!isset($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

/**
 * Verify CSRF token
 */
function verifyCSRFToken($token) {
    startSession();
    return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

/**
 * Redirect to URL
 */
function redirect($url) {
    header("Location: $url");
    exit();
}

/**
 * Get server status
 */
function getServerStatus() {
    // This would check if the TrinityCore server is running
    // For now, return a mock status
    return array(
        'status' => 'online',
        'uptime' => '2 days, 5 hours',
        'online_players' => getOnlinePlayersCount(),
        'max_players' => 1000
    );
}

/**
 * Get online players count
 */
function getOnlinePlayersCount() {
    try {
        $db = DatabaseConfig::getCharactersConnection();
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM " . DatabaseConfig::getTableName('characters') . " WHERE online = 1");
        $stmt->execute();
        $result = $stmt->fetch();
        return $result['count'] ?? 0;
    } catch (Exception $e) {
        debugError("Error getting online players count: " . $e->getMessage());
        return 0;
    }
}

/**
 * Get total accounts count
 */
function getTotalAccountsCount() {
    try {
        $db = DatabaseConfig::getAuthConnection();
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM " . DatabaseConfig::getTableName('account'));
        $stmt->execute();
        $result = $stmt->fetch();
        return $result['count'] ?? 0;
    } catch (Exception $e) {
        debugError("Error getting total accounts count: " . $e->getMessage());
        return 0;
    }
}

/**
 * Get total characters count
 */
function getTotalCharactersCount() {
    try {
        $db = DatabaseConfig::getCharactersConnection();
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM " . DatabaseConfig::getTableName('characters'));
        $stmt->execute();
        $result = $stmt->fetch();
        return $result['count'] ?? 0;
    } catch (Exception $e) {
        debugError("Error getting total characters count: " . $e->getMessage());
        return 0;
    }
}

/**
 * Format date for display
 */
function formatDate($date) {
    return date('d.m.Y H:i:s', strtotime($date));
}

/**
 * Get character class name
 */
function getCharacterClassName($classId) {
    $classes = array(
        1 => 'Krieger',
        2 => 'Paladin',
        3 => 'Jäger',
        4 => 'Schurke',
        5 => 'Priester',
        6 => 'Todesritter',
        7 => 'Schamane',
        8 => 'Magier',
        9 => 'Hexenmeister',
        11 => 'Druide'
    );
    return $classes[$classId] ?? 'Unbekannt';
}

/**
 * Get character race name
 */
function getCharacterRaceName($raceId) {
    $races = array(
        1 => 'Mensch',
        2 => 'Orc',
        3 => 'Zwerg',
        4 => 'Nachtelf',
        5 => 'Untoter',
        6 => 'Tauren',
        7 => 'Gnom',
        8 => 'Troll',
        9 => 'Goblin',
        10 => 'Blutelf',
        11 => 'Draenei',
        22 => 'Worgen'
    );
    return $races[$raceId] ?? 'Unbekannt';
}

/**
 * Log activity
 */
function logActivity($userId, $action, $details = '') {
    try {
        $db = DatabaseConfig::getAuthConnection();
        $stmt = $db->prepare("INSERT INTO " . DatabaseConfig::getTableName('account_log') . " (account_id, action, details, timestamp) VALUES (?, ?, ?, NOW())");
        $stmt->execute(array($userId, $action, $details));
    } catch (Exception $e) {
        debugError("Error logging activity: " . $e->getMessage());
    }
}
?>