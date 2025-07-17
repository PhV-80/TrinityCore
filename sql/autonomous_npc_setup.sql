-- ===================================
-- Autonome NPC-KI für TrinityCore 3.3.5a
-- SQL Setup-Skript
-- ===================================

-- Tabelle für die Lerndaten der autonomen NPCs
CREATE TABLE IF NOT EXISTS `autonomous_npc_learning` (
  `npc_guid` int(10) unsigned NOT NULL COMMENT 'GUID des NPCs',
  `total_combats` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Gesamtanzahl Kämpfe',
  `wins` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Anzahl Siege',
  `losses` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Anzahl Niederlagen',
  `average_combat_time` float NOT NULL DEFAULT '0' COMMENT 'Durchschnittliche Kampfzeit in ms',
  `primary_role` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Primäre Rolle (AutonomousRole enum)',
  `secondary_role` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Sekundäre Rolle',
  `personality_aggressiveness` tinyint(3) unsigned NOT NULL DEFAULT '50' COMMENT 'Aggressivität 0-100',
  `personality_curiosity` tinyint(3) unsigned NOT NULL DEFAULT '50' COMMENT 'Neugier 0-100',
  `personality_sociability` tinyint(3) unsigned NOT NULL DEFAULT '50' COMMENT 'Sozialität 0-100',
  `personality_intelligence` tinyint(3) unsigned NOT NULL DEFAULT '50' COMMENT 'Intelligenz 0-100',
  `personality_patience` tinyint(3) unsigned NOT NULL DEFAULT '50' COMMENT 'Geduld 0-100',
  `visited_zones` text COMMENT 'JSON Array der besuchten Zonen',
  `zone_preferences` text COMMENT 'JSON Object der Zonenpräferenzen',
  `learned_phrases` text COMMENT 'JSON Array der gelernten Chat-Phrasen',
  `last_save_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`npc_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Lerndaten für autonome NPCs';

-- Tabelle für Zaubereffektivität
CREATE TABLE IF NOT EXISTS `autonomous_npc_spell_data` (
  `npc_guid` int(10) unsigned NOT NULL,
  `spell_id` int(10) unsigned NOT NULL,
  `usage_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Wie oft verwendet',
  `success_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Wie oft erfolgreich',
  `effectiveness_score` float NOT NULL DEFAULT '50.0' COMMENT 'Effektivitätsbewertung 0-100',
  `last_used` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`npc_guid`, `spell_id`),
  KEY `idx_npc_spell` (`npc_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Zauberstatistiken für autonome NPCs';

-- Tabelle für soziale Beziehungen
CREATE TABLE IF NOT EXISTS `autonomous_npc_relationships` (
  `npc_guid` int(10) unsigned NOT NULL,
  `player_guid` int(10) unsigned NOT NULL,
  `relationship_value` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Beziehungswert -100 bis +100',
  `interaction_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Anzahl Interaktionen',
  `last_interaction` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`npc_guid`, `player_guid`),
  KEY `idx_npc_relationships` (`npc_guid`),
  KEY `idx_player_relationships` (`player_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Soziale Beziehungen autonomer NPCs';

-- Tabelle für Kampfhistorie
CREATE TABLE IF NOT EXISTS `autonomous_npc_combat_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `npc_guid` int(10) unsigned NOT NULL,
  `enemy_entry` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entry des Gegners',
  `enemy_level` tinyint(3) unsigned NOT NULL DEFAULT '1' COMMENT 'Level des Gegners',
  `damage_dealt` int(10) unsigned NOT NULL DEFAULT '0',
  `damage_taken` int(10) unsigned NOT NULL DEFAULT '0',
  `healing_done` int(10) unsigned NOT NULL DEFAULT '0',
  `mana_used` int(10) unsigned NOT NULL DEFAULT '0',
  `combat_duration` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Kampfzeit in ms',
  `victory` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1 = Sieg, 0 = Niederlage',
  `spells_used` text COMMENT 'JSON Array der verwendeten Zauber',
  `combat_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_npc_combat` (`npc_guid`),
  KEY `idx_combat_time` (`combat_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Kampfhistorie autonomer NPCs';

-- ===================================
-- Test-NPCs für autonome KI
-- ===================================

-- Beispiel NPC Template
REPLACE INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `unit_class`, `unit_flags`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `dmgschool`, `BaseAttackTime`, `RangeAttackTime`, `unit_flags2`, `AIName`, `ScriptName`) VALUES
(90001, 'Autonomer Krieger', 'Experimentelle KI', 55, 1, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90002, 'Autonomer Magier', 'Experimentelle KI', 49, 2, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90003, 'Autonomer Heiler', 'Experimentelle KI', 1257, 2, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90004, 'Autonomer Entdecker', 'Experimentelle KI', 1890, 1, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90005, 'Autonomer Händler', 'Experimentelle KI', 9991, 1, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', '');

-- Grundlegende Stat-Templates für die Test-NPCs
REPLACE INTO `creature_template_stats` (`entry`, `level`, `hp`, `mana`, `armor`, `str`, `agi`, `sta`, `inte`, `spi`) VALUES
-- Krieger (90001) - Tank-orientiert
(90001, 1, 100, 0, 15, 18, 14, 17, 11, 13),
(90001, 5, 180, 0, 45, 22, 16, 21, 13, 15),
(90001, 10, 320, 0, 85, 28, 20, 27, 15, 17),
(90001, 15, 480, 0, 135, 34, 24, 33, 17, 19),
(90001, 20, 680, 0, 195, 42, 28, 41, 19, 21),

-- Magier (90002) - DPS-orientiert
(90002, 1, 60, 150, 8, 12, 13, 14, 20, 16),
(90002, 5, 110, 280, 24, 14, 15, 16, 26, 20),
(90002, 10, 190, 450, 44, 16, 17, 18, 34, 26),
(90002, 15, 280, 640, 70, 18, 19, 20, 42, 32),
(90002, 20, 390, 850, 100, 20, 21, 22, 52, 40),

-- Heiler (90003) - Heiler-orientiert
(90003, 1, 80, 130, 10, 13, 12, 15, 18, 19),
(90003, 5, 140, 240, 30, 15, 14, 17, 24, 25),
(90003, 10, 240, 390, 55, 17, 16, 19, 32, 33),
(90003, 15, 360, 560, 85, 19, 18, 21, 40, 41),
(90003, 20, 500, 750, 120, 21, 20, 23, 50, 51),

-- Entdecker (90004) - Ausgewogen
(90004, 1, 90, 80, 12, 15, 16, 16, 14, 15),
(90004, 5, 160, 140, 36, 19, 20, 20, 16, 17),
(90004, 10, 280, 220, 65, 25, 26, 26, 18, 19),
(90004, 15, 420, 320, 100, 31, 32, 32, 20, 21),
(90004, 20, 580, 440, 140, 39, 40, 40, 22, 23),

-- Händler (90005) - Sozial-orientiert
(90005, 1, 85, 100, 11, 14, 15, 15, 16, 17),
(90005, 5, 150, 180, 33, 16, 17, 17, 20, 21),
(90005, 10, 260, 280, 60, 18, 19, 19, 26, 27),
(90005, 15, 390, 400, 92, 20, 21, 21, 32, 33),
(90005, 20, 540, 540, 130, 22, 23, 23, 40, 41);

-- Spawn-Punkte für Test-NPCs (Elwynn Forest - Goldshire Umgebung)
INSERT INTO `creature` (`id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`) VALUES
-- Autonomer Krieger bei Goldshire
(90001, 0, -9449.06, -1346.62, 46.27, 4.71, 300),
-- Autonomer Magier beim Kristallsee
(90002, 0, -9789.17, -943.19, 41.78, 1.57, 300),
-- Autonomer Heiler bei der Abtei von Nordkloster
(90003, 0, -8906.95, -197.52, 80.66, 3.14, 300),
-- Autonomer Entdecker am Waldrand
(90004, 0, -9531.28, -831.45, 53.42, 0.79, 300),
-- Autonomer Händler in Goldshire (Gasthaus-Nähe)
(90005, 0, -9463.84, -1356.17, 46.84, 2.35, 300);

-- ===================================
-- Konfiguration für worldserver.conf
-- ===================================

-- Die folgenden Zeilen sollten in worldserver.conf hinzugefügt werden:
-- 
-- ###################################################################################################
-- # AUTONOME NPC EINSTELLUNGEN
-- ###################################################################################################
-- 
-- # Maximale Anzahl aktiver autonomer NPCs
-- AutonomousNPC.MaxCount = 25
-- 
-- # Respektiere Spielerkapazität des Servers
-- AutonomousNPC.RespectPlayerCap = 1
-- 
-- # Automatisches Ausloggen bei Spielerlimit
-- AutonomousNPC.AutoLogoutOnPlayerLimit = 1
-- 
-- # Lerndaten in Datenbank persistieren
-- AutonomousNPC.PersistLearningData = 1
-- 
-- # Debug-Logging aktivieren (0 = Aus, 1 = An)
-- AutonomousNPC.EnableDebugLogging = 0
-- 
-- # Chat-Lernen aktivieren
-- AutonomousNPC.EnableChatLearning = 1
-- AutonomousNPC.MaxLearnedPhrases = 100
-- AutonomousNPC.ChatResponseChance = 30
-- 
-- # Kampf-Lernen aktivieren
-- AutonomousNPC.EnableCombatLearning = 1
-- AutonomousNPC.MaxCombatHistory = 50
-- AutonomousNPC.AggressiveMode = 0
-- 
-- # Exploration aktivieren
-- AutonomousNPC.EnableExploration = 1
-- AutonomousNPC.ExplorationRadius = 100.0
-- AutonomousNPC.ExplorationCooldown = 15000
-- 
-- # Soziale Interaktion aktivieren
-- AutonomousNPC.EnableSocialInteraction = 1
-- AutonomousNPC.SocialInteractionRadius = 15.0
-- AutonomousNPC.RelationshipDecayTime = 86400000
-- 
-- # Performance-Einstellungen (in Millisekunden)
-- AutonomousNPC.AIUpdateInterval = 2000
-- AutonomousNPC.LearningUpdateInterval = 5000
-- AutonomousNPC.SocialUpdateInterval = 10000
-- 
-- # Datenbank-Einstellungen
-- AutonomousNPC.LearningDataTable = "autonomous_npc_learning"
-- AutonomousNPC.SaveInterval = 300000
-- 
-- ###################################################################################################

-- Bereinigung und Test-Kommandos
-- Zum Testen der NPCs:
-- .npc add 90001  (Spawnt einen autonomen Krieger)
-- .npc add 90002  (Spawnt einen autonomen Magier)
-- .npc add 90003  (Spawnt einen autonomen Heiler)

-- Zum Löschen aller Test-NPCs:
-- DELETE FROM creature WHERE id BETWEEN 90001 AND 90005;

-- Zum Zurücksetzen der Lerndaten:
-- DELETE FROM autonomous_npc_learning;
-- DELETE FROM autonomous_npc_spell_data;
-- DELETE FROM autonomous_npc_relationships;
-- DELETE FROM autonomous_npc_combat_history;

-- ===================================
-- Erweiterte NPC-Einstellungen
-- ===================================

-- Zusätzliche NPC-Varianten für verschiedene Fraktionen
REPLACE INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `unit_class`, `unit_flags`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `dmgschool`, `BaseAttackTime`, `RangeAttackTime`, `unit_flags2`, `AIName`, `ScriptName`) VALUES
-- Horde-Versionen
(90006, 'Autonomer Ork-Krieger', 'Experimentelle KI', 17, 1, 0, 85, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90007, 'Autonomer Untoten-Magier', 'Experimentelle KI', 57, 2, 0, 85, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90008, 'Autonomer Tauren-Schamane', 'Experimentelle KI', 59, 2, 0, 85, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),

-- Neutrale Versionen
(90009, 'Autonomer Goblin-Händler', 'Experimentelle KI', 1141, 1, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', ''),
(90010, 'Autonomer Gnom-Erfinder', 'Experimentelle KI', 1563, 2, 0, 35, 0, 1.0, 1.14, 1.0, 0, 0, 2000, 2000, 0, 'AutonomousPlayerAI', '');

-- Standard-Loot für autonome NPCs (sie droppen normale Gegenstände wie NPCs ihres Levels)
REPLACE INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(90001, 25, 100, 1, 0, 1, 4),  -- Silber
(90002, 25, 100, 1, 0, 1, 4),  -- Silber  
(90003, 25, 100, 1, 0, 1, 4),  -- Silber
(90004, 25, 100, 1, 0, 1, 4),  -- Silber
(90005, 25, 100, 1, 0, 1, 4);  -- Silber

-- Logging-Kategorie für autonome NPCs
-- In Log.cpp sollte hinzugefügt werden:
-- { "autonomous.npc", 5, false }

COMMIT;