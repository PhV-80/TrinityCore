/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "AutonomousPlayerAI.h"
#include "AutonomousNPCConfig.h"
#include "Creature.h"
#include "Player.h"
#include "SpellMgr.h"
#include "SpellInfo.h"
#include "WorldSession.h"
#include "Chat.h"
#include "ObjectAccessor.h"
#include "MapManager.h"
#include "Log.h"
#include "Config.h"
#include "GridNotifiers.h"
#include "CellImpl.h"
#include "GridNotifiersImpl.h"
#include "World.h"
#include <algorithm>
#include <chrono>

// Konstanten für das Verhalten
constexpr uint32 BEHAVIOR_UPDATE_INTERVAL = 2000;   // 2 Sekunden
constexpr uint32 LEARNING_UPDATE_INTERVAL = 5000;   // 5 Sekunden  
constexpr uint32 SOCIAL_UPDATE_INTERVAL = 10000;    // 10 Sekunden
constexpr uint32 EXPLORATION_INTERVAL = 15000;      // 15 Sekunden
constexpr uint32 CHAT_INTERVAL = 30000;             // 30 Sekunden

constexpr uint32 ROLE_DISCOVERY_MIN_LEVEL = 6;
constexpr uint32 ROLE_SPECIALIZATION_MIN_LEVEL = 11;
constexpr uint32 ROLE_MASTERY_MIN_LEVEL = 21;

constexpr float COMBAT_ENGAGE_DISTANCE = 30.0f;
constexpr float SOCIAL_INTERACTION_DISTANCE = 15.0f;

AutonomousPlayerAI::AutonomousPlayerAI(Creature* creature) : CreatureAI(creature),
    m_currentPhase(LearningPhase::PHASE_INITIALIZATION),
    m_currentState(BehaviorState::STATE_IDLE),
    m_previousState(BehaviorState::STATE_IDLE),
    m_behaviorUpdateTimer(AutonomousNPCConfig::AIUpdateInterval),
    m_learningUpdateTimer(AutonomousNPCConfig::LearningUpdateInterval),
    m_socialUpdateTimer(AutonomousNPCConfig::SocialUpdateInterval),
    m_explorationTimer(AutonomousNPCConfig::ExplorationCooldown),
    m_chatTimer(CHAT_INTERVAL),
    m_combatStartTime(0),
    m_totalDamageDealt(0),
    m_totalDamageTaken(0),
    m_totalHealingDone(0),
    m_totalManaUsed(0),
    m_aggressiveness(50),
    m_curiosity(50),
    m_sociability(50),
    m_intelligence(50),
    m_patience(50),
    m_randomGenerator(std::chrono::steady_clock::now().time_since_epoch().count()),
    m_lastDecisionTime(0)
{
    TC_LOG_INFO("autonomous.npc", "AutonomousPlayerAI: Erstelle autonomen NPC {}", creature->GetName());
    
    // Registriere NPC bei der Konfiguration
    AutonomousNPCConfig::NotifyNPCSpawned();
    
    InitializeAsNewCharacter();
}

AutonomousPlayerAI::~AutonomousPlayerAI()
{
    SaveLearningData();
    
    // Deregistriere NPC bei der Konfiguration
    AutonomousNPCConfig::NotifyNPCDespawned();
    
    TC_LOG_INFO("autonomous.npc", "AutonomousPlayerAI: Zerstöre autonomen NPC {}", me->GetName());
}

void AutonomousPlayerAI::Reset()
{
    CreatureAI::Reset();
    
    m_currentState = BehaviorState::STATE_IDLE;
    m_combatStartTime = 0;
    m_totalDamageDealt = 0;
    m_totalDamageTaken = 0;
    m_totalHealingDone = 0;
    m_totalManaUsed = 0;
    m_currentCombatSpells.clear();
    
    TC_LOG_DEBUG("autonomous.npc", "AutonomousPlayerAI::Reset: NPC {} zurückgesetzt", me->GetName());
}

