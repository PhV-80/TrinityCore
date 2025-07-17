-- ===================================
-- Autonomer Händler in Goldshire
-- Korrekte SQL für TrinityCore 3.3.5a
-- ===================================

-- Lösche existierende Spawns des Händlers (falls vorhanden)
DELETE FROM `creature` WHERE `id` = 90005;
DELETE FROM `creature` WHERE `guid` = 250001;

-- ===================================
-- Loot-Tabelle (mit korrektem Spaltennamen 'Chance')
-- ===================================
DELETE FROM `creature_loot_template` WHERE `entry` = 90005;

-- Grundloot für den Händler (nur garantierte Spalten)
INSERT INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
(90005, 25, 100),   -- Silber (100% Chance)
(90005, 2589, 75),  -- Leinenstoff (75% Chance)
(90005, 2592, 50),  -- Wollstoff (50% Chance)
(90005, 4306, 25),  -- Seidenstoff (25% Chance)
(90005, 858, 15),   -- Geringwertige Heilungsrezepte (15% Chance)
(90005, 159, 10);   -- Erfrischende Getränke (10% Chance)

-- ===================================
-- Händler-Spawn in Goldshire
-- ===================================
-- Position: Vor dem Goldenen Löwen Gasthaus in Goldshire
-- Koordinaten: X: -9463.02, Y: 62.85, Z: 55.96
REPLACE INTO `creature` (
    `guid`, 
    `id`, 
    `map`, 
    `zoneId`, 
    `areaId`, 
    `spawnMask`, 
    `phaseMask`, 
    `modelid`, 
    `equipment_id`, 
    `position_x`, 
    `position_y`, 
    `position_z`, 
    `orientation`, 
    `spawntimesecs`, 
    `spawndist`, 
    `currentwaypoint`, 
    `curhealth`, 
    `curmana`, 
    `MovementType`, 
    `npcflag`, 
    `unit_flags`, 
    `dynamicflags`
) VALUES (
    250001,         -- guid (eindeutige ID)
    90005,          -- id (Autonomer Händler)
    0,              -- map (Eastern Kingdoms)
    0,              -- zoneId (wird automatisch gesetzt)
    0,              -- areaId (wird automatisch gesetzt)
    1,              -- spawnMask (normal mode)
    1,              -- phaseMask (phase 1)
    0,              -- modelid (0 = default model)
    0,              -- equipment_id (0 = default equipment)
    -9463.02,       -- position_x (Goldshire)
    62.8533,        -- position_y
    55.9574,        -- position_z
    2.07694,        -- orientation (Blickrichtung)
    300,            -- spawntimesecs (5 Minuten Respawn)
    5,              -- spawndist (5 Yard Wanderradius)
    0,              -- currentwaypoint
    1,              -- curhealth (wird bei Spawn korrekt gesetzt)
    1,              -- curmana (wird bei Spawn korrekt gesetzt)
    1,              -- MovementType (1 = random movement)
    0,              -- npcflag (keine besonderen Flags)
    0,              -- unit_flags
    0               -- dynamicflags
);

-- ===================================
-- Verifikation
-- ===================================
-- Prüfe ob der Händler korrekt eingetragen wurde
SELECT 
    c.guid,
    c.id,
    ct.name,
    c.position_x,
    c.position_y,
    c.position_z,
    c.spawntimesecs
FROM `creature` c
JOIN `creature_template` ct ON c.id = ct.entry
WHERE c.id = 90005;

-- Prüfe Loot-Tabelle
SELECT 
    entry,
    item,
    Chance,
    (SELECT name FROM item_template WHERE entry = clt.item) as item_name
FROM `creature_loot_template` clt
WHERE entry = 90005
ORDER BY Chance DESC;

COMMIT;

-- ===================================
-- HINWEISE ZUR VERWENDUNG:
-- ===================================
-- 1. Nach dem Ausführen dieses Scripts sollten Sie den Server neustarten
-- 2. Der Händler spawnt vor dem Gasthaus in Goldshire
-- 3. Er wird automatisch die AutonomousPlayerAI verwenden
-- 4. Er beginnt als "Trader" und entwickelt sich weiter
-- 5. GUID 250001 kann geändert werden wenn sie bereits vergeben ist
-- 6. Der Händler respawnt nach 5 Minuten automatisch

-- ===================================
-- ALTERNATIVE POSITIONEN (auskommentiert):
-- ===================================
-- Beim Briefkasten in Goldshire:
-- position_x: -9449.06, position_y: 64.8815, position_z: 55.6766

-- Am Brunnen in Goldshire:
-- position_x: -9457.13, position_y: 87.1258, position_z: 57.7737

-- Bei der Schmiede in Goldshire:
-- position_x: -9460.47, position_y: 109.534, position_z: 57.6549