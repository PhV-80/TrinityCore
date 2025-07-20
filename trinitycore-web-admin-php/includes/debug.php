<?php
// Global debug system
require_once __DIR__ . '/../config/config.php';

class DebugSystem {
    private static $instance = null;
    private $debugQueue = [];
    private $startTime;
    
    private function __construct() {
        $this->startTime = microtime(true);
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function log($message, $type = 'info', $context = []) {
        $debugEntry = [
            'timestamp' => microtime(true),
            'type' => $type,
            'message' => $message,
            'context' => $context,
            'backtrace' => debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 3)
        ];
        
        $this->debugQueue[] = $debugEntry;
        
        // Also log to file if DEV_MODE is enabled
        if (DEV_MODE && defined('DEBUG_LOG_FILE')) {
            $logMessage = sprintf(
                "[%s] [%s] %s %s\n",
                date('Y-m-d H:i:s'),
                strtoupper($type),
                $message,
                !empty($context) ? json_encode($context) : ''
            );
            error_log($logMessage, 3, DEBUG_LOG_FILE);
        }
    }
    
    public function getQueue() {
        return $this->debugQueue;
    }
    
    public function clearQueue() {
        $this->debugQueue = [];
    }
    
    public function getExecutionTime() {
        return microtime(true) - $this->startTime;
    }
    
    public function renderPanel() {
        if (!DEV_MODE || !DEBUG_SHOW_PANEL) {
            return '';
        }
        
        $debugData = $this->getQueue();
        if (empty($debugData)) {
            return '';
        }
        
        $html = '<div id="debug-panel" style="position: fixed; bottom: 0; left: 0; right: 0; background: #2d2d2d; color: #fff; border-top: 2px solid #ff4444; max-height: 300px; overflow-y: auto; z-index: 9999; font-family: monospace; font-size: 12px; padding: 10px;">';
        $html .= '<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">';
        $html .= '<strong style="color: #ff4444;">DEBUG PANEL (DEV MODE)</strong>';
        $html .= '<button onclick="toggleDebugPanel()" style="background: #ff4444; color: white; border: none; padding: 5px 10px; cursor: pointer;">Toggle</button>';
        $html .= '</div>';
        
        $html .= '<div id="debug-content">';
        foreach ($debugData as $entry) {
            $typeColor = $this->getTypeColor($entry['type']);
            $html .= sprintf(
                '<div style="margin-bottom: 5px; padding: 5px; background: #1a1a1a; border-left: 3px solid %s;">',
                $typeColor
            );
            $html .= sprintf(
                '<span style="color: %s; font-weight: bold;">[%s]</span> %s',
                $typeColor,
                strtoupper($entry['type']),
                htmlspecialchars($entry['message'])
            );
            
            if (!empty($entry['context'])) {
                $html .= '<div style="margin-top: 3px; color: #888;">';
                $html .= '<strong>Context:</strong> ' . htmlspecialchars(json_encode($entry['context'], JSON_PRETTY_PRINT));
                $html .= '</div>';
            }
            
            if (!empty($entry['backtrace'])) {
                $html .= '<div style="margin-top: 3px; color: #888; font-size: 10px;">';
                $html .= '<strong>Location:</strong> ';
                foreach (array_slice($entry['backtrace'], 0, 2) as $trace) {
                    if (isset($trace['file']) && isset($trace['line'])) {
                        $html .= basename($trace['file']) . ':' . $trace['line'] . ' ';
                    }
                }
                $html .= '</div>';
            }
            
            $html .= '</div>';
        }
        
        $html .= sprintf(
            '<div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid #444; color: #888;">Execution time: %.4f seconds</div>',
            $this->getExecutionTime()
        );
        
        $html .= '</div>';
        $html .= '</div>';
        
        $html .= '<script>
        function toggleDebugPanel() {
            const content = document.getElementById("debug-content");
            if (content.style.display === "none") {
                content.style.display = "block";
            } else {
                content.style.display = "none";
            }
        }
        </script>';
        
        return $html;
    }
    
    private function getTypeColor($type) {
        switch ($type) {
            case 'error': return '#ff4444';
            case 'warning': return '#ffaa00';
            case 'info': return '#44aaff';
            case 'success': return '#44ff44';
            default: return '#888888';
        }
    }
}

// Global debug functions
function debugLog($message, $type = 'info', $context = []) {
    DebugSystem::getInstance()->log($message, $type, $context);
}

function debugError($message, $context = []) {
    debugLog($message, 'error', $context);
}

function debugWarning($message, $context = []) {
    debugLog($message, 'warning', $context);
}

function debugSuccess($message, $context = []) {
    debugLog($message, 'success', $context);
}

function renderDebugPanel() {
    return DebugSystem::getInstance()->renderPanel();
}

// Set up error handling for DEV_MODE
if (DEV_MODE) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    ini_set('log_errors', 1);
    
    // Custom error handler to capture errors in debug queue
    set_error_handler(function($errno, $errstr, $errfile, $errline) {
        debugError("PHP Error: $errstr", [
            'file' => $errfile,
            'line' => $errline,
            'errno' => $errno
        ]);
        return false; // Let PHP handle the error normally too
    });
    
    // Exception handler
    set_exception_handler(function($exception) {
        debugError("Uncaught Exception: " . $exception->getMessage(), [
            'file' => $exception->getFile(),
            'line' => $exception->getLine(),
            'trace' => $exception->getTraceAsString()
        ]);
    });
}
?>