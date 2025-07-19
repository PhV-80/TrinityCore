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
    
    // Database names
    const DB_AUTH = 'auth';
    const DB_CHARACTERS = 'characters';
    const DB_WORLD = 'world';
    
    // Table prefixes
    const PREFIX = 'wotlk_';
    
    // Connection instances
    private static $authConnection = null;
    private static $charactersConnection = null;
    private static $worldConnection = null;
    
    /**
     * Get connection to auth database
     */
    public static function getAuthConnection() {
        if (self::$authConnection === null) {
            try {
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
            } catch (PDOException $e) {
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
            } catch (PDOException $e) {
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
            } catch (PDOException $e) {
                die('World database connection failed: ' . $e->getMessage());
            }
        }
        return self::$worldConnection;
    }
    
    /**
     * Get table name with prefix
     */
    public static function getTableName($tableName) {
        return self::PREFIX . $tableName;
    }
}
?>