void AutonomousPlayerAI::UpdateAI(uint32 diff)
{
    // Basis CreatureAI Update
    if (!UpdateVictim())
    {
        // Kein Kampf - normale Verhaltensroutinen ausführen
        UpdateBehavior(diff);
        UpdateLearning(diff);
        UpdateSocialBehavior(diff);
    }
    else
    {
        // Im Kampf - Kampf-KI ausführen
        m_currentState = BehaviorState::STATE_COMBAT;
        
        if (Unit* target = me->GetVictim())
        {
            SelectBestSpell(target);
        }
    }
    
    // Phase progression prüfen
    UpdatePhaseProgression();
}

void AutonomousPlayerAI::InitializeAsNewCharacter()
{
    TC_LOG_INFO("autonomous.npc", "AutonomousPlayerAI::InitializeAsNewCharacter: Initialisiere NPC {}", me->GetName());
    
    // Zufällige Persönlichkeitsmerkmale generieren
    RandomizeCharacteristics();
    
    // Startphase setzen
    m_currentPhase = LearningPhase::PHASE_INITIALIZATION;
    m_currentState = BehaviorState::STATE_LEARNING;
    
    // Grundlegende Chat-Phrasen hinzufügen
    m_socialMemory.learnedPhrases.push_back("Hallo!");
    m_socialMemory.learnedPhrases.push_back("Wie geht es dir?");
    m_socialMemory.learnedPhrases.push_back("Schönes Wetter heute.");
    m_socialMemory.learnedPhrases.push_back("Viel Erfolg beim Abenteuer!");
    m_socialMemory.learnedPhrases.push_back("Für die Allianz!"); // Wird später je nach Fraktion angepasst
    
    // Initial alle Rollen als gleich wahrscheinlich setzen
    for (int i = static_cast<int>(AutonomousRole::ROLE_DPS_MELEE); 
         i <= static_cast<int>(AutonomousRole::ROLE_TRADER); ++i)
    {
        m_learningData.roleAffinities[static_cast<AutonomousRole>(i)] = 10.0f;
    }
    
    LoadLearningData();
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} initialisiert mit Persönlichkeit: Aggr={}, Cur={}, Soc={}, Int={}, Pat={}", 
                 me->GetName(), m_aggressiveness, m_curiosity, m_sociability, m_intelligence, m_patience);
}

void AutonomousPlayerAI::UpdateBehavior(uint32 diff)
{
    if (m_behaviorUpdateTimer <= diff)
    {
        m_behaviorUpdateTimer = BEHAVIOR_UPDATE_INTERVAL;
        
        // Entscheide über nächste Aktion
        MakeAutonomousDecision();
        
        // Führe aktuelles Verhalten aus
        switch (m_currentState)
        {
            case BehaviorState::STATE_IDLE:
                ExecuteIdleBehavior();
                break;
            case BehaviorState::STATE_EXPLORING:
                ExecuteExplorationBehavior();
                break;
            case BehaviorState::STATE_SOCIALIZING:
                ExecuteSocialBehavior();
                break;
            case BehaviorState::STATE_CRAFTING:
                ExecuteCraftingBehavior();
                break;
            case BehaviorState::STATE_LEARNING:
                // Spezielle Lernaktivitäten
                EvaluateCurrentSituation();
                break;
            default:
                break;
        }
    }
    else
    {
        m_behaviorUpdateTimer -= diff;
    }
}

void AutonomousPlayerAI::UpdateLearning(uint32 diff)
{
    if (m_learningUpdateTimer <= diff)
    {
        m_learningUpdateTimer = LEARNING_UPDATE_INTERVAL;
        
        // Bewerte Rollenaffinitäten basierend auf bisherigen Erfahrungen
        EvaluateRoleAffinity();
        
        // Optimiere Zauberrotation
        if (m_learningData.totalCombats > 5)
        {
            OptimizeSpellRotation();
        }
        
        // Speichere Lerndaten periodisch
        if (m_learningData.totalCombats % 10 == 0)
        {
            SaveLearningData();
        }
    }
    else
    {
        m_learningUpdateTimer -= diff;
    }
}

