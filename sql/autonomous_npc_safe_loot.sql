-- ===================================
-- Sichere Loot-Tabellen für autonome NPCs
-- Verschiedene Fallback-Optionen für TrinityCore 3.3.5a
-- ===================================

-- Zuerst prüfen wir die Struktur der Loot-Tabelle
-- DESCRIBE creature_loot_template;

-- Lösche existierende Loot-Einträge
DELETE FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

-- Version 1: Standard TrinityCore 3.3.5a (wahrscheinlich korrekt)
-- Nur die grundlegenden Spalten verwenden
INSERT INTO `creature_loot_template` (`entry`, `item`, `Chance`) VALUES
(90001, 25, 100),  -- Silber für Autonomer Krieger
(90002, 25, 100),  -- Silber für Autonomer Magier
(90003, 25, 100),  -- Silber für Autonomer Heiler
(90004, 25, 100),  -- Silber für Autonomer Entdecker
(90005, 25, 100),  -- Silber für Autonomer Händler
(90006, 25, 100),  -- Silber für Autonomer Ork-Krieger
(90007, 25, 100),  -- Silber für Autonomer Untoten-Magier
(90008, 25, 100),  -- Silber für Autonomer Tauren-Schamane
(90009, 25, 100),  -- Silber für Autonomer Goblin-Händler
(90010, 25, 100);  -- Silber für Autonomer Gnom-Erfinder

-- Falls obiges fehlschlägt, versuche diese Alternative:
-- INSERT INTO `creature_loot_template` (`entry`, `item`, `chance`) VALUES
-- (90001, 25, 100), (90002, 25, 100), (90003, 25, 100), (90004, 25, 100), (90005, 25, 100);

-- Prüfe das Ergebnis
SELECT * FROM `creature_loot_template` WHERE `entry` BETWEEN 90001 AND 90010;

COMMIT;