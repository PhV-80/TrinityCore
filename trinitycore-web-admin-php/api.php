<?php
// API-Endpunkte für SRP6-Login und Passwort-Änderung
require_once __DIR__ . '/includes/srp6.php';
require_once __DIR__ . '/includes/functions.php';
require_once __DIR__ . '/config/database.php';

header('Content-Type: application/json');

$action = $_GET['action'] ?? $_POST['action'] ?? '';

switch ($action) {
    case 'srp6_challenge':
        // SRP6 Challenge: Salt und N/g für User liefern
        $username = strtoupper(trim($_POST['username'] ?? ''));
        if (!$username) {
            echo json_encode(['error' => 'Missing username']);
            exit;
        }
        try {
            $db = DatabaseConfig::getAuthConnection();
            $stmt = $db->prepare('SELECT salt, verifier FROM account WHERE username = ?');
            $stmt->execute([$username]);
            $row = $stmt->fetch();
            if (!$row) {
                echo json_encode(['error' => 'User not found']);
                exit;
            }
            echo json_encode([
                'salt' => bin2hex($row['salt']),
                'verifier' => bin2hex($row['verifier']),
                'N_hex' => SRP6::getN(),
                'g_hex' => SRP6::getG()
            ]);
        } catch (Exception $e) {
            echo json_encode(['error' => $e->getMessage()]);
        }
        exit;
    case 'srp6_proof':
        // Hier würde die Server-seitige Proof-Prüfung erfolgen (Proof-Logik folgt)
        echo json_encode(['error' => 'Not implemented']);
        exit;
    case 'change_password':
        // Passwort-Änderung via SRP6 (Proof-Logik folgt)
        echo json_encode(['error' => 'Not implemented']);
        exit;
    default:
        echo json_encode(['error' => 'Unknown action']);
        exit;
}