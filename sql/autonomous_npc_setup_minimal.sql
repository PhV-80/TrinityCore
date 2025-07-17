-- ===================================
-- Autonome NPC-KI für TrinityCore 3.3.5a
-- MINIMALE SQL Setup-Version (Nur notwendige Spalten)
-- ===================================

-- Tabellen für autonome NPCs (unverändert - diese sind neu)
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
-- MINIMALE NPC Templates (nur absolut notwendige Spalten)
-- ===================================

-- Prüfe zunächst, welche Spalten existieren
-- BESCHREIBUNG: Führe vor diesem Skript aus: DESCRIBE creature_template;

-- Basis-NPCs (nur notwendige Spalten)
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `AIName`) VALUES
(90001, 'Autonomer Krieger', 'Experimentelle KI', 'AutonomousPlayerAI'),
(90002, 'Autonomer Magier', 'Experimentelle KI', 'AutonomousPlayerAI'),
(90003, 'Autonomer Heiler', 'Experimentelle KI', 'AutonomousPlayerAI'),
(90004, 'Autonomer Entdecker', 'Experimentelle KI', 'AutonomousPlayerAI'),
(90005, 'Autonomer Händler', 'Experimentelle KI', 'AutonomousPlayerAI');

-- Versuche häufige optionale Spalten zu setzen (Ignoriere Fehler)
-- Modell-IDs
UPDATE `creature_template` SET `modelid1` = 55 WHERE `entry` = 90001;
UPDATE `creature_template` SET `modelid1` = 49 WHERE `entry` = 90002;
UPDATE `creature_template` SET `modelid1` = 1257 WHERE `entry` = 90003;
UPDATE `creature_template` SET `modelid1` = 1890 WHERE `entry` = 90004;
UPDATE `creature_template` SET `modelid1` = 9991 WHERE `entry` = 90005;

-- Level (wenn Spalten existieren)
UPDATE `creature_template` SET `minlevel` = 1, `maxlevel` = 20 WHERE `entry` BETWEEN 90001 AND 90005;

-- Fraktion (versuche verschiedene Spaltennamen)
UPDATE `creature_template` SET `faction_A` = 35, `faction_H` = 35 WHERE `entry` BETWEEN 90001 AND 90005;
-- Fallback für ältere Versionen:
UPDATE `creature_template` SET `faction` = 35 WHERE `entry` BETWEEN 90001 AND 90005;

-- Klasse
UPDATE `creature_template` SET `unit_class` = 1 WHERE `entry` IN (90001, 90004, 90005); -- Krieger
UPDATE `creature_template` SET `unit_class` = 2 WHERE `entry` IN (90002, 90003); -- Magier/Priester

-- Spawn-Punkte (einfach)
INSERT INTO `creature` (`id`, `map`, `position_x`, `position_y`, `position_z`) VALUES
(90001, 0, -9449.06, -1346.62, 46.27),  -- Goldshire
(90002, 0, -9789.17, -943.19, 41.78),   -- Kristallsee
(90003, 0, -8906.95, -197.52, 80.66),   -- Nordkloster
(90004, 0, -9531.28, -831.45, 53.42),   -- Wald
(90005, 0, -9463.84, -1356.17, 46.84);  -- Goldshire Gasthaus

-- ===================================
-- ANWEISUNGEN FÜR MANUELLEN GEBRAUCH
-- ===================================

-- 1. Führe aus: DESCRIBE creature_template;
-- 2. Notiere dir die verfügbaren Spalten
-- 3. Passe die UPDATE-Statements entsprechend an
-- 4. Führe nur die Teile aus, die zu deiner DB-Struktur passen

-- Häufige TrinityCore 3.3.5a Spalten:
-- `entry`, `name`, `subname`, `modelid1`, `modelid2`, `modelid3`, `modelid4`
-- `faction_A`, `faction_H` ODER `faction`
-- `minlevel`, `maxlevel`
-- `unit_class`, `unit_flags`
-- `AIName`, `ScriptName`
-- `speed_walk`, `speed_run`, `scale`
-- `mindmg`, `maxdmg`, `attackpower`
-- `baseattacktime`, `rangeattacktime`

-- Test nach Installation:
-- .npc add 90001
-- .npc info (sollte AutonomousPlayerAI zeigen)

COMMIT;