void AutonomousPlayerAI::UpdateSocialBehavior(uint32 diff)
{
    if (m_socialUpdateTimer <= diff)
    {
        m_socialUpdateTimer = SOCIAL_UPDATE_INTERVAL;
        
        // Suche nach Interaktionsmöglichkeiten
        SeekNearbyInteractions();
        
        // Verarbeite nahestehende Spieler und NPCs
        ProcessNearbyPlayers();
        ProcessNearbyCreatures();
        
        // Gelegentlich chatten
        if (m_chatTimer <= diff && m_sociability > 30)
        {
            m_chatTimer = CHAT_INTERVAL + urand(0, 15000); // Zufällige Variation
            if (urand(1, 100) <= m_sociability)
            {
                SendRandomChat();
            }
        }
        else
        {
            m_chatTimer -= diff;
        }
    }
    else
    {
        m_socialUpdateTimer -= diff;
    }
}

void AutonomousPlayerAI::JustEnteredCombat(Unit* who)
{
    CreatureAI::JustEnteredCombat(who);
    
    m_combatStartTime = getMSTime();
    m_currentState = BehaviorState::STATE_COMBAT;
    m_totalDamageDealt = 0;
    m_totalDamageTaken = 0;
    m_totalHealingDone = 0;
    m_totalManaUsed = 0;
    m_currentCombatSpells.clear();
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} beginn Kampf mit {}", me->GetName(), who->GetName());
}

void AutonomousPlayerAI::JustDied(Unit* killer)
{
    CreatureAI::JustDied(killer);
    
    // Analysiere Kampfresultat
    AnalyzeCombatResult(false, killer);
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} ist gestorben. Lerne aus Niederlage.", me->GetName());
}

void AutonomousPlayerAI::KilledUnit(Unit* victim)
{
    CreatureAI::KilledUnit(victim);
    
    // Analysiere erfolgreichen Kampf
    AnalyzeCombatResult(true, victim);
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} hat {} besiegt. Lerne aus Sieg.", me->GetName(), victim->GetName());
}

void AutonomousPlayerAI::EnterEvadeMode(EvadeReason why)
{
    CreatureAI::EnterEvadeMode(why);
    
    // Wenn wir aus dem Kampf fliehen, analysiere trotzdem das Ergebnis
    if (m_combatStartTime > 0)
    {
        AnalyzeCombatResult(false, nullptr);
    }
    
    m_currentState = BehaviorState::STATE_RESTING;
    TC_LOG_DEBUG("autonomous.npc", "NPC {} verlässt Kampf. Grund: {}", me->GetName(), static_cast<uint32>(why));
}

void AutonomousPlayerAI::MoveInLineOfSight(Unit* who)
{
    if (!who || !me->IsAlive())
        return;
        
    // Soziale Interaktion mit Spielern
    if (Player* player = who->ToPlayer())
    {
        if (me->GetDistance(player) <= SOCIAL_INTERACTION_DISTANCE && m_sociability > 50)
        {
            // Merke dir diese Spielerinteraktion
            auto it = m_socialMemory.playerInteractions.find(player->GetGUID());
            if (it != m_socialMemory.playerInteractions.end())
            {
                it->second++;
            }
            else
            {
                m_socialMemory.playerInteractions[player->GetGUID()] = 1;
                m_socialMemory.relationshipValues[player->GetGUID()] = 0; // Neutral
            }
        }
    }
    
    // Normale Kampflogik
    if (ShouldEngageTarget(who))
    {
        CreatureAI::MoveInLineOfSight(who);
    }
}

