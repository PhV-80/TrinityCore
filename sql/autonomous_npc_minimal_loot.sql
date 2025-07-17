-- ===================================
-- MINIMALE Loot-Tabellen für autonome NPCs
-- Nur garantiert existierende Spalten für TrinityCore 3.3.5a
-- ===================================

-- Lösche existierende Loot-Einträge
DELETE FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- ===================================
-- VERSION 1: Nur entry, item, Chance (garantiert funktionsfähig)
-- ===================================
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
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

-- ===================================
-- ZUSÄTZLICHE ITEMS FÜR HÄNDLER (90005, 90009)
-- ===================================
REPLACE INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
-- Autonomer Händler (90005) - Handelsware
(90005, 2589, 75),  -- Leinenstoff
(90005, 2592, 50),  -- Wollstoff
(90005, 4306, 25),  -- Seidenstoff
(90005, 858, 15),   -- Geringwertige Heilungsrezepte
(90005, 159, 10),   -- Erfrischende Getränke

-- Autonomer Goblin-Händler (90009) - Handelsware
(90009, 2589, 75),  -- Leinenstoff
(90009, 2592, 50),  -- Wollstoff
(90009, 4306, 25),  -- Seidenstoff
(90009, 858, 15),   -- Geringwertige Heilungsrezepte
(90009, 159, 10);   -- Erfrischende Getränke

-- ===================================
-- VERIFIKATION
-- ===================================
SELECT 
    entry as NPC_ID,
    item as Item_ID,
    Chance as Drop_Chance,
    (SELECT name FROM item_template WHERE entry = clt.item) as Item_Name
FROM `creature_loot_template` clt
WHERE entry BETWEEN 90001 AND 90010
ORDER BY entry, Chance DESC;

COMMIT;

-- ===================================
-- FALLS SIE IHRE SPALTEN-STRUKTUR PRÜFEN MÖCHTEN:
-- ===================================
-- Führen Sie diesen Befehl aus um die exakte Struktur zu sehen:
-- DESCRIBE creature_loot_template;