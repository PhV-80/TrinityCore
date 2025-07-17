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

#include "AutonomousNPCConfig.h"
#include "Config.h"
#include "Log.h"
#include "World.h"

// Statische Variablen definieren
uint32 AutonomousNPCConfig::MaxActiveNPCs = DEFAULT_MAX_ACTIVE_NPCS;
bool AutonomousNPCConfig::RespectPlayerCap = DEFAULT_RESPECT_PLAYER_CAP;
bool AutonomousNPCConfig::AutoLogoutOnPlayerLimit = DEFAULT_AUTO_LOGOUT_ON_LIMIT;
bool AutonomousNPCConfig::PersistLearningData = DEFAULT_PERSIST_LEARNING_DATA;
bool AutonomousNPCConfig::EnableDebugLogging = DEFAULT_ENABLE_DEBUG_LOGGING;
bool AutonomousNPCConfig::EnableChatLearning = DEFAULT_ENABLE_CHAT_LEARNING;
uint32 AutonomousNPCConfig::MaxLearnedPhrases = DEFAULT_MAX_LEARNED_PHRASES;
uint32 AutonomousNPCConfig::ChatResponseChance = DEFAULT_CHAT_RESPONSE_CHANCE;
bool AutonomousNPCConfig::EnableCombatLearning = DEFAULT_ENABLE_COMBAT_LEARNING;
uint32 AutonomousNPCConfig::MaxCombatHistory = DEFAULT_MAX_COMBAT_HISTORY;
bool AutonomousNPCConfig::AggressiveMode = DEFAULT_AGGRESSIVE_MODE;
bool AutonomousNPCConfig::EnableExploration = DEFAULT_ENABLE_EXPLORATION;
float AutonomousNPCConfig::ExplorationRadius = DEFAULT_EXPLORATION_RADIUS;
uint32 AutonomousNPCConfig::ExplorationCooldown = DEFAULT_EXPLORATION_COOLDOWN;
bool AutonomousNPCConfig::EnableSocialInteraction = DEFAULT_ENABLE_SOCIAL_INTERACTION;
float AutonomousNPCConfig::SocialInteractionRadius = DEFAULT_SOCIAL_INTERACTION_RADIUS;
uint32 AutonomousNPCConfig::RelationshipDecayTime = DEFAULT_RELATIONSHIP_DECAY_TIME;
uint32 AutonomousNPCConfig::AIUpdateInterval = DEFAULT_AI_UPDATE_INTERVAL;
uint32 AutonomousNPCConfig::LearningUpdateInterval = DEFAULT_LEARNING_UPDATE_INTERVAL;
uint32 AutonomousNPCConfig::SocialUpdateInterval = DEFAULT_SOCIAL_UPDATE_INTERVAL;
std::string AutonomousNPCConfig::LearningDataTable = "autonomous_npc_learning";
uint32 AutonomousNPCConfig::SaveInterval = DEFAULT_SAVE_INTERVAL;

uint32 AutonomousNPCConfig::s_activeNPCCount = 0;
bool AutonomousNPCConfig::s_configLoaded = false;

void AutonomousNPCConfig::LoadConfig()
{
    TC_LOG_INFO("server.loading", "Loading Autonomous NPC configuration...");
    
    // Grundeinstellungen
    MaxActiveNPCs = sConfigMgr->GetIntDefault("AutonomousNPC.MaxCount", DEFAULT_MAX_ACTIVE_NPCS);
    RespectPlayerCap = sConfigMgr->GetBoolDefault("AutonomousNPC.RespectPlayerCap", DEFAULT_RESPECT_PLAYER_CAP);
    AutoLogoutOnPlayerLimit = sConfigMgr->GetBoolDefault("AutonomousNPC.AutoLogoutOnPlayerLimit", DEFAULT_AUTO_LOGOUT_ON_LIMIT);
    PersistLearningData = sConfigMgr->GetBoolDefault("AutonomousNPC.PersistLearningData", DEFAULT_PERSIST_LEARNING_DATA);
    EnableDebugLogging = sConfigMgr->GetBoolDefault("AutonomousNPC.EnableDebugLogging", DEFAULT_ENABLE_DEBUG_LOGGING);
    
    // Chat-Einstellungen
    EnableChatLearning = sConfigMgr->GetBoolDefault("AutonomousNPC.EnableChatLearning", DEFAULT_ENABLE_CHAT_LEARNING);
    MaxLearnedPhrases = sConfigMgr->GetIntDefault("AutonomousNPC.MaxLearnedPhrases", DEFAULT_MAX_LEARNED_PHRASES);
    ChatResponseChance = sConfigMgr->GetIntDefault("AutonomousNPC.ChatResponseChance", DEFAULT_CHAT_RESPONSE_CHANCE);
    
    // Kampf-Einstellungen
    EnableCombatLearning = sConfigMgr->GetBoolDefault("AutonomousNPC.EnableCombatLearning", DEFAULT_ENABLE_COMBAT_LEARNING);
    MaxCombatHistory = sConfigMgr->GetIntDefault("AutonomousNPC.MaxCombatHistory", DEFAULT_MAX_COMBAT_HISTORY);
    AggressiveMode = sConfigMgr->GetBoolDefault("AutonomousNPC.AggressiveMode", DEFAULT_AGGRESSIVE_MODE);
    
    // Exploration-Einstellungen
    EnableExploration = sConfigMgr->GetBoolDefault("AutonomousNPC.EnableExploration", DEFAULT_ENABLE_EXPLORATION);
    ExplorationRadius = sConfigMgr->GetFloatDefault("AutonomousNPC.ExplorationRadius", DEFAULT_EXPLORATION_RADIUS);
    ExplorationCooldown = sConfigMgr->GetIntDefault("AutonomousNPC.ExplorationCooldown", DEFAULT_EXPLORATION_COOLDOWN);
    
    // Sozial-Einstellungen
    EnableSocialInteraction = sConfigMgr->GetBoolDefault("AutonomousNPC.EnableSocialInteraction", DEFAULT_ENABLE_SOCIAL_INTERACTION);
    SocialInteractionRadius = sConfigMgr->GetFloatDefault("AutonomousNPC.SocialInteractionRadius", DEFAULT_SOCIAL_INTERACTION_RADIUS);
    RelationshipDecayTime = sConfigMgr->GetIntDefault("AutonomousNPC.RelationshipDecayTime", DEFAULT_RELATIONSHIP_DECAY_TIME);
    
    // Performance-Einstellungen
    AIUpdateInterval = sConfigMgr->GetIntDefault("AutonomousNPC.AIUpdateInterval", DEFAULT_AI_UPDATE_INTERVAL);
    LearningUpdateInterval = sConfigMgr->GetIntDefault("AutonomousNPC.LearningUpdateInterval", DEFAULT_LEARNING_UPDATE_INTERVAL);
    SocialUpdateInterval = sConfigMgr->GetIntDefault("AutonomousNPC.SocialUpdateInterval", DEFAULT_SOCIAL_UPDATE_INTERVAL);
    
    // Datenbank-Einstellungen
    LearningDataTable = sConfigMgr->GetStringDefault("AutonomousNPC.LearningDataTable", "autonomous_npc_learning");
    SaveInterval = sConfigMgr->GetIntDefault("AutonomousNPC.SaveInterval", DEFAULT_SAVE_INTERVAL);
    
    // Validierung der Konfigurationswerte
    if (MaxActiveNPCs > 100)
    {
        TC_LOG_WARN("autonomous.npc", "AutonomousNPC.MaxCount ist sehr hoch ({}). Empfohlen: <= 100", MaxActiveNPCs);
    }
    
    if (ChatResponseChance > 100)
    {
        TC_LOG_ERROR("autonomous.npc", "AutonomousNPC.ChatResponseChance ist ungültig ({}). Setze auf 30.", ChatResponseChance);
        ChatResponseChance = 30;
    }
    
    if (ExplorationRadius > 500.0f)
    {
        TC_LOG_WARN("autonomous.npc", "AutonomousNPC.ExplorationRadius ist sehr hoch ({:.1f}). Kann Performance beeinträchtigen.", ExplorationRadius);
    }
    
    if (AIUpdateInterval < 1000)
    {
        TC_LOG_WARN("autonomous.npc", "AutonomousNPC.AIUpdateInterval ist sehr niedrig ({}ms). Kann Performance beeinträchtigen.", AIUpdateInterval);
    }
    
    s_configLoaded = true;
    
    TC_LOG_INFO("autonomous.npc", "Autonomous NPC Konfiguration geladen:");
    TC_LOG_INFO("autonomous.npc", "  Max NPCs: {}", MaxActiveNPCs);
    TC_LOG_INFO("autonomous.npc", "  Respektiere Spielergrenze: {}", RespectPlayerCap ? "Ja" : "Nein");
    TC_LOG_INFO("autonomous.npc", "  Chat-Lernen: {}", EnableChatLearning ? "Aktiviert" : "Deaktiviert");
    TC_LOG_INFO("autonomous.npc", "  Kampf-Lernen: {}", EnableCombatLearning ? "Aktiviert" : "Deaktiviert");
    TC_LOG_INFO("autonomous.npc", "  Exploration: {}", EnableExploration ? "Aktiviert" : "Deaktiviert");
    TC_LOG_INFO("autonomous.npc", "  Soziale Interaktion: {}", EnableSocialInteraction ? "Aktiviert" : "Deaktiviert");
    TC_LOG_INFO("autonomous.npc", "  Debug-Logging: {}", EnableDebugLogging ? "Aktiviert" : "Deaktiviert");
}

void AutonomousNPCConfig::ReloadConfig()
{
    TC_LOG_INFO("autonomous.npc", "Autonomous NPC Konfiguration wird neu geladen...");
    LoadConfig();
}

bool AutonomousNPCConfig::IsEnabled()
{
    if (!s_configLoaded)
    {
        LoadConfig();
    }
    
    return MaxActiveNPCs > 0;
}

uint32 AutonomousNPCConfig::GetActiveNPCCount()
{
    return s_activeNPCCount;
}

bool AutonomousNPCConfig::CanSpawnNewNPC()
{
    if (!IsEnabled())
        return false;
        
    if (s_activeNPCCount >= MaxActiveNPCs)
        return false;
        
    // Prüfe Spielerkapazität wenn aktiviert
    if (RespectPlayerCap)
    {
        uint32 currentPlayers = sWorld->GetPlayerCount();
        uint32 maxPlayers = sWorld->GetPlayerAmountLimit();
        
        // Reserviere Plätze für echte Spieler
        uint32 reservedSlots = std::min(maxPlayers / 4, 10u); // 25% oder maximal 10 Slots
        
        if (currentPlayers + s_activeNPCCount + 1 > maxPlayers - reservedSlots)
        {
            TC_LOG_DEBUG("autonomous.npc", "Kann keinen neuen autonomen NPC spawnen - Spielerkapazität erreicht ({}/{} Spieler)", 
                         currentPlayers, maxPlayers);
            return false;
        }
    }
    
    return true;
}

void AutonomousNPCConfig::NotifyNPCSpawned()
{
    s_activeNPCCount++;
    TC_LOG_DEBUG("autonomous.npc", "Autonomer NPC gespawnt. Aktive NPCs: {}/{}", s_activeNPCCount, MaxActiveNPCs);
}

void AutonomousNPCConfig::NotifyNPCDespawned()
{
    if (s_activeNPCCount > 0)
    {
        s_activeNPCCount--;
        TC_LOG_DEBUG("autonomous.npc", "Autonomer NPC despawnt. Aktive NPCs: {}/{}", s_activeNPCCount, MaxActiveNPCs);
    }
}