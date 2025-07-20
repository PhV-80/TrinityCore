<?php
/**
 * TrinityCore Database Configuration
 * Konfiguration für die TrinityCore Datenbanken
 */

class DatabaseConfig {
    // Database connection settings
    const DB_HOST = 'localhost';
    const DB_USER = 'trinity';  // Ändern Sie dies zu Ihrem MySQL Benutzer
    const DB_PASS = 'trinity';  // Ändern Sie dies zu Ihrem MySQL Passwort
    
    // Database names with prefix
    const DB_AUTH = 'wotlk_auth';
    const DB_CHARACTERS = 'wotlk_characters';
    const DB_WORLD = 'wotlk_world';
    
    // Connection instances
    private static $authConnection = null;
    private static $charactersConnection = null;
    private static $worldConnection = null;
    
    /**
     * Debug logging function
     */
    private static function debugLog($message) {
        if (defined('DEBUG_MODE') && DEBUG_MODE) {
            error_log("[DB DEBUG] " . $message);
        }
    }
    
    /**
     * Get connection to auth database
     */
    public static function getAuthConnection() {
        if (self::$authConnection === null) {
            try {
                self::debugLog("Attempting to connect to auth database: " . self::DB_AUTH);
                self::debugLog("Connection string: mysql:host=" . self::DB_HOST . ";dbname=" . self::DB_AUTH . ";charset=utf8");
                self::debugLog("User: " . self::DB_USER);
                
                self::$authConnection = new PDO(
                    'mysql:host=' . self::DB_HOST . ';dbname=' . self::DB_AUTH . ';charset=utf8',
                    self::DB_USER,
                    self::DB_PASS,
                    array(
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
                    )
                );
                
                self::debugLog("Auth database connection successful");
            } catch (PDOException $e) {
                self::debugLog("Auth database connection failed: " . $e->getMessage());
                self::debugLog("Error code: " . $e->getCode());
                die('Auth database connection failed: ' . $e->getMessage());
            }
        }
        return self::$authConnection;
    }
    
    /**
     * Get connection to characters database
     */
    public static function getCharactersConnection() {
        if (self::$charactersConnection === null) {
            try {
                self::debugLog("Attempting to connect to characters database: " . self::DB_CHARACTERS);
                
                self::$charactersConnection = new PDO(
                    'mysql:host=' . self::DB_HOST . ';dbname=' . self::DB_CHARACTERS . ';charset=utf8',
                    self::DB_USER,
                    self::DB_PASS,
                    array(
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
                    )
                );
                
                self::debugLog("Characters database connection successful");
            } catch (PDOException $e) {
                self::debugLog("Characters database connection failed: " . $e->getMessage());
                self::debugLog("Error code: " . $e->getCode());
                die('Characters database connection failed: ' . $e->getMessage());
            }
        }
        return self::$charactersConnection;
    }
    
    /**
     * Get connection to world database
     */
    public static function getWorldConnection() {
        if (self::$worldConnection === null) {
            try {
                self::debugLog("Attempting to connect to world database: " . self::DB_WORLD);
                
                self::$worldConnection = new PDO(
                    'mysql:host=' . self::DB_HOST . ';dbname=' . self::DB_WORLD . ';charset=utf8',
                    self::DB_USER,
                    self::DB_PASS,
                    array(
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
                    )
                );
                
                self::debugLog("World database connection successful");
            } catch (PDOException $e) {
                self::debugLog("World database connection failed: " . $e->getMessage());
                self::debugLog("Error code: " . $e->getCode());
                die('World database connection failed: ' . $e->getMessage());
            }
        }
        return self::$worldConnection;
    }
    
    /**
     * Get table name (no prefix needed, tables are in prefixed databases)
     */
    public static function getTableName($tableName) {
        self::debugLog("Getting table name: " . $tableName . " (no prefix needed)");
        return $tableName;
    }
    
    /**
     * Test database connections
     */
    public static function testConnections() {
        self::debugLog("Testing all database connections...");
        
        try {
            $authConn = self::getAuthConnection();
            self::debugLog("Auth connection test: SUCCESS");
            
            $charConn = self::getCharactersConnection();
            self::debugLog("Characters connection test: SUCCESS");
            
            $worldConn = self::getWorldConnection();
            self::debugLog("World connection test: SUCCESS");
            
            return true;
        } catch (Exception $e) {
            self::debugLog("Connection test failed: " . $e->getMessage());
            return false;
        }
    }
}
?>