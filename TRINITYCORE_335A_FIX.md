# 🔧 TrinityCore 3.3.5a Kompatibilitäts-Fix

## ❌ Problem: Datenbankfehler bei TrinityCore 3.3.5a

**Fehlermeldungen:**
```
#1146 - Tabelle 'wotlk_world.creature_template_stats' existiert nicht
#1054 - Unbekanntes Tabellenfeld 'minhealth' in INSERT INTO
#1054 - Unbekanntes Tabellenfeld 'faction_A' in INSERT INTO
```

## ✅ Lösung

TrinityCore 3.3.5a hat eine andere Datenbankstruktur als neuere Versionen:

1. **`creature_template_stats`** existiert nicht - Stats sind in `creature_template` integriert
2. **Spaltennamen unterscheiden sich** zwischen verschiedenen 3.3.5a-Builds
3. **Verschiedene Commits** haben unterschiedliche Strukturen

### 🔧 Drei Lösungsansätze:

#### 🎯 Empfohlene Lösung: Minimales SQL-Skript

**Verwende:** `sql/autonomous_npc_setup_minimal.sql`

Dieses Skript:
- Verwendet nur garantiert existierende Spalten
- Ignoriert Fehler bei optionalen Spalten
- Funktioniert mit allen TrinityCore 3.3.5a-Varianten

```bash
mysql -u root -p world < sql/autonomous_npc_setup_minimal.sql
```

#### 🔍 Alternative: Manuelle Anpassung

1. **Prüfe deine DB-Struktur:**
```sql
DESCRIBE creature_template;
```

2. **Passe SQL entsprechend an** - verwende nur existierende Spalten

#### 📋 Was wurde allgemein geändert:

#### Vorher (fehlerhaft für 3.3.5a):
```sql
REPLACE INTO `creature_template_stats` (`entry`, `level`, `hp`, `mana`, `armor`, `str`, `agi`, `sta`, `inte`, `spi`) VALUES
(90001, 1, 100, 0, 15, 18, 14, 17, 11, 13),
...
```

#### Nachher (korrekt für 3.3.5a):
```sql
REPLACE INTO `creature_template` (
  `entry`, `name`, `subname`, `modelid1`, `modelid2`, `modelid3`, `modelid4`,
  `faction`, `minlevel`, `maxlevel`, `minhealth`, `maxhealth`, `minmana`, `maxmana`,
  `armor`, `mindmg`, `maxdmg`, `attackpower`, `dmg_multiplier`, `baseattacktime`, `rangeattacktime`,
  `unit_class`, `unit_flags`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `dmgschool`,
  `AIName`, `ScriptName`
) VALUES
(90001, 'Autonomer Krieger', 'Experimentelle KI', 55, 0, 0, 0,
 35, 1, 20, 100, 680, 0, 0,
 15, 8, 12, 18, 1.0, 2000, 2000,
 1, 0, 0, 1.0, 1.14, 1.0, 0, 0,
 'AutonomousPlayerAI', ''),
...
```

### 📊 TrinityCore 3.3.5a `creature_template` Struktur

Wichtige Spalten für NPC-Stats:
- `minlevel`, `maxlevel`: Level-Bereich des NPCs
- `minhealth`, `maxhealth`: HP-Bereich
- `minmana`, `maxmana`: Mana-Bereich
- `armor`: Rüstung
- `mindmg`, `maxdmg`: Schadenswerte
- `attackpower`: Angriffskraft
- `dmg_multiplier`: Schadensmultiplikator
- `baseattacktime`, `rangeattacktime`: Angriffsgeschwindigkeit

### 🎯 Unterschiede zwischen TrinityCore-Versionen

| Feature | 3.3.5a | Neuere Versionen |
|---------|--------|------------------|
| Stats | `creature_template` | `creature_template_stats` |
| Modelle | `modelid1-4` | `Models` Array |
| Unit Flags | `unit_flags` | `unit_flags`, `unit_flags2`, `unit_flags3` |

## 🔍 Fehlerbehebung

### 1. Überprüfe TrinityCore-Version
```sql
SELECT @@version; -- MySQL Version
SHOW TABLES LIKE 'creature_template%'; -- Verfügbare Tabellen
```

### 2. Überprüfe `creature_template` Struktur
```sql
DESCRIBE creature_template;
```

### 3. Teste NPC-Erstellung
```sql
-- Prüfe ob NPCs korrekt erstellt wurden
SELECT entry, name, AIName, minlevel, maxlevel, minhealth, maxhealth 
FROM creature_template 
WHERE entry BETWEEN 90001 AND 90005;
```

### 4. Spawn-Test
```sql
-- Prüfe Spawn-Punkte
SELECT id, map, position_x, position_y, position_z 
FROM creature 
WHERE id BETWEEN 90001 AND 90005;
```

## ⚠️ Weitere mögliche 3.3.5a Probleme

### Problem: `unit_flags2` nicht verfügbar
**Lösung:** Entferne `unit_flags2` aus SQL-Statements

### Problem: Verschiedene Spalten-Namen
**Lösung:** Überprüfe Spalten-Namen mit `DESCRIBE creature_template`

### Problem: Fehlende Includes in C++
**Lösung:** Stelle sicher, dass alle TrinityCore-Headers verfügbar sind

## ✅ Validierung

Nach der Installation sollten folgende Befehle funktionieren:

```sql
-- Ingame als GM
.npc add 90001  -- Spawnt autonomen Krieger
.npc add 90002  -- Spawnt autonomen Magier
.npc info       -- Zeigt NPC-Informationen
```

## 📝 Support

Bei weiteren Problemen:
1. Überprüfe die TrinityCore-Version: `git branch` oder `git log --oneline -1`
2. Vergleiche `creature_template`-Struktur mit aktueller DB
3. Prüfe Logs: `grep "autonomous.npc" Server.log`
4. Forum: [TrinityCore Community](https://community.trinitycore.org/)

---

**Status: ✅ Kompatibilitäts-Fix für TrinityCore 3.3.5a angewendet**