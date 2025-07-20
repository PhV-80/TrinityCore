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
    if (!verifyCSRFToken($_POST['csrf_token'] ?? '')) {
        $error = 'Sicherheitsfehler. Bitte versuchen Sie es erneut.';
    } else {
        $username = sanitizeInput($_POST['username'] ?? '');
        $password = $_POST['password'] ?? '';
        
        if (empty($username) || empty($password)) {
            $error = 'Bitte füllen Sie alle Felder aus.';
        } else {
            try {
                debugLog("Login attempt for username: " . $username);
                
                $db = DatabaseConfig::getAuthConnection();
                debugLog("Database connection established");
                
                $tableName = DatabaseConfig::getTableName('account');
                debugLog("Using table: " . $tableName);
                
                $stmt = $db->prepare("SELECT id, username, sha_pass_hash, email FROM " . $tableName . " WHERE username = ?");
                $stmt->execute(array($username));
                $user = $stmt->fetch();
                
                debugLog("User query result: " . ($user ? "User found" : "User not found"));
                
                if ($user) {
                    $hashedPassword = hashPassword($password);
                    $passwordMatch = verifyPassword($password, $user['sha_pass_hash']);
                    
                    debugLog("Password verification: " . ($passwordMatch ? "Match" : "No match"));
                    debugLog("Input hash: " . $hashedPassword);
                    debugLog("DB hash: " . $user['sha_pass_hash']);
                    
                    if ($passwordMatch) {
                        startSession();
                        $_SESSION['user_id'] = $user['id'];
                        $_SESSION['username'] = $user['username'];
                        $_SESSION['email'] = $user['email'];
                        
                        debugLog("Login successful for user ID: " . $user['id']);
                        logActivity($user['id'], 'login', 'Web login successful');
                        redirect('dashboard.php');
                    } else {
                        $error = 'Ungültige Anmeldedaten.';
                        debugLog("Password mismatch for user: " . $username);
                    }
                } else {
                    $error = 'Ungültige Anmeldedaten.';
                    debugLog("User not found: " . $username);
                }
            } catch (Exception $e) {
                $error = 'Datenbankfehler. Bitte versuchen Sie es später erneut.';
                debugLog("Database error during login: " . $e->getMessage());
                debugLog("Error details: " . $e->getTraceAsString());
            }
        }
    }
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
                    debugLog("Username already exists: " . $username);
                } else {
                    // Create new account
                    $hashedPassword = hashPassword($password);
                    debugLog("Creating new account with hashed password: " . $hashedPassword);
                    
                    $stmt = $db->prepare("INSERT INTO " . $tableName . " (username, sha_pass_hash, email, joindate) VALUES (?, ?, ?, NOW())");
                    $result = $stmt->execute(array($username, $hashedPassword, $email));
                    
                    if ($result) {
                        $success = 'Account erfolgreich erstellt! Sie können sich jetzt anmelden.';
                        debugLog("Account created successfully for: " . $username);
                    } else {
                        $error = 'Registrierung fehlgeschlagen.';
                        debugLog("Account creation failed for: " . $username);
                    }
                }
            } catch (Exception $e) {
                $error = 'Registrierung fehlgeschlagen. Bitte versuchen Sie es später erneut.';
                debugLog("Database error during registration: " . $e->getMessage());
                debugLog("Error details: " . $e->getTraceAsString());
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
                <form method="POST" class="auth-form">
                    <input type="hidden" name="action" value="login">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    
                    <div class="form-group">
                        <label for="login-username">Benutzername</label>
                        <input type="text" id="login-username" name="username" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="login-password">Passwort</label>
                        <input type="password" id="login-password" name="password" required>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-block">Anmelden</button>
                </form>
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
</body>
</html>