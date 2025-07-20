<?php
require_once 'includes/functions.php';

// Check if user is logged in
if (!isLoggedIn()) {
    redirect('index.php');
}

$currentUser = getCurrentUsername();
$serverStatus = getServerStatus();
$onlinePlayers = getOnlinePlayersCount();
$totalAccounts = getTotalAccountsCount();
$totalCharacters = getTotalCharactersCount();
?>
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - TrinityCore Admin</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@400;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
</head>
<body>
<?php devModeBanner(); ?>
    <div class="app-wrapper">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="logo">
                    <h1>TrinityCore Admin</h1>
                </div>
                <nav class="main-nav">
                    <ul>
                        <li><a href="dashboard.php" class="nav-link active">Dashboard</a></li>
                        <li><a href="players.php" class="nav-link">Spieler</a></li>
                        <li><a href="characters.php" class="nav-link">Charaktere</a></li>
                        <li><a href="database.php" class="nav-link">Datenbank</a></li>
                        <li><a href="plugins.php" class="nav-link">Plugins</a></li>
                    </ul>
                </nav>
                <div class="user-menu">
                    <span class="username"><?php echo htmlspecialchars($currentUser); ?></span>
                    <a href="logout.php" class="btn btn-secondary">Abmelden</a>
                </div>
            </div>
        </header>

        <!-- Main Content -->
        <main class="app-main">
            <div class="page-header">
                <h2>Server Dashboard</h2>
                <p>Willkommen zurück, <?php echo htmlspecialchars($currentUser); ?>!</p>
            </div>

            <!-- Server Status Cards -->
            <div class="dashboard-grid">
                <div class="dashboard-card">
                    <div class="card-header">
                        <h3>Server Status</h3>
                    </div>
                    <div class="card-content">
                        <div class="status-indicator">
                            <span class="status-dot <?php echo $serverStatus['status'] === 'online' ? 'online' : 'offline'; ?>"></span>
                            <span class="status-text"><?php echo ucfirst($serverStatus['status']); ?></span>
                        </div>
                        <div class="status-details">
                            <p><strong>Uptime:</strong> <?php echo $serverStatus['uptime']; ?></p>
                            <p><strong>Max Spieler:</strong> <?php echo $serverStatus['max_players']; ?></p>
                        </div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h3>Online Spieler</h3>
                    </div>
                    <div class="card-content">
                        <div class="stat-number"><?php echo $onlinePlayers; ?></div>
                        <div class="stat-label">Aktuell online</div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h3>Registrierte Accounts</h3>
                    </div>
                    <div class="card-content">
                        <div class="stat-number"><?php echo $totalAccounts; ?></div>
                        <div class="stat-label">Gesamt Accounts</div>
                    </div>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <h3>Charaktere</h3>
                    </div>
                    <div class="card-content">
                        <div class="stat-number"><?php echo $totalCharacters; ?></div>
                        <div class="stat-label">Erstellte Charaktere</div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="quick-actions">
                <h3>Schnellzugriff</h3>
                <div class="action-grid">
                    <a href="players.php" class="action-card">
                        <div class="action-icon">👥</div>
                        <h4>Spieler verwalten</h4>
                        <p>Accounts und Berechtigungen verwalten</p>
                    </a>
                    <a href="characters.php" class="action-card">
                        <div class="action-icon">⚔️</div>
                        <h4>Charaktere</h4>
                        <p>Charaktere durchsuchen und verwalten</p>
                    </a>
                    <a href="database.php" class="action-card">
                        <div class="action-icon">🗄️</div>
                        <h4>Datenbank</h4>
                        <p>Quests, Items, Kreaturen durchsuchen</p>
                    </a>
                    <a href="plugins.php" class="action-card">
                        <div class="action-icon">🔌</div>
                        <h4>Plugins</h4>
                        <p>Zusätzliche Module verwalten</p>
                    </a>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="recent-activity">
                <h3>Letzte Aktivitäten</h3>
                <div class="activity-list">
                    <?php
                    try {
                        $db = DatabaseConfig::getAuthConnection();
                        $stmt = $db->prepare("
                            SELECT al.*, a.username 
                            FROM " . DatabaseConfig::getTableName('account_log') . " al
                            LEFT JOIN " . DatabaseConfig::getTableName('account') . " a ON al.account_id = a.id
                            ORDER BY al.timestamp DESC 
                            LIMIT 10
                        ");
                        $stmt->execute();
                        $activities = $stmt->fetchAll();
                        
                        if (empty($activities)) {
                            echo '<p class="no-data">Noch keine Aktivitäten vorhanden.</p>';
                        } else {
                            foreach ($activities as $activity) {
                                echo '<div class="activity-item">';
                                echo '<div class="activity-icon">👤</div>';
                                echo '<div class="activity-content">';
                                echo '<div class="activity-user">' . htmlspecialchars($activity['username'] ?? 'Unbekannt') . '</div>';
                                echo '<div class="activity-action">' . htmlspecialchars($activity['action']) . '</div>';
                                echo '<div class="activity-time">' . formatDate($activity['timestamp']) . '</div>';
                                echo '</div>';
                                echo '</div>';
                            }
                        }
                    } catch (Exception $e) {
                        echo '<p class="no-data">Aktivitäten konnten nicht geladen werden.</p>';
                    }
                    ?>
                </div>
            </div>
        </main>
    </div>

    <script src="assets/js/dashboard.js"></script>
</body>
</html>