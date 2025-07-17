-- ===================================
-- Autonome NPC-KI für TrinityCore 3.3.5a
-- EXAKTES SQL Setup für Ihre DB-Struktur
-- ===================================

-- Tabellen für autonome NPCs
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
-- NPC Templates (Exakt für Ihre DB-Struktur)
-- ===================================

-- Lösche existierende Einträge falls vorhanden
DELETE FROM `creature_template` WHERE `entry` BETWEEN 90001 AND 90010;
DELETE FROM `creature` WHERE `id` BETWEEN 90001 AND 90010;
DELETE FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- Erstelle NPCs neu
INSERT INTO `creature_template` (
  `entry`, `name`, `subname`, `modelid1`, `modelid2`, `modelid3`, `modelid4`,
  `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, 
  `speed_walk`, `speed_run`, `scale`, `rank`, `dmgschool`,
  `BaseAttackTime`, `RangeAttackTime`, `BaseVariance`, `RangeVariance`,
  `unit_class`, `unit_flags`, `unit_flags2`, `dynamicflags`,
  `family`, `type`, `type_flags`,
  `HealthModifier`, `ManaModifier`, `ArmorModifier`, `DamageModifier`, `ExperienceModifier`,
  `AIName`, `MovementType`, `HoverHeight`, `RegenHealth`, `ScriptName`
) VALUES
-- Autonomer Krieger (Tank-orientiert)
(90001, 'Autonomer Krieger', 'Experimentelle KI', 55, 0, 0, 0,
 1, 20, 0, 35, 0,
 1.0, 1.14286, 1.0, 0, 0,
 2000, 2000, 1.0, 1.0,
 1, 0, 0, 0,
 0, 7, 0,
 1.5, 1.0, 1.2, 1.0, 1.0,
 'AutonomousPlayerAI', 0, 1.0, 1, ''),

-- Autonomer Magier (DPS-Caster)
(90002, 'Autonomer Magier', 'Experimentelle KI', 49, 0, 0, 0,
 1, 20, 0, 35, 0,
 1.0, 1.14286, 1.0, 0, 0,
 2000, 2000, 1.0, 1.0,
 2, 0, 0, 0,
 0, 7, 0,
 0.8, 1.5, 0.8, 1.3, 1.0,
 'AutonomousPlayerAI', 0, 1.0, 1, ''),

-- Autonomer Heiler (Support)
(90003, 'Autonomer Heiler', 'Experimentelle KI', 1257, 0, 0, 0,
 1, 20, 0, 35, 0,
 1.0, 1.14286, 1.0, 0, 0,
 2000, 2000, 1.0, 1.0,
 2, 0, 0, 0,
 0, 7, 0,
 1.2, 1.3, 1.0, 0.9, 1.0,
 'AutonomousPlayerAI', 0, 1.0, 1, ''),

-- Autonomer Entdecker (Ausgewogen)
(90004, 'Autonomer Entdecker', 'Experimentelle KI', 1890, 0, 0, 0,
 1, 20, 0, 35, 0,
 1.0, 1.14286, 1.0, 0, 0,
 2000, 2000, 1.0, 1.0,
 1, 0, 0, 0,
 0, 7, 0,
 1.0, 1.0, 1.0, 1.0, 1.0,
 'AutonomousPlayerAI', 1, 1.0, 1, ''),

-- Autonomer Händler (Sozial)
(90005, 'Autonomer Händler', 'Experimentelle KI', 9991, 0, 0, 0,
 1, 20, 0, 35, 0,
 1.0, 1.14286, 1.0, 0, 0,
 2000, 2000, 1.0, 1.0,
 1, 0, 0, 0,
 0, 7, 0,
 1.1, 1.1, 1.0, 0.95, 1.0,
 'AutonomousPlayerAI', 0, 1.0, 1, '');

-- ===================================
-- Erweiterte NPCs (Horde/Neutral)
-- ===================================

-- Erweiterte NPCs (ersetze falls vorhanden)
REPLACE INTO `creature_template` (
  `entry`, `name`, `subname`, `modelid1`,
  `minlevel`, `maxlevel`, `faction`, `unit_class`,
  `HealthModifier`, `ManaModifier`, `ArmorModifier`, `DamageModifier`,
  `AIName`, `RegenHealth`
) VALUES
-- Horde-Versionen
(90006, 'Autonomer Ork-Krieger', 'Experimentelle KI', 17, 1, 20, 85, 1, 1.5, 1.0, 1.2, 1.0, 'AutonomousPlayerAI', 1),
(90007, 'Autonomer Untoten-Magier', 'Experimentelle KI', 57, 1, 20, 85, 2, 0.8, 1.5, 0.8, 1.3, 'AutonomousPlayerAI', 1),
(90008, 'Autonomer Tauren-Schamane', 'Experimentelle KI', 59, 1, 20, 85, 2, 1.2, 1.3, 1.0, 0.9, 'AutonomousPlayerAI', 1),
-- Neutrale Versionen
(90009, 'Autonomer Goblin-Händler', 'Experimentelle KI', 1141, 1, 20, 35, 1, 1.1, 1.1, 1.0, 0.95, 'AutonomousPlayerAI', 1),
(90010, 'Autonomer Gnom-Erfinder', 'Experimentelle KI', 1563, 1, 20, 35, 2, 0.8, 1.5, 0.8, 1.3, 'AutonomousPlayerAI', 1);

-- ===================================
-- Spawn-Punkte
-- ===================================

-- Spawn-Punkte (ersetze falls vorhanden)  
REPLACE INTO `creature` (`id`, `map`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`) VALUES
-- Basis NPCs (Elwynn Forest)
(90001, 0, -9449.06, -1346.62, 46.27, 4.71, 300),  -- Autonomer Krieger bei Goldshire
(90002, 0, -9789.17, -943.19, 41.78, 1.57, 300),   -- Autonomer Magier beim Kristallsee
(90003, 0, -8906.95, -197.52, 80.66, 3.14, 300),   -- Autonomer Heiler bei der Abtei
(90004, 0, -9531.28, -831.45, 53.42, 0.79, 300),   -- Autonomer Entdecker am Waldrand
(90005, 0, -9463.84, -1356.17, 46.84, 2.35, 300);  -- Autonomer Händler in Goldshire

-- ===================================
-- Loot-Tabellen
-- ===================================

-- Loot-Tabellen (ersetze falls vorhanden)
REPLACE INTO `creature_loot_template` (`entry`, `item`, `ChanceOrQuestChance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(90001, 25, 100, 1, 0, 1, 4),  -- Silber
(90002, 25, 100, 1, 0, 1, 4),
(90003, 25, 100, 1, 0, 1, 4),
(90004, 25, 100, 1, 0, 1, 4),
(90005, 25, 100, 1, 0, 1, 4),
(90006, 25, 100, 1, 0, 1, 4),
(90007, 25, 100, 1, 0, 1, 4),
(90008, 25, 100, 1, 0, 1, 4),
(90009, 25, 100, 1, 0, 1, 4),
(90010, 25, 100, 1, 0, 1, 4);

-- ===================================
-- Validierung
-- ===================================

-- Prüfe ob NPCs korrekt erstellt wurden
SELECT entry, name, AIName, minlevel, maxlevel, HealthModifier, unit_class, faction 
FROM creature_template 
WHERE entry BETWEEN 90001 AND 90010;

-- Prüfe Spawn-Punkte
SELECT id, map, position_x, position_y, position_z 
FROM creature 
WHERE id BETWEEN 90001 AND 90005;

-- ===================================
-- Test-Befehle (Ingame als GM)
-- ===================================

-- .npc add 90001  -- Spawnt autonomen Krieger
-- .npc add 90002  -- Spawnt autonomen Magier
-- .npc add 90003  -- Spawnt autonomen Heiler
-- .npc add 90004  -- Spawnt autonomen Entdecker
-- .npc add 90005  -- Spawnt autonomen Händler

-- .npc info       -- Zeigt NPC-Informationen (sollte AutonomousPlayerAI zeigen)

COMMIT;