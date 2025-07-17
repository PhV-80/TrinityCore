-- ===================================
-- KOMPLETTES AUTONOME NPC SYSTEM
-- TrinityCore 3.3.5a - Finale Version
-- Alle notwendigen Befehle in einer Datei
-- ===================================

-- ===================================
-- 1. DATENBANK-TABELLEN ERSTELLEN
-- ===================================

-- Erstelle Tabelle für Lernverhalten der autonomen NPCs
CREATE TABLE IF NOT EXISTS `autonomous_npc_learning` (
    `npc_guid` int(10) unsigned NOT NULL,
    `personality_aggressiveness` tinyint(3) unsigned DEFAULT 50,
    `personality_curiosity` tinyint(3) unsigned DEFAULT 50,
    `personality_sociability` tinyint(3) unsigned DEFAULT 50,
    `personality_intelligence` tinyint(3) unsigned DEFAULT 50,
    `personality_patience` tinyint(3) unsigned DEFAULT 50,
    `current_role` varchar(20) DEFAULT 'Unknown',
    `learning_phase` tinyint(3) unsigned DEFAULT 0,
    `experience_points` int(10) unsigned DEFAULT 0,
    `combat_wins` int(10) unsigned DEFAULT 0,
    `combat_losses` int(10) unsigned DEFAULT 0,
    `social_interactions` int(10) unsigned DEFAULT 0,
    `exploration_distance` float DEFAULT 0,
    `last_behavior_change` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`npc_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Autonome NPC Lerndaten';

-- Erstelle Tabelle für Zauber-Effizienz
CREATE TABLE IF NOT EXISTS `autonomous_npc_spell_data` (
    `npc_guid` int(10) unsigned NOT NULL,
    `spell_id` int(10) unsigned NOT NULL,
    `times_used` int(10) unsigned DEFAULT 0,
    `times_successful` int(10) unsigned DEFAULT 0,
    `total_damage` bigint(20) unsigned DEFAULT 0,
    `total_healing` bigint(20) unsigned DEFAULT 0,
    `last_used` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`npc_guid`, `spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Autonome NPC Zauber-Statistiken';

-- Erstelle Tabelle für soziale Beziehungen
CREATE TABLE IF NOT EXISTS `autonomous_npc_relationships` (
    `npc_guid` int(10) unsigned NOT NULL,
    `player_guid` int(10) unsigned NOT NULL,
    `relationship_value` tinyint(4) DEFAULT 0,
    `interactions_count` int(10) unsigned DEFAULT 0,
    `last_interaction` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`npc_guid`, `player_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Autonome NPC Spieler-Beziehungen';

-- Erstelle Tabelle für Kampf-Historie
CREATE TABLE IF NOT EXISTS `autonomous_npc_combat_history` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `npc_guid` int(10) unsigned NOT NULL,
    `enemy_entry` int(10) unsigned NOT NULL,
    `combat_result` tinyint(1) unsigned NOT NULL,
    `damage_dealt` int(10) unsigned DEFAULT 0,
    `damage_taken` int(10) unsigned DEFAULT 0,
    `combat_duration` int(10) unsigned DEFAULT 0,
    `spells_used` varchar(255) DEFAULT '',
    `combat_timestamp` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_npc_guid` (`npc_guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Autonome NPC Kampf-Historie';

-- ===================================
-- 2. CREATURE TEMPLATES ERSTELLEN
-- ===================================

-- Lösche existierende autonome NPCs
DELETE FROM `creature_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- Erstelle autonome NPC Templates
INSERT INTO `creature_template` (
    `entry`, `difficulty_entry_1`, `difficulty_entry_2`, `difficulty_entry_3`, 
    `KillCredit1`, `KillCredit2`, `modelid1`, `modelid2`, `modelid3`, `modelid4`, 
    `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, 
    `exp`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, 
    `mindmg`, `maxdmg`, `dmgschool`, `attackpower`, `dmg_multiplier`, 
    `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`, `unit_flags2`, 
    `dynamicflags`, `family`, `trainer_type`, `trainer_spell`, `trainer_class`, 
    `trainer_race`, `minrangedmg`, `maxrangedmg`, `rangedattackpower`, 
    `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, 
    `resistance1`, `resistance2`, `resistance3`, `resistance4`, `resistance5`, `resistance6`, 
    `spell1`, `spell2`, `spell3`, `spell4`, `spell5`, `spell6`, `spell7`, `spell8`, 
    `PetSpellDataId`, `VehicleId`, `mingold`, `maxgold`, `AIName`, `MovementType`, 
    `InhabitType`, `HoverHeight`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, 
    `DamageModifier`, `ExperienceModifier`, `RacialLeader`, `questItem1`, `questItem2`, 
    `questItem3`, `questItem4`, `questItem5`, `questItem6`, `movementId`, `RegenHealth`, 
    `mechanic_immune_mask`, `flags_extra`, `ScriptName`, `WDBVerified`
) VALUES
-- Autonomer Krieger (Tank-Role)
(90001, 0, 0, 0, 0, 0, 1478, 0, 0, 0, 'Autonomer Krieger', 'Selbstlernende KI', '', 0, 10, 15, 0, 35, 0, 1.0, 1.14286, 1, 0, 24, 35, 0, 42, 1, 2000, 2000, 1, 0, 0, 0, 0, 0, 0, 0, 0, 18, 27, 14, 7, 0, 90001, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 25, 'AutonomousPlayerAI', 1, 3, 1, 2.5, 1.0, 1.5, 1.2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Magier (DPS-Caster)
(90002, 0, 0, 0, 0, 0, 1501, 0, 0, 0, 'Autonomer Magier', 'Selbstlernende KI', '', 0, 10, 15, 0, 35, 0, 1.0, 1.14286, 1, 0, 18, 28, 0, 32, 1, 2000, 2000, 8, 0, 0, 0, 0, 0, 0, 0, 0, 14, 21, 11, 7, 0, 90002, 0, 0, 0, 0, 0, 0, 0, 0, 0, 133, 168, 116, 0, 0, 0, 0, 0, 0, 12, 20, 'AutonomousPlayerAI', 1, 3, 1, 1.8, 2.5, 1.0, 1.5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Heiler (Support)
(90003, 0, 0, 0, 0, 0, 1699, 0, 0, 0, 'Autonomer Heiler', 'Selbstlernende KI', '', 0, 10, 15, 0, 35, 0, 1.0, 1.14286, 1, 0, 20, 30, 0, 36, 1, 2000, 2000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 15, 23, 12, 7, 0, 90003, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2061, 2054, 594, 0, 0, 0, 0, 0, 0, 13, 22, 'AutonomousPlayerAI', 1, 3, 1, 2.2, 2.2, 1.2, 1.0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Entdecker (Explorer)
(90004, 0, 0, 0, 0, 0, 1547, 0, 0, 0, 'Autonomer Entdecker', 'Selbstlernende KI', '', 0, 8, 12, 0, 35, 0, 1.2, 1.28571, 1, 0, 20, 30, 0, 36, 1, 1800, 1800, 1, 0, 0, 0, 0, 0, 0, 0, 0, 15, 23, 12, 7, 0, 90004, 0, 0, 0, 0, 0, 0, 0, 0, 0, 75, 6603, 0, 0, 0, 0, 0, 0, 0, 10, 18, 'AutonomousPlayerAI', 1, 3, 1, 1.8, 1.5, 1.0, 1.1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Händler (Trader)
(90005, 0, 0, 0, 0, 0, 1647, 0, 0, 0, 'Autonomer Händler', 'Selbstlernende KI', '', 0, 8, 12, 0, 35, 0, 1.0, 1.14286, 1, 0, 18, 26, 0, 32, 1, 2000, 2000, 1, 0, 0, 0, 0, 0, 0, 0, 0, 14, 20, 11, 7, 0, 90005, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 20, 'AutonomousPlayerAI', 1, 3, 1, 1.5, 1.5, 1.0, 0.8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Horde Varianten
-- Autonomer Ork-Krieger
(90006, 0, 0, 0, 0, 0, 1563, 0, 0, 0, 'Autonomer Ork-Krieger', 'Selbstlernende KI', '', 0, 10, 15, 0, 85, 0, 1.0, 1.14286, 1, 0, 26, 37, 0, 44, 1, 2000, 2000, 1, 0, 0, 0, 0, 0, 0, 0, 0, 19, 29, 15, 7, 0, 90006, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 26, 'AutonomousPlayerAI', 1, 3, 1, 2.5, 1.0, 1.5, 1.2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Untoten-Magier
(90007, 0, 0, 0, 0, 0, 1560, 0, 0, 0, 'Autonomer Untoten-Magier', 'Selbstlernende KI', '', 0, 10, 15, 0, 68, 0, 1.0, 1.14286, 1, 0, 18, 28, 0, 32, 1, 2000, 2000, 8, 0, 0, 0, 0, 0, 0, 0, 0, 14, 21, 11, 6, 0, 90007, 0, 0, 0, 0, 0, 0, 0, 0, 0, 133, 168, 116, 0, 0, 0, 0, 0, 0, 12, 20, 'AutonomousPlayerAI', 1, 3, 1, 1.8, 2.5, 1.0, 1.5, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Tauren-Schamane
(90008, 0, 0, 0, 0, 0, 1616, 0, 0, 0, 'Autonomer Tauren-Schamane', 'Selbstlernende KI', '', 0, 10, 15, 0, 105, 0, 1.0, 1.14286, 1, 0, 20, 30, 0, 36, 1, 2000, 2000, 2, 0, 0, 0, 0, 0, 0, 0, 0, 15, 23, 12, 7, 0, 90008, 0, 0, 0, 0, 0, 0, 0, 0, 0, 403, 324, 332, 0, 0, 0, 0, 0, 0, 13, 22, 'AutonomousPlayerAI', 1, 3, 1, 2.2, 2.2, 1.2, 1.0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Goblin-Händler
(90009, 0, 0, 0, 0, 0, 1654, 0, 0, 0, 'Autonomer Goblin-Händler', 'Selbstlernende KI', '', 0, 8, 12, 0, 35, 0, 1.0, 1.14286, 0.8, 0, 18, 26, 0, 32, 1, 2000, 2000, 1, 0, 0, 0, 0, 0, 0, 0, 0, 14, 20, 11, 7, 0, 90009, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12, 20, 'AutonomousPlayerAI', 1, 3, 1, 1.5, 1.5, 1.0, 0.8, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340),

-- Autonomer Gnom-Erfinder
(90010, 0, 0, 0, 0, 0, 1563, 0, 0, 0, 'Autonomer Gnom-Erfinder', 'Selbstlernende KI', '', 0, 8, 12, 0, 35, 0, 1.0, 1.14286, 0.9, 0, 16, 24, 0, 28, 1, 2000, 2000, 1, 0, 0, 0, 0, 0, 0, 0, 0, 12, 18, 9, 7, 0, 90010, 0, 0, 0, 0, 0, 0, 0, 0, 0, 133, 6603, 0, 0, 0, 0, 0, 0, 0, 10, 18, 'AutonomousPlayerAI', 1, 3, 1, 1.6, 2.0, 1.0, 1.0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, '', 12340);

-- ===================================
-- 3. LOOT-TABELLEN (NUR GARANTIERTE SPALTEN)
-- ===================================

-- Lösche existierende Loot-Einträge
DELETE FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- Basis-Loot für alle autonomen NPCs
INSERT INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
(90001, 25, 100),  -- Autonomer Krieger - Silber
(90002, 25, 100),  -- Autonomer Magier - Silber
(90003, 25, 100),  -- Autonomer Heiler - Silber
(90004, 25, 100),  -- Autonomer Entdecker - Silber
(90005, 25, 100),  -- Autonomer Händler - Silber
(90006, 25, 100),  -- Autonomer Ork-Krieger - Silber
(90007, 25, 100),  -- Autonomer Untoten-Magier - Silber
(90008, 25, 100),  -- Autonomer Tauren-Schamane - Silber
(90009, 25, 100),  -- Autonomer Goblin-Händler - Silber
(90010, 25, 100);  -- Autonomer Gnom-Erfinder - Silber

-- Zusätzliche Handelsware für Händler
INSERT INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
-- Autonomer Händler (90005)
(90005, 2589, 75),  -- Leinenstoff
(90005, 2592, 50),  -- Wollstoff
(90005, 4306, 25),  -- Seidenstoff
(90005, 858, 15),   -- Geringwertige Heilungsrezepte
(90005, 159, 10),   -- Erfrischende Getränke

-- Autonomer Goblin-Händler (90009)
(90009, 2589, 75),  -- Leinenstoff
(90009, 2592, 50),  -- Wollstoff
(90009, 4306, 25),  -- Seidenstoff
(90009, 858, 15),   -- Geringwertige Heilungsrezepte
(90009, 159, 10);   -- Erfrischende Getränke

-- ===================================
-- 4. BEISPIEL-SPAWNS (OPTIONAL)
-- ===================================

-- Lösche existierende Spawns
DELETE FROM `creature` WHERE `id` BETWEEN 90001 AND 90010;

-- Spawn Autonomer Händler in Goldshire
INSERT INTO `creature` (
    `guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, 
    `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, 
    `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, 
    `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`
) VALUES (
    250001, 90005, 0, 0, 0, 1, 1, 0, 0, 
    -9463.02, 62.8533, 55.9574, 2.07694, 
    300, 5, 0, 1, 1, 1, 0, 0, 0
);

-- Spawn Autonomer Krieger in Elwynn Forest
INSERT INTO `creature` (
    `guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, 
    `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, 
    `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, 
    `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`
) VALUES (
    250002, 90001, 0, 0, 0, 1, 1, 0, 0, 
    -9400.5, 120.3, 58.2, 1.5, 
    300, 10, 0, 1, 1, 1, 0, 0, 0
);

-- ===================================
-- 5. INITIALE LERNDATEN
-- ===================================

-- Erstelle Basis-Lerndaten für gespawnte NPCs
INSERT INTO `autonomous_npc_learning` (
    `npc_guid`, `personality_aggressiveness`, `personality_curiosity`, 
    `personality_sociability`, `personality_intelligence`, `personality_patience`, 
    `current_role`, `learning_phase`, `experience_points`
) VALUES
(250001, 30, 70, 80, 60, 70, 'Trader', 0, 0),      -- Händler in Goldshire
(250002, 75, 50, 40, 55, 45, 'Tank', 0, 0);        -- Krieger in Elwynn

-- ===================================
-- 6. VERIFIKATION
-- ===================================

-- Prüfe erstellte NPCs
SELECT 
    ct.entry,
    ct.name,
    ct.subname,
    ct.minlevel,
    ct.maxlevel,
    ct.AIName
FROM `creature_template` ct
WHERE ct.entry BETWEEN 90001 AND 90010
ORDER BY ct.entry;

-- Prüfe gespawnte Kreaturen
SELECT 
    c.guid,
    c.id,
    ct.name,
    c.position_x,
    c.position_y,
    c.position_z
FROM `creature` c
JOIN `creature_template` ct ON c.id = ct.entry
WHERE c.id BETWEEN 90001 AND 90010;

-- Prüfe Loot-Tabellen
SELECT 
    entry as NPC_ID,
    item as Item_ID,
    Chance as Drop_Chance,
    (SELECT name FROM item_template WHERE entry = clt.item) as Item_Name
FROM `creature_loot_template` clt
WHERE entry BETWEEN 90001 AND 90010
ORDER BY entry, Chance DESC;

-- Prüfe Lerndaten
SELECT * FROM `autonomous_npc_learning`;

COMMIT;

-- ===================================
-- INSTALLATION ABGESCHLOSSEN!
-- ===================================
-- Nach Ausführung dieses Scripts:
-- 1. Server neustarten
-- 2. NPCs spawnen automatisch mit AutonomousPlayerAI
-- 3. Sie beginnen sofort zu lernen und sich zu entwickeln
-- 
-- Händler-NPC befindet sich in Goldshire (GUID: 250001)
-- Krieger-NPC befindet sich in Elwynn Forest (GUID: 250002)
-- ===================================