void AutonomousPlayerAI::AnalyzeCombatResult(bool victory, Unit* opponent)
{
    if (m_combatStartTime == 0)
        return;
        
    CombatExperience experience;
    experience.victory = victory;
    experience.combatDuration = getMSTime() - m_combatStartTime;
    experience.damageDealt = m_totalDamageDealt;
    experience.damageTaken = m_totalDamageTaken;
    experience.healingDone = m_totalHealingDone;
    experience.manaUsed = m_totalManaUsed;
    experience.spellsUsed = m_currentCombatSpells;
    
    if (opponent)
    {
        if (Creature* creature = opponent->ToCreature())
        {
            experience.enemyEntry = creature->GetEntry();
        }
        experience.enemyLevel = opponent->GetLevel();
    }
    
    // Lerne aus dieser Erfahrung
    LearnFromCombat(experience);
    
    // Speichere in Historie
    m_combatHistory.push_back(experience);
    
    // Halte Historie überschaubar (letzte 50 Kämpfe)
    if (m_combatHistory.size() > 50)
    {
        m_combatHistory.erase(m_combatHistory.begin());
    }
    
    // Reset Kampfvariablen
    m_combatStartTime = 0;
}

void AutonomousPlayerAI::LearnFromCombat(const CombatExperience& experience)
{
    m_learningData.totalCombats++;
    
    if (experience.victory)
    {
        m_learningData.wins++;
    }
    else
    {
        m_learningData.losses++;
    }
    
    // Aktualisiere durchschnittliche Kampfzeit
    float totalTime = m_learningData.averageCombatTime * (m_learningData.totalCombats - 1) + experience.combatDuration;
    m_learningData.averageCombatTime = totalTime / m_learningData.totalCombats;
    
    // Lerne Zaubereffektivität
    for (uint32 spellId : experience.spellsUsed)
    {
        auto it = experience.spellEffectiveness.find(spellId);
        if (it != experience.spellEffectiveness.end())
        {
            float currentRate = m_learningData.spellSuccessRates[spellId];
            float newRate = (currentRate + it->second) / 2.0f; // Gewichteter Durchschnitt
            m_learningData.spellSuccessRates[spellId] = newRate;
        }
    }
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} lernt aus Kampf: Siege={}, Niederlagen={}, Ø-Zeit={:.1f}ms", 
                 me->GetName(), m_learningData.wins, m_learningData.losses, m_learningData.averageCombatTime);
}

void AutonomousPlayerAI::EvaluateRoleAffinity()
{
    uint32 level = me->GetLevel();
    
    // Bewerte Rollenaffinität basierend auf Kampfstatistiken
    if (m_learningData.totalCombats > 0)
    {
        float winRate = static_cast<float>(m_learningData.wins) / m_learningData.totalCombats;
        
        // Tank-Affinität: Basiert auf überstandenem Schaden
        if (m_totalDamageTaken > 0)
        {
            float survivability = static_cast<float>(m_totalHealingDone) / m_totalDamageTaken;
            m_learningData.roleAffinities[AutonomousRole::ROLE_TANK] += survivability * 5.0f;
        }
        
        // Heiler-Affinität: Basiert auf Heilung
        if (m_totalHealingDone > 0)
        {
            m_learningData.roleAffinities[AutonomousRole::ROLE_HEALER] += 
                (static_cast<float>(m_totalHealingDone) / 1000.0f) * winRate;
        }
        
        // DPS-Affinität: Basiert auf Schaden
        if (m_totalDamageDealt > 0)
        {
            float dpsScore = (static_cast<float>(m_totalDamageDealt) / 1000.0f) * winRate;
            m_learningData.roleAffinities[AutonomousRole::ROLE_DPS_MELEE] += dpsScore;
            m_learningData.roleAffinities[AutonomousRole::ROLE_DPS_RANGED] += dpsScore;
            m_learningData.roleAffinities[AutonomousRole::ROLE_DPS_CASTER] += dpsScore;
        }
        
        // Explorer-Affinität: Basiert auf besuchten Zonen
        float explorationScore = static_cast<float>(m_learningData.visitedZones.size()) * 2.0f;
        m_learningData.roleAffinities[AutonomousRole::ROLE_EXPLORER] += explorationScore;
    }
    
    // Bestimme primäre Rolle basierend auf höchster Affinität
    if (level >= ROLE_DISCOVERY_MIN_LEVEL)
    {
        AutonomousRole newRole = DetermineOptimalRole();
        if (newRole != m_learningData.primaryRole)
        {
            SetPrimaryRole(newRole);
        }
    }
}

AutonomousRole AutonomousPlayerAI::DetermineOptimalRole()
{
    AutonomousRole bestRole = AutonomousRole::ROLE_UNDEFINED;
    float bestAffinity = 0.0f;
    
    for (const auto& pair : m_learningData.roleAffinities)
    {
        if (pair.second > bestAffinity)
        {
            bestAffinity = pair.second;
            bestRole = pair.first;
        }
    }
    
    return bestRole;
}

void AutonomousPlayerAI::SetPrimaryRole(AutonomousRole role)
{
    if (m_learningData.primaryRole != role)
    {
        TC_LOG_INFO("autonomous.npc", "NPC {} wechselt Rolle zu {}", 
                    me->GetName(), static_cast<uint32>(role));
        
        m_learningData.primaryRole = role;
        
        // Verhaltensmuster an neue Rolle anpassen
        switch (role)
        {
            case AutonomousRole::ROLE_TANK:
                m_aggressiveness = std::min(m_aggressiveness + 20, 100);
                m_patience = std::min(m_patience + 15, 100);
                break;
            case AutonomousRole::ROLE_HEALER:
                m_patience = std::min(m_patience + 25, 100);
                m_sociability = std::min(m_sociability + 10, 100);
                break;
            case AutonomousRole::ROLE_DPS_MELEE:
            case AutonomousRole::ROLE_DPS_RANGED:
            case AutonomousRole::ROLE_DPS_CASTER:
                m_aggressiveness = std::min(m_aggressiveness + 15, 100);
                break;
            case AutonomousRole::ROLE_EXPLORER:
                m_curiosity = std::min(m_curiosity + 30, 100);
                break;
            case AutonomousRole::ROLE_TRADER:
                m_intelligence = std::min(m_intelligence + 20, 100);
                m_sociability = std::min(m_sociability + 15, 100);
                break;
            default:
                break;
        }
    }
}

void AutonomousPlayerAI::ExecuteIdleBehavior()
{
    // Gelegentlich den Zustand wechseln
    if (urand(1, 100) <= m_curiosity)
    {
        // Neue Aktivität basierend auf Persönlichkeit wählen
        std::vector<BehaviorState> possibleStates;
        
        if (m_curiosity > 60)
            possibleStates.push_back(BehaviorState::STATE_EXPLORING);
        if (m_sociability > 50)
            possibleStates.push_back(BehaviorState::STATE_SOCIALIZING);
        if (m_intelligence > 70)
            possibleStates.push_back(BehaviorState::STATE_LEARNING);
        
        if (!possibleStates.empty())
        {
            size_t index = urand(0, possibleStates.size() - 1);
            m_previousState = m_currentState;
            m_currentState = possibleStates[index];
        }
    }
}

void AutonomousPlayerAI::ExecuteExplorationBehavior()
{
    if (m_explorationTimer <= 0)
    {
        m_explorationTimer = EXPLORATION_INTERVAL;
        
        // Wähle zufälligen Punkt in der Nähe
        float x, y, z;
        me->GetPosition(x, y, z);
        
        float angle = static_cast<float>(urand(0, 360)) * M_PI / 180.0f;
        float distance = static_cast<float>(urand(10, 50));
        
        float newX = x + cos(angle) * distance;
        float newY = y + sin(angle) * distance;
        
        me->GetMotionMaster()->MovePoint(0, newX, newY, z);
        
        // Merke besuchte Zone
        uint32 zoneId = me->GetZoneId();
        if (std::find(m_learningData.visitedZones.begin(), m_learningData.visitedZones.end(), zoneId) 
            == m_learningData.visitedZones.end())
        {
            m_learningData.visitedZones.push_back(zoneId);
            m_learningData.zonePreferences[zoneId] = 1;
            
            TC_LOG_DEBUG("autonomous.npc", "NPC {} entdeckt neue Zone: {}", me->GetName(), zoneId);
        }
        else
        {
            m_learningData.zonePreferences[zoneId]++;
        }
    }
    
    // Zurück zu IDLE nach Exploration
    if (urand(1, 100) <= 20) // 20% Chance
    {
        m_currentState = BehaviorState::STATE_IDLE;
    }
}

void AutonomousPlayerAI::ExecuteSocialBehavior()
{
    // Versuche mit nahestehenden Spielern zu interagieren
    // Dies wird in ProcessNearbyPlayers() implementiert
    
    // Kehre nach einer Weile zu IDLE zurück
    if (urand(1, 100) <= 30)
    {
        m_currentState = BehaviorState::STATE_IDLE;
    }
}

void AutonomousPlayerAI::ExecuteCraftingBehavior()
{
    // Hier könnte später Berufe-Interaktion implementiert werden
    // Für jetzt zurück zu IDLE
    m_currentState = BehaviorState::STATE_IDLE;
}

bool AutonomousPlayerAI::ShouldEngageTarget(Unit* target)
{
    if (!target || target == me)
        return false;
        
    // Spieler nicht angreifen (es sei denn PvP ist explizit gewollt)
    if (target->IsPlayer())
        return false;
        
    // Freundliche NPCs nicht angreifen
    if (me->IsFriendlyTo(target))
        return false;
        
    // Level-Unterschied prüfen
    int32 levelDiff = static_cast<int32>(target->GetLevel()) - static_cast<int32>(me->GetLevel());
    
    // Aggressiveness beeinflusst Bereitschaft schwierigere Gegner anzugreifen
    int32 maxLevelDiff = (m_aggressiveness / 20) - 2; // -2 bis +3 basierend auf Aggressiveness
    
    if (levelDiff > maxLevelDiff)
        return false;
        
    // Distanz prüfen
    if (me->GetDistance(target) > COMBAT_ENGAGE_DISTANCE)
        return false;
        
    return true;
}

void AutonomousPlayerAI::RandomizeCharacteristics()
{
    std::uniform_int_distribution<uint8> dist(20, 80);
    
    m_aggressiveness = dist(m_randomGenerator);
    m_curiosity = dist(m_randomGenerator);
    m_sociability = dist(m_randomGenerator);
    m_intelligence = dist(m_randomGenerator);
    m_patience = dist(m_randomGenerator);
    
    // Sorge für ausgewogene Persönlichkeiten (nicht alle Werte extrem)
    uint8 total = m_aggressiveness + m_curiosity + m_sociability + m_intelligence + m_patience;
    if (total > 350) // Zu hoch, reduziere Extremwerte
    {
        m_aggressiveness = std::min(m_aggressiveness, static_cast<uint8>(70));
        m_curiosity = std::min(m_curiosity, static_cast<uint8>(70));
        m_sociability = std::min(m_sociability, static_cast<uint8>(70));
        m_intelligence = std::min(m_intelligence, static_cast<uint8>(70));
        m_patience = std::min(m_patience, static_cast<uint8>(70));
    }
}

void AutonomousPlayerAI::SaveLearningData()
{
    // TODO: Implementiere Persistierung in Datenbank
    // Für jetzt nur Debug-Ausgabe
    TC_LOG_DEBUG("autonomous.npc", "Speichere Lerndaten für NPC {}: Kämpfe={}, Siege={}", 
                 me->GetName(), m_learningData.totalCombats, m_learningData.wins);
}

void AutonomousPlayerAI::LoadLearningData()
{
    // TODO: Implementiere Laden aus Datenbank
    TC_LOG_DEBUG("autonomous.npc", "Lade Lerndaten für NPC {}", me->GetName());
}

void AutonomousPlayerAI::SendRandomChat()
{
    if (m_socialMemory.learnedPhrases.empty())
        return;
        
    size_t index = urand(0, m_socialMemory.learnedPhrases.size() - 1);
    const std::string& phrase = m_socialMemory.learnedPhrases[index];
    
    me->Say(phrase, LANG_UNIVERSAL);
    
    TC_LOG_DEBUG("autonomous.npc", "NPC {} sagt: '{}'", me->GetName(), phrase);
}

void AutonomousPlayerAI::ProcessChatMessage(Player* sender, const std::string& message)
{
    if (!sender)
        return;
        
    // Lerne neue Phrasen aus Spielernachrichten
    if (message.length() > 3 && message.length() < 50)
    {
        // Einfache Filterung für angemessene Nachrichten
        bool isAppropriate = true;
        std::string lowerMsg = message;
        std::transform(lowerMsg.begin(), lowerMsg.end(), lowerMsg.begin(), ::tolower);
        
        // Hier könnten weitere Filter implementiert werden
        
        if (isAppropriate)
        {
            // Füge Phrase hinzu wenn noch nicht bekannt
            if (std::find(m_socialMemory.learnedPhrases.begin(), 
                          m_socialMemory.learnedPhrases.end(), message) 
                == m_socialMemory.learnedPhrases.end())
            {
                m_socialMemory.learnedPhrases.push_back(message);
                
                // Behalte Liste überschaubar
                if (m_socialMemory.learnedPhrases.size() > 100)
                {
                    m_socialMemory.learnedPhrases.erase(m_socialMemory.learnedPhrases.begin());
                }
            }
        }
    }
    
    // Verbessere Beziehung zu diesem Spieler
    auto it = m_socialMemory.relationshipValues.find(sender->GetGUID());
    if (it != m_socialMemory.relationshipValues.end())
    {
        it->second = std::min(it->second + 1, 100);
    }
    else
    {
        m_socialMemory.relationshipValues[sender->GetGUID()] = 1;
    }
    
    // Gelegentlich antworten
    if (urand(1, 100) <= m_sociability / 2)
    {
        RespondToPlayer(sender, message);
    }
}

void AutonomousPlayerAI::RespondToPlayer(Player* player, const std::string& context)
{
    if (!player || m_socialMemory.learnedPhrases.empty())
        return;
        
    // Wähle angemessene Antwort basierend auf Kontext und Beziehung
    int32 relationship = 0;
    auto it = m_socialMemory.relationshipValues.find(player->GetGUID());
    if (it != m_socialMemory.relationshipValues.end())
    {
        relationship = it->second;
    }
    
    std::vector<std::string> possibleResponses;
    
    // Freundliche Antworten für gute Beziehungen
    if (relationship > 20)
    {
        possibleResponses.push_back("Das ist interessant!");
        possibleResponses.push_back("Ich stimme zu.");
        possibleResponses.push_back("Danke für die Information.");
    }
    
    // Neutrale Antworten
    possibleResponses.push_back("Verstehe.");
    possibleResponses.push_back("Hmm.");
    possibleResponses.push_back("Interessant.");
    
    if (!possibleResponses.empty())
    {
        size_t index = urand(0, possibleResponses.size() - 1);
        me->Say(possibleResponses[index], LANG_UNIVERSAL);
    }
}

void AutonomousPlayerAI::UpdatePhaseProgression()
{
    uint32 level = me->GetLevel();
    LearningPhase newPhase = m_currentPhase;
    
    if (level >= ROLE_MASTERY_MIN_LEVEL)
        newPhase = LearningPhase::PHASE_MASTERY;
    else if (level >= ROLE_SPECIALIZATION_MIN_LEVEL)
        newPhase = LearningPhase::PHASE_SPECIALIZATION;
    else if (level >= ROLE_DISCOVERY_MIN_LEVEL)
        newPhase = LearningPhase::PHASE_ROLE_DISCOVERY;
    else
        newPhase = LearningPhase::PHASE_INITIALIZATION;
    
    if (newPhase != m_currentPhase)
    {
        TC_LOG_INFO("autonomous.npc", "NPC {} erreicht Lernphase: {}", 
                    me->GetName(), static_cast<uint32>(newPhase));
        m_currentPhase = newPhase;
    }
}

void AutonomousPlayerAI::SelectBestSpell(Unit* target)
{
    // Einfache Zauberauswahl basierend auf gelernten Präferenzen
    // TODO: Erweiterte Logik basierend auf Rolle und Lerndaten
    
    if (!target)
        return;
        
    // Für jetzt: Standard Angriff
    me->AttackerStateUpdate(target);
}

void AutonomousPlayerAI::EvaluateCurrentSituation()
{
    // Bewerte aktuelle Umgebung und treffe Entscheidungen
    uint32 nearbyEnemies = 0;
    uint32 nearbyPlayers = 0;
    
    // TODO: Implementiere Umgebungsanalyse
    
    // Basierend auf Situation Verhalten anpassen
    if (nearbyEnemies > 0 && m_aggressiveness > 60)
    {
        m_currentState = BehaviorState::STATE_EXPLORING; // Suche Kämpfe
    }
    else if (nearbyPlayers > 0 && m_sociability > 50)
    {
        m_currentState = BehaviorState::STATE_SOCIALIZING;
    }
}

void AutonomousPlayerAI::MakeAutonomousDecision()
{
    uint32 currentTime = getMSTime();
    
    // Entscheide nur alle paar Sekunden neu
    if (currentTime - m_lastDecisionTime < 3000)
        return;
        
    m_lastDecisionTime = currentTime;
    
    // Entscheidungslogik basierend auf Persönlichkeit und Situation
    std::vector<std::pair<BehaviorState, uint32>> options;
    
    // Gewichte basierend auf Persönlichkeitsmerkmalen
    options.push_back({BehaviorState::STATE_IDLE, m_patience});
    options.push_back({BehaviorState::STATE_EXPLORING, m_curiosity});
    options.push_back({BehaviorState::STATE_SOCIALIZING, m_sociability});
    options.push_back({BehaviorState::STATE_LEARNING, m_intelligence});
    
    // Wähle Option basierend auf Gewichtung
    uint32 totalWeight = 0;
    for (const auto& option : options)
    {
        totalWeight += option.second;
    }
    
    if (totalWeight > 0)
    {
        uint32 randomValue = urand(1, totalWeight);
        uint32 currentSum = 0;
        
        for (const auto& option : options)
        {
            currentSum += option.second;
            if (randomValue <= currentSum)
            {
                if (option.first != m_currentState)
                {
                    m_previousState = m_currentState;
                    m_currentState = option.first;
                }
                break;
            }
        }
    }
}

uint32 AutonomousPlayerAI::CalculateSpellEffectiveness(uint32 spellId, Unit* target)
{
    // TODO: Implementiere Zaubereffektivitätsberechnung
    return 50; // Platzhalter
}

void AutonomousPlayerAI::LogExperience(const std::string& event, const std::string& details)
{
    TC_LOG_DEBUG("autonomous.npc", "NPC {} Erfahrung - {}: {}", me->GetName(), event, details);
}

bool AutonomousPlayerAI::IsInSafeZone() const
{
    // TODO: Implementiere Sicherheitszonenerkennung
    return true;
}

void AutonomousPlayerAI::SeekNearbyInteractions()
{
    // TODO: Implementiere aktive Suche nach Interaktionsmöglichkeiten
}

void AutonomousPlayerAI::ProcessNearbyCreatures()
{
    // TODO: Implementiere Interaktion mit anderen NPCs
}

void AutonomousPlayerAI::ProcessNearbyPlayers()
{
    // TODO: Implementiere erweiterte Spielerinteraktion
}

void AutonomousPlayerAI::OptimizeSpellRotation()
{
    // TODO: Implementiere Zauberrotations-Optimierung basierend auf Lerndaten
}