-- ===================================
-- Sichere Loot-Tabellen für autonome NPCs
-- Korrigiert für TrinityCore 3.3.5a mit 'Chance' statt 'ChanceOrQuestChance'
-- ===================================

-- Lösche existierende Loot-Einträge (falls vorhanden)
DELETE FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- ===================================
-- KORREKTE VERSION - Für Ihre Datenbank-Struktur
-- ===================================
-- Verwendet 'Chance' statt 'ChanceOrQuestChance'
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`, `lootmode`, `groupid`, `mincountOrRef`, `maxcount`) VALUES
(90001, 25, 100, 1, 0, 1, 4),  -- Autonomer Krieger - Silber
(90002, 25, 100, 1, 0, 1, 4),  -- Autonomer Magier - Silber
(90003, 25, 100, 1, 0, 1, 4),  -- Autonomer Heiler - Silber
(90004, 25, 100, 1, 0, 1, 4),  -- Autonomer Entdecker - Silber
(90005, 25, 100, 1, 0, 1, 4),  -- Autonomer Händler - Silber
(90006, 25, 100, 1, 0, 1, 4),  -- Autonomer Ork-Krieger - Silber
(90007, 25, 100, 1, 0, 1, 4),  -- Autonomer Untoten-Magier - Silber
(90008, 25, 100, 1, 0, 1, 4),  -- Autonomer Tauren-Schamane - Silber
(90009, 25, 100, 1, 0, 1, 4),  -- Autonomer Goblin-Händler - Silber
(90010, 25, 100, 1, 0, 1, 4);  -- Autonomer Gnom-Erfinder - Silber

-- ===================================
-- ALTERNATIVE 1: Nur wichtigste Spalten (falls obiges fehlschlägt)
-- ===================================
/*
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
(90001, 25, 100),  -- Autonomer Krieger
(90002, 25, 100),  -- Autonomer Magier
(90003, 25, 100),  -- Autonomer Heiler
(90004, 25, 100),  -- Autonomer Entdecker
(90005, 25, 100),  -- Autonomer Händler
(90006, 25, 100),  -- Autonomer Ork-Krieger
(90007, 25, 100),  -- Autonomer Untoten-Magier
(90008, 25, 100),  -- Autonomer Tauren-Schamane
(90009, 25, 100),  -- Autonomer Goblin-Händler
(90010, 25, 100);  -- Autonomer Gnom-Erfinder
*/

-- ===================================
-- ALTERNATIVE 2: Mit zusätzlichen Items für Händler (90005, 90009)
-- ===================================
/*
-- Händler bekommen zusätzliche Handelsware
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
(90005, 2589, 75),  -- Leinenstoff
(90005, 2592, 50),  -- Wollstoff
(90005, 4306, 25),  -- Seidenstoff
(90009, 2589, 75),  -- Leinenstoff
(90009, 2592, 50),  -- Wollstoff
(90009, 4306, 25);  -- Seidenstoff
*/

-- Prüfe das Ergebnis
SELECT * FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- ===================================
-- Zusätzlich: Händler-NPC in Goldshire spawnen
-- ===================================
-- Falls Sie den Händler in Goldshire platzieren möchten:
/*
REPLACE INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `modelid`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`) VALUES
(250001, 90005, 0, 0, 0, 1, 1, 0, 0, -9463.02, 62.8533, 55.9574, 2.07694, 300, 0, 0, 1, 1, 0, 0, 0, 0);
*/

COMMIT;