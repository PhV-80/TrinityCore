-- ===================================
-- Autonome NPC-KI Update-Skript
-- Aktualisiert bereits existierende NPCs
-- ===================================

-- Aktualisiere AIName für alle autonomen NPCs
UPDATE `creature_template` SET `AIName` = 'AutonomousPlayerAI' WHERE `entry` BETWEEN 90001 AND 90010;

-- Aktualisiere NPC-Eigenschaften basierend auf Ihrer DB-Struktur
-- Autonomer Krieger (Tank-orientiert)
UPDATE `creature_template` SET 
  `name` = 'Autonomer Krieger',
  `subname` = 'Experimentelle KI',
  `modelid1` = 55,
  `minlevel` = 1,
  `maxlevel` = 20,
  `faction` = 35,
  `unit_class` = 1,
  `HealthModifier` = 1.5,
  `ManaModifier` = 1.0,
  `ArmorModifier` = 1.2,
  `DamageModifier` = 1.0,
  `BaseAttackTime` = 2000,
  `RangeAttackTime` = 2000,
  `speed_walk` = 1.0,
  `speed_run` = 1.14286,
  `scale` = 1.0,
  `RegenHealth` = 1
WHERE `entry` = 90001;

-- Autonomer Magier (DPS-Caster)
UPDATE `creature_template` SET 
  `name` = 'Autonomer Magier',
  `subname` = 'Experimentelle KI',
  `modelid1` = 49,
  `minlevel` = 1,
  `maxlevel` = 20,
  `faction` = 35,
  `unit_class` = 2,
  `HealthModifier` = 0.8,
  `ManaModifier` = 1.5,
  `ArmorModifier` = 0.8,
  `DamageModifier` = 1.3,
  `BaseAttackTime` = 2000,
  `RangeAttackTime` = 2000,
  `speed_walk` = 1.0,
  `speed_run` = 1.14286,
  `scale` = 1.0,
  `RegenHealth` = 1
WHERE `entry` = 90002;

-- Autonomer Heiler (Support)
UPDATE `creature_template` SET 
  `name` = 'Autonomer Heiler',
  `subname` = 'Experimentelle KI',
  `modelid1` = 1257,
  `minlevel` = 1,
  `maxlevel` = 20,
  `faction` = 35,
  `unit_class` = 2,
  `HealthModifier` = 1.2,
  `ManaModifier` = 1.3,
  `ArmorModifier` = 1.0,
  `DamageModifier` = 0.9,
  `BaseAttackTime` = 2000,
  `RangeAttackTime` = 2000,
  `speed_walk` = 1.0,
  `speed_run` = 1.14286,
  `scale` = 1.0,
  `RegenHealth` = 1
WHERE `entry` = 90003;

-- Autonomer Entdecker (Ausgewogen)
UPDATE `creature_template` SET 
  `name` = 'Autonomer Entdecker',
  `subname` = 'Experimentelle KI',
  `modelid1` = 1890,
  `minlevel` = 1,
  `maxlevel` = 20,
  `faction` = 35,
  `unit_class` = 1,
  `HealthModifier` = 1.0,
  `ManaModifier` = 1.0,
  `ArmorModifier` = 1.0,
  `DamageModifier` = 1.0,
  `BaseAttackTime` = 2000,
  `RangeAttackTime` = 2000,
  `speed_walk` = 1.0,
  `speed_run` = 1.14286,
  `scale` = 1.0,
  `MovementType` = 1,
  `RegenHealth` = 1
WHERE `entry` = 90004;

-- Autonomer Händler (Sozial)
UPDATE `creature_template` SET 
  `name` = 'Autonomer Händler',
  `subname` = 'Experimentelle KI',
  `modelid1` = 9991,
  `minlevel` = 1,
  `maxlevel` = 20,
  `faction` = 35,
  `unit_class` = 1,
  `HealthModifier` = 1.1,
  `ManaModifier` = 1.1,
  `ArmorModifier` = 1.0,
  `DamageModifier` = 0.95,
  `BaseAttackTime` = 2000,
  `RangeAttackTime` = 2000,
  `speed_walk` = 1.0,
  `speed_run` = 1.14286,
  `scale` = 1.0,
  `RegenHealth` = 1
WHERE `entry` = 90005;

-- Stelle sicher, dass Spawn-Punkte existieren (falls noch nicht vorhanden)
INSERT IGNORE INTO `creature` (`id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`) VALUES
(90001, 0, -9449.06, -1346.62, 46.27, 4.71, 300),  -- Autonomer Krieger bei Goldshire
(90002, 0, -9789.17, -943.19, 41.78, 1.57, 300),   -- Autonomer Magier beim Kristallsee
(90003, 0, -8906.95, -197.52, 80.66, 3.14, 300),   -- Autonomer Heiler bei der Abtei
(90004, 0, -9531.28, -831.45, 53.42, 0.79, 300),   -- Autonomer Entdecker am Waldrand
(90005, 0, -9463.84, -1356.17, 46.84, 2.35, 300);  -- Autonomer Händler in Goldshire

-- Erstelle Lerndaten-Tabellen falls noch nicht vorhanden
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

-- Loot-Tabellen aktualisieren (TrinityCore 3.3.5a korrekte Spalten)
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(90001, 25, 100, 1, 0, 1, 4),  -- Silber
(90002, 25, 100, 1, 0, 1, 4),
(90003, 25, 100, 1, 0, 1, 4),
(90004, 25, 100, 1, 0, 1, 4),
(90005, 25, 100, 1, 0, 1, 4);

-- Validierung
SELECT entry, name, AIName, minlevel, maxlevel, HealthModifier, unit_class, faction 
FROM creature_template 
WHERE entry BETWEEN 90001 AND 90005;

-- Prüfe Spawn-Punkte
SELECT id, map, position_x, position_y, position_z 
FROM creature 
WHERE id BETWEEN 90001 AND 90005;

COMMIT;