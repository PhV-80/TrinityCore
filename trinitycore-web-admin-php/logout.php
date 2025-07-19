<?php
require_once 'includes/functions.php';

// Log the logout activity
if (isLoggedIn()) {
    logActivity(getCurrentUserId(), 'logout', 'Web logout');
}

// Destroy session
startSession();
session_destroy();

// Redirect to login page
redirect('index.php');
?>