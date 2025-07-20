<?php
/**
 * Debug-Seite für Entwicklung
 * Diese Datei sollte in der Produktion entfernt werden!
 */

// Debug-Modus aktivieren
define('DEBUG_MODE', true);

require_once 'config/database.php';
require_once 'includes/functions.php';

echo "<h1>TrinityCore Web Admin - Debug Information</h1>";

echo "<h2>1. PHP Information</h2>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>PDO verfügbar: " . (extension_loaded('pdo') ? 'Ja' : 'Nein') . "</p>";
echo "<p>PDO MySQL verfügbar: " . (extension_loaded('pdo_mysql') ? 'Ja' : 'Nein') . "</p>";

echo "<h2>2. Database Configuration</h2>";
echo "<p>Host: " . DatabaseConfig::DB_HOST . "</p>";
echo "<p>User: " . DatabaseConfig::DB_USER . "</p>";
echo "<p>Auth DB: " . DatabaseConfig::DB_AUTH . "</p>";
echo "<p>Characters DB: " . DatabaseConfig::DB_CHARACTERS . "</p>";
echo "<p>World DB: " . DatabaseConfig::DB_WORLD . "</p>";

echo "<h2>3. Database Connection Test</h2>";

try {
    echo "<h3>Auth Database Test:</h3>";
    $authConn = DatabaseConfig::getAuthConnection();
    echo "<p style='color: green;'>✓ Auth database connection successful</p>";
    
    // Test table access
    $tableName = DatabaseConfig::getTableName('account');
    echo "<p>Testing table: " . $tableName . "</p>";
    
    $stmt = $authConn->prepare("SELECT COUNT(*) as count FROM " . $tableName);
    $stmt->execute();
    $result = $stmt->fetch();
    echo "<p>Accounts in database: " . $result['count'] . "</p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>✗ Auth database error: " . $e->getMessage() . "</p>";
    echo "<p>Error code: " . $e->getCode() . "</p>";
}

try {
    echo "<h3>Characters Database Test:</h3>";
    $charConn = DatabaseConfig::getCharactersConnection();
    echo "<p style='color: green;'>✓ Characters database connection successful</p>";
    
    // Test table access
    $tableName = DatabaseConfig::getTableName('characters');
    echo "<p>Testing table: " . $tableName . "</p>";
    
    $stmt = $charConn->prepare("SELECT COUNT(*) as count FROM " . $tableName);
    $stmt->execute();
    $result = $stmt->fetch();
    echo "<p>Characters in database: " . $result['count'] . "</p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>✗ Characters database error: " . $e->getMessage() . "</p>";
    echo "<p>Error code: " . $e->getCode() . "</p>";
}

try {
    echo "<h3>World Database Test:</h3>";
    $worldConn = DatabaseConfig::getWorldConnection();
    echo "<p style='color: green;'>✓ World database connection successful</p>";
    
} catch (Exception $e) {
    echo "<p style='color: red;'>✗ World database error: " . $e->getMessage() . "</p>";
    echo "<p>Error code: " . $e->getCode() . "</p>";
}

echo "<h2>4. Function Tests</h2>";

echo "<h3>Password Hashing Test:</h3>";
$testPassword = "test123";
$hashedPassword = hashPassword($testPassword);
echo "<p>Test password: " . $testPassword . "</p>";
echo "<p>Hashed password: " . $hashedPassword . "</p>";
echo "<p>Verification: " . (verifyPassword($testPassword, $hashedPassword) ? '✓ Pass' : '✗ Fail') . "</p>";

echo "<h3>Statistics Test:</h3>";
echo "<p>Online players: " . getOnlinePlayersCount() . "</p>";
echo "<p>Total accounts: " . getTotalAccountsCount() . "</p>";
echo "<p>Total characters: " . getTotalCharactersCount() . "</p>";

echo "<h2>5. Session Test</h2>";
startSession();
echo "<p>Session ID: " . session_id() . "</p>";
echo "<p>Session status: " . session_status() . "</p>";
echo "<p>Logged in: " . (isLoggedIn() ? 'Ja' : 'Nein') . "</p>";

echo "<h2>6. Error Log Location</h2>";
echo "<p>PHP error log: " . ini_get('error_log') . "</p>";
echo "<p>Apache error log: /var/log/apache2/error.log</p>";

echo "<hr>";
echo "<p><strong>Hinweis:</strong> Diese Debug-Seite sollte in der Produktion entfernt werden!</p>";
echo "<p><a href='index.php'>Zurück zur Login-Seite</a></p>";
?>