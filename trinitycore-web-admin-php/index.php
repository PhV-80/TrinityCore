<?php
require_once 'includes/functions.php';

// Check if user is already logged in
if (isLoggedIn()) {
    redirect('dashboard.php');
}

$error = '';
$success = '';

// Handle login form submission
if ($_POST && isset($_POST['action']) && $_POST['action'] === 'login') {
    $error = 'Web-Login ist mit dieser TrinityCore-Version nicht möglich. Bitte nutze den WoW-Client.';
}

// Handle registration form submission
if ($_POST && isset($_POST['action']) && $_POST['action'] === 'register') {
    if (!verifyCSRFToken($_POST['csrf_token'] ?? '')) {
        $error = 'Sicherheitsfehler. Bitte versuchen Sie es erneut.';
    } else {
        $username = sanitizeInput($_POST['username'] ?? '');
        $email = sanitizeInput($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $confirm_password = $_POST['confirm_password'] ?? '';
        if (empty($username) || empty($email) || empty($password) || empty($confirm_password)) {
            $error = 'Bitte füllen Sie alle Felder aus.';
        } elseif ($password !== $confirm_password) {
            $error = 'Passwörter stimmen nicht überein.';
        } elseif (strlen($password) < 6) {
            $error = 'Passwort muss mindestens 6 Zeichen lang sein.';
        } else {
            try {
                debugLog("Registration attempt for username: " . $username);
                $db = DatabaseConfig::getAuthConnection();
                debugLog("Database connection established for registration");
                $tableName = DatabaseConfig::getTableName('account');
                debugLog("Using table: " . $tableName);
                // Check if username already exists
                $stmt = $db->prepare("SELECT id FROM " . $tableName . " WHERE username = ?");
                $stmt->execute(array($username));
                if ($stmt->fetch()) {
                    $error = 'Benutzername existiert bereits.';
                    debugWarning("Username already exists: " . $username);
                } else {
                    // SRP6 salt/verifier generieren
                    require_once __DIR__ . '/includes/srp6.php';
                    $salt = SRP6::generateSalt();
                    $verifier = SRP6::calculateVerifier($username, $password, $salt);
                    debugLog("SRP6 salt/verifier erzeugt");
                    $stmt = $db->prepare("INSERT INTO " . $tableName . " (username, salt, verifier, email, joindate) VALUES (?, ?, ?, ?, NOW())");
                    $result = $stmt->execute(array($username, $salt, $verifier, $email));
                    if ($result) {
                        $success = 'Account erfolgreich erstellt! Sie können sich jetzt im WoW-Client anmelden.';
                        debugSuccess("Account created successfully for: " . $username);
                    } else {
                        $error = 'Registrierung fehlgeschlagen.';
                        debugError("Account creation failed for: " . $username);
                    }
                }
            } catch (Exception $e) {
                $error = 'Registrierung fehlgeschlagen. Bitte versuchen Sie es später erneut.';
                debugError("Database error during registration: " . $e->getMessage());
                debugError("Error details: " . $e->getTraceAsString());
            }
        }
    }
}

$csrf_token = generateCSRFToken();
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TrinityCore Server Administration</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
</head>
<body>
<?php devModeBanner(); ?>
    <div class="container">
        <div class="auth-container">
            <div class="auth-header">
                <h1>TrinityCore</h1>
                <h2>Server Administration</h2>
            </div>
            
            <?php if ($error): ?>
                <div class="alert alert-error"><?php echo $error; ?></div>
            <?php endif; ?>
            
            <?php if ($success): ?>
                <div class="alert alert-success"><?php echo $success; ?></div>
            <?php endif; ?>
            
            <div class="auth-tabs">
                <button class="tab-btn active" data-tab="login">Anmelden</button>
                <button class="tab-btn" data-tab="register">Registrieren</button>
            </div>
            
            <!-- Login Form -->
            <div id="login-tab" class="auth-tab active">
                <div class="alert alert-warning">Web-Login ist mit dieser TrinityCore-Version nicht möglich. Bitte nutze den WoW-Client.</div>
            </div>
            
            <!-- Register Form -->
            <div id="register-tab" class="auth-tab">
                <form method="POST" class="auth-form">
                    <input type="hidden" name="action" value="register">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    
                    <div class="form-group">
                        <label for="register-username">Benutzername</label>
                        <input type="text" id="register-username" name="username" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="register-email">E-Mail</label>
                        <input type="email" id="register-email" name="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="register-password">Passwort</label>
                        <input type="password" id="register-password" name="password" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="register-confirm">Passwort bestätigen</label>
                        <input type="password" id="register-confirm" name="confirm_password" required>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-block">Registrieren</button>
                </form>
            </div>
        </div>
    </div>
    
    <script src="assets/js/auth.js"></script>
    <script src="assets/js/srp6.js"></script>
    <?php echo renderDebugPanel(); ?>
</body>
</html>