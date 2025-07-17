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

-- Beispiel NPC Template (TrinityCore 3.3.5a - Minimale Spalten)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `faction_A`, `faction_H`, `minlevel`, `maxlevel`, `unit_class`, `AIName`) VALUES
(90001, 'Autonomer Krieger', 'Experimentelle KI', 55, 35, 35, 1, 20, 1, 'AutonomousPlayerAI'),
(90002, 'Autonomer Magier', 'Experimentelle KI', 49, 35, 35, 1, 20, 2, 'AutonomousPlayerAI'),
(90003, 'Autonomer Heiler', 'Experimentelle KI', 1257, 35, 35, 1, 20, 2, 'AutonomousPlayerAI'),
(90004, 'Autonomer Entdecker', 'Experimentelle KI', 1890, 35, 35, 1, 20, 1, 'AutonomousPlayerAI'),
(90005, 'Autonomer Händler', 'Experimentelle KI', 9991, 35, 35, 1, 20, 1, 'AutonomousPlayerAI');

-- Aktualisiere erweiterte Eigenschaften separat (nur existierende Spalten)
UPDATE `creature_template` SET 
  `mindmg` = 8, `maxdmg` = 12, `attackpower` = 18, `dmg_multiplier` = 1.0,
  `baseattacktime` = 2000, `rangeattacktime` = 2000, `unit_flags` = 0, `npcflag` = 0,
  `speed_walk` = 1.0, `speed_run` = 1.14, `scale` = 1.0, `rank` = 0, `dmgschool` = 0
WHERE `entry` = 90001;

UPDATE `creature_template` SET 
  `mindmg` = 6, `maxdmg` = 10, `attackpower` = 12, `dmg_multiplier` = 1.2,
  `baseattacktime` = 2000, `rangeattacktime` = 2000, `unit_flags` = 0, `npcflag` = 0,
  `speed_walk` = 1.0, `speed_run` = 1.14, `scale` = 1.0, `rank` = 0, `dmgschool` = 0
WHERE `entry` = 90002;

UPDATE `creature_template` SET 
  `mindmg` = 5, `maxdmg` = 8, `attackpower` = 13, `dmg_multiplier` = 0.8,
  `baseattacktime` = 2000, `rangeattacktime` = 2000, `unit_flags` = 0, `npcflag` = 0,
  `speed_walk` = 1.0, `speed_run` = 1.14, `scale` = 1.0, `rank` = 0, `dmgschool` = 0
WHERE `entry` = 90003;

UPDATE `creature_template` SET 
  `mindmg` = 7, `maxdmg` = 11, `attackpower` = 15, `dmg_multiplier` = 1.0,
  `baseattacktime` = 2000, `rangeattacktime` = 2000, `unit_flags` = 0, `npcflag` = 0,
  `speed_walk` = 1.0, `speed_run` = 1.14, `scale` = 1.0, `rank` = 0, `dmgschool` = 0
WHERE `entry` = 90004;

UPDATE `creature_template` SET 
  `mindmg` = 6, `maxdmg` = 9, `attackpower` = 14, `dmg_multiplier` = 0.9,
  `baseattacktime` = 2000, `rangeattacktime` = 2000, `unit_flags` = 0, `npcflag` = 0,
  `speed_walk` = 1.0, `speed_run` = 1.14, `scale` = 1.0, `rank` = 0, `dmgschool` = 0
WHERE `entry` = 90005;



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

-- Zusätzliche NPC-Varianten für verschiedene Fraktionen (TrinityCore 3.3.5a - Vereinfacht)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `faction_A`, `faction_H`, `minlevel`, `maxlevel`, `unit_class`, `AIName`) VALUES
-- Horde-Versionen
(90006, 'Autonomer Ork-Krieger', 'Experimentelle KI', 17, 85, 85, 1, 20, 1, 'AutonomousPlayerAI'),
(90007, 'Autonomer Untoten-Magier', 'Experimentelle KI', 57, 85, 85, 1, 20, 2, 'AutonomousPlayerAI'),
(90008, 'Autonomer Tauren-Schamane', 'Experimentelle KI', 59, 85, 85, 1, 20, 2, 'AutonomousPlayerAI'),
-- Neutrale Versionen
(90009, 'Autonomer Goblin-Händler', 'Experimentelle KI', 1141, 35, 35, 1, 20, 1, 'AutonomousPlayerAI'),
(90010, 'Autonomer Gnom-Erfinder', 'Experimentelle KI', 1563, 35, 35, 1, 20, 2, 'AutonomousPlayerAI');

-- Standard-Loot für autonome NPCs - entfernt wegen Kompatibilitätsproblemen
-- Verwende: sql/autonomous_npc_safe_loot.sql für Loot-Konfiguration

-- Logging-Kategorie für autonome NPCs
-- In Log.cpp sollte hinzugefügt werden:
-- { "autonomous.npc", 5, false }

COMMIT;