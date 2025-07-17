# 🧠 Autonome NPC-KI für TrinityCore (3.3.5a)

Dieses Projekt implementiert vollautonome, selbstlernende NPCs innerhalb der World of Warcraft: Wrath of the Lich King (3.3.5a) Server-Umgebung für TrinityCore.

![Status](https://img.shields.io/badge/Status-In%20Entwicklung-yellow)
![TrinityCore](https://img.shields.io/badge/TrinityCore-3.3.5a-blue)
![Lizenz](https://img.shields.io/badge/Lizenz-GPL%20v2+-green)

## 🌟 Übersicht

Im Gegensatz zu herkömmlich geskripteten NPCs simulieren diese autonomen Entitäten echte Spieler:
- **Charaktererstellungsprozess** mit zufälligen Eigenschaften
- **Levelaufstieg** durch Kampferfahrung
- **Adaptive Rollenermittlung** basierend auf Erfolg/Misserfolg
- **Soziale Interaktion** mit Spielern und anderen NPCs
- **Lernfähigkeit** durch kontinuierliche Analyse der Spielwelt

---

## 🏗️ Architektur

### Verzeichnisstruktur
```
src/server/game/AI/AutonomousNPC/
├── AutonomousPlayerAI.h          # Hauptklasse der autonomen KI
├── AutonomousPlayerAI.cpp        # Implementierung der KI-Logik
├── AutonomousNPCConfig.h         # Konfigurationssystem
└── AutonomousNPCConfig.cpp       # Konfigurationsimplementierung

sql/
└── autonomous_npc_setup.sql      # Datenbankstruktur und Test-NPCs
```

### Kernkomponenten

#### 🧠 LearningPhases
- **PHASE_INITIALIZATION** (Level 1-5): Grundlagenlernen
- **PHASE_ROLE_DISCOVERY** (Level 6-10): Rollenexperimente
- **PHASE_SPECIALIZATION** (Level 11-20): Rollenfokussierung  
- **PHASE_MASTERY** (Level 21+): Komplexe Strategien
- **PHASE_SOCIAL_INTEGRATION** (Alle Level): Soziales Lernen

#### 🎭 AutonomousRoles
- **ROLE_DPS_MELEE/RANGED/CASTER**: Schadensspezialist
- **ROLE_TANK**: Verteidiger und Aufmerksamkeits-Manager
- **ROLE_HEALER**: Unterstützer und Heiler
- **ROLE_SUPPORT**: Buffs und Utility
- **ROLE_EXPLORER**: Weltentdecker
- **ROLE_TRADER**: Sozialer Händler

#### 🎯 BehaviorStates
- **STATE_IDLE**: Ruhe und Beobachtung
- **STATE_EXPLORING**: Aktive Erkundung
- **STATE_COMBAT**: Kampfmodus
- **STATE_SOCIALIZING**: Interaktion mit Spielern
- **STATE_LEARNING**: Aktive Lernphase
- **STATE_CRAFTING**: Berufstätigkeiten (geplant)

---

## 🔧 Installation

### 1. Quellcode hinzufügen
```bash
# Kopiere die AutonomousNPC-Dateien in dein TrinityCore-Repository
cp -r src/server/game/AI/AutonomousNPC /path/to/trinitycore/src/server/game/AI/
```

### 2. CreatureAIRegistry erweitern
Die Registrierung erfolgt automatisch durch die Änderungen in `src/server/game/AI/CreatureAIRegistry.cpp`:
```cpp
#include "AutonomousNPC/AutonomousPlayerAI.h"
// ...
(new CreatureAIFactory<AutonomousPlayerAI>("AutonomousPlayerAI"))->RegisterSelf();
```

### 3. Datenbank-Setup
```sql
-- Führe das SQL-Setup aus
mysql -u root -p world < sql/autonomous_npc_setup.sql
```

### 4. Kompilierung
```bash
# TrinityCore normal kompilieren - die neuen Dateien werden automatisch erkannt
cd /path/to/trinitycore/build
make -j$(nproc)
```

### 5. Konfiguration
Füge folgende Einstellungen zu `worldserver.conf` hinzu:
```ini
###################################################################################################
# AUTONOME NPC EINSTELLUNGEN
###################################################################################################

# Maximale Anzahl aktiver autonomer NPCs
AutonomousNPC.MaxCount = 25

# Respektiere Spielerkapazität des Servers
AutonomousNPC.RespectPlayerCap = 1

# Automatisches Ausloggen bei Spielerlimit
AutonomousNPC.AutoLogoutOnPlayerLimit = 1

# Lerndaten in Datenbank persistieren
AutonomousNPC.PersistLearningData = 1

# Debug-Logging aktivieren (0 = Aus, 1 = An)
AutonomousNPC.EnableDebugLogging = 0

# Chat-Lernen aktivieren
AutonomousNPC.EnableChatLearning = 1
AutonomousNPC.MaxLearnedPhrases = 100
AutonomousNPC.ChatResponseChance = 30

# Kampf-Lernen aktivieren
AutonomousNPC.EnableCombatLearning = 1
AutonomousNPC.MaxCombatHistory = 50
AutonomousNPC.AggressiveMode = 0

# Exploration aktivieren
AutonomousNPC.EnableExploration = 1
AutonomousNPC.ExplorationRadius = 100.0
AutonomousNPC.ExplorationCooldown = 15000

# Soziale Interaktion aktivieren
AutonomousNPC.EnableSocialInteraction = 1
AutonomousNPC.SocialInteractionRadius = 15.0
AutonomousNPC.RelationshipDecayTime = 86400000

# Performance-Einstellungen (in Millisekunden)
AutonomousNPC.AIUpdateInterval = 2000
AutonomousNPC.LearningUpdateInterval = 5000
AutonomousNPC.SocialUpdateInterval = 10000

# Datenbank-Einstellungen
AutonomousNPC.LearningDataTable = "autonomous_npc_learning"
AutonomousNPC.SaveInterval = 300000
```

---

## 🎮 Nutzung

### Test-NPCs spawnen
```sql
-- Ingame-Befehle für GM:
.npc add 90001   -- Autonomer Krieger
.npc add 90002   -- Autonomer Magier  
.npc add 90003   -- Autonomer Heiler
.npc add 90004   -- Autonomer Entdecker
.npc add 90005   -- Autonomer Händler
```

### Eigene autonome NPCs erstellen
```sql
-- 1. Erstelle NPC Template
INSERT INTO creature_template 
SET entry=90100, name='Mein Autonomer NPC', AIName='AutonomousPlayerAI', ...;

-- 2. Spawne den NPC
INSERT INTO creature 
SET id=90100, map=0, position_x=..., position_y=..., position_z=...;
```

### Monitoring und Debug
```bash
# Logs überwachen
tail -f /path/to/server/logs/Server.log | grep "autonomous.npc"

# Datenbanküberwachung
SELECT npc_guid, total_combats, wins, losses, primary_role 
FROM autonomous_npc_learning;
```

---

## 🔍 Funktionsweise

### Lernzyklus
1. **Initialisierung**: NPC erhält zufällige Persönlichkeitsmerkmale
2. **Exploration**: NPC erkundet die Welt und sammelt Grundlagenerfahrung
3. **Rollenfindung**: Basierend auf Kampferfolg wird eine primäre Rolle gewählt
4. **Optimierung**: Zauberrotationen und Verhalten werden kontinuierlich angepasst
5. **Soziale Integration**: NPC lernt aus Spielerinteraktionen

### Persönlichkeitsmerkmale
- **Aggressiveness** (0-100): Beeinflusst Kampfbereitschaft
- **Curiosity** (0-100): Steuert Explorationsdrang
- **Sociability** (0-100): Bestimmt Interaktionsfreudigkeit
- **Intelligence** (0-100): Beeinflusst Lerngeschwindigkeit
- **Patience** (0-100): Steuert Ausdauer und Verteidigungsverhalten

### Adaptives Verhalten
```
Kampferfahrung → Rollenaffinität berechnen → Verhalten anpassen
      ↓                    ↓                        ↓
Zaubernutzung → Effektivität messen → Rotation optimieren
      ↓                    ↓                        ↓
Spielerchat → Phrasen lernen → Antworten generieren
```

---

## 📊 Datenbank-Schema

### autonomous_npc_learning
Speichert Lerndaten und Persönlichkeitsmerkmale:
- `npc_guid`: Eindeutige NPC-Identifikation  
- `total_combats/wins/losses`: Kampfstatistiken
- `primary_role/secondary_role`: Erkannte Rollen
- `personality_*`: Persönlichkeitsmerkmale (0-100)
- `visited_zones`: JSON-Array besuchter Gebiete
- `learned_phrases`: JSON-Array gelernter Chat-Phrasen

### autonomous_npc_spell_data
Zaubereffektivitäts-Tracking:
- `spell_id`: Zauber-ID
- `usage_count/success_count`: Nutzungs- und Erfolgsstatistiken
- `effectiveness_score`: Berechnete Effektivität (0-100)

### autonomous_npc_relationships
Soziale Beziehungen zu Spielern:
- `player_guid`: Spieler-GUID
- `relationship_value`: Beziehungswert (-100 bis +100)
- `interaction_count`: Anzahl Interaktionen

### autonomous_npc_combat_history
Detaillierte Kampfhistorie für Lernanalyse:
- Schaden/Heilung/Mana-Statistiken
- Verwendete Zauber (JSON)
- Kampfdauer und Ergebnis

---

## ⚡ Performance-Überlegungen

### Optimierungen
- **Timer-basierte Updates**: Vermeidet unnötige Berechnungen
- **Konfigurierbare Intervalle**: Anpassung an Serverleistung
- **Begrenzte Historien**: Speicher-effiziente Datenhaltung
- **Spielerkapazitäts-Respekt**: Automatische NPC-Verwaltung

### Empfohlene Einstellungen
```ini
# Für starke Server (32+ Kerne)
AutonomousNPC.MaxCount = 50
AutonomousNPC.AIUpdateInterval = 1500

# Für mittelstarke Server (8-16 Kerne)  
AutonomousNPC.MaxCount = 25
AutonomousNPC.AIUpdateInterval = 2000

# Für schwächere Server (4 Kerne oder weniger)
AutonomousNPC.MaxCount = 10
AutonomousNPC.AIUpdateInterval = 3000
```

---

## 🚀 Erweiterte Features (Roadmap)

### 🔮 Geplante Funktionen
- [ ] **Berufssystem-Integration**: NPCs lernen Handwerk
- [ ] **Auktionshaus-Nutzung**: Intelligenter Handel
- [ ] **Gruppen-KI**: NPCs bilden Gruppen für Dungeons
- [ ] **PvP-Modus**: Teilnahme an Schlachtfeldern
- [ ] **Guild-Integration**: NPCs können Gilden beitreten
- [ ] **Quest-System**: NPCs können Quests annehmen und abschließen
- [ ] **Mount-Nutzung**: Transportoptimierung
- [ ] **Makro-Lernen**: Komplexe Spieler-Makros nachahmen

### 🛠️ Technische Verbesserungen
- [ ] **Machine Learning Integration**: TensorFlow/PyTorch-Anbindung
- [ ] **Verbessertes Pathfinding**: A*-basierte Bewegung
- [ ] **Sprach-Verarbeitung**: Erweiterte Chat-Analyse
- [ ] **Performance-Profiling**: Detaillierte Leistungsmetriken
- [ ] **Web-Interface**: Überwachung und Konfiguration über Browser

---

## 🐛 Bekannte Probleme & Lösungen

### Problem: NPCs spawnen nicht
**Lösung**: 
```sql
-- Prüfe creature_template AIName
SELECT entry, name, AIName FROM creature_template WHERE entry BETWEEN 90001 AND 90005;

-- Stelle sicher, dass AIName = 'AutonomousPlayerAI'
UPDATE creature_template SET AIName = 'AutonomousPlayerAI' WHERE entry BETWEEN 90001 AND 90005;
```

### Problem: Hohe CPU-Belastung
**Lösung**:
```ini
# Erhöhe Update-Intervalle
AutonomousNPC.AIUpdateInterval = 3000
AutonomousNPC.LearningUpdateInterval = 10000

# Reduziere aktive NPCs
AutonomousNPC.MaxCount = 10
```

### Problem: Datenbank-Fehler
**Lösung**:
```sql
-- Prüfe Tabellenexistenz
SHOW TABLES LIKE 'autonomous_npc_%';

-- Repariere Tabellen falls nötig
REPAIR TABLE autonomous_npc_learning;
```

---

## 🤝 Beitrag leisten

### Entwicklung
```bash
# Repository forken und klonen
git clone https://github.com/YourUsername/TrinityCore-AutonomousNPC.git

# Feature-Branch erstellen
git checkout -b feature/neue-funktion

# Änderungen committen
git commit -m "Füge neue Funktion hinzu"

# Pull Request erstellen
```

### Bereiche für Beiträge
- **🧠 KI-Algorithmen**: Verbesserung der Lernlogik
- **⚔️ Kampf-System**: Erweiterte Kampftaktiken
- **💬 Sozial-System**: Bessere Chat-Verarbeitung
- **🔧 Performance**: Optimierungen und Profiling
- **📝 Dokumentation**: Tutorials und Guides
- **🧪 Tests**: Unit-Tests und Integrationstests

---

## 📜 Lizenz

Dieses Projekt steht unter der **GNU General Public License v2+** entsprechend der TrinityCore-Lizenz.

```
Copyright (C) 2024 TrinityCore Autonomous NPC Project

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
```

---

## 📧 Support & Community

- **Issues**: [GitHub Issues](https://github.com/TrinityCore/TrinityCore/issues)
- **Diskussionen**: [TrinityCore Discord](https://discord.gg/trinitycore)
- **Wiki**: [TrinityCore Wiki](https://trinitycore.atlassian.net/wiki)
- **Forum**: [TrinityCore Community](https://community.trinitycore.org/)

---

## 🙏 Danksagungen

- **TrinityCore Team**: Für die exzellente Server-Grundlage
- **WoW Classic Community**: Für Inspiration und Feedback  
- **OpenAI**: Für KI-Forschung und -Technologien
- **Alle Mitwirkenden**: Für Code, Tests und Dokumentation

---

*Erstellt mit ❤️ für die World of Warcraft Private Server Community*