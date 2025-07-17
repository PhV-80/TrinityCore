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

#ifndef TRINITY_AUTONOMOUSNPCCONFIG_H
#define TRINITY_AUTONOMOUSNPCCONFIG_H

#include "Define.h"

// Konfigurationswerte für autonome NPCs
struct AutonomousNPCConfig
{
    // Maximale Anzahl aktiver autonomer NPCs
    static uint32 MaxActiveNPCs;
    
    // Respektiere Spielerkapazität des Realms
    static bool RespectPlayerCap;
    
    // Automatisches Ausloggen bei Spielerlimit
    static bool AutoLogoutOnPlayerLimit;
    
    // Lerndaten in Datenbank persistieren
    static bool PersistLearningData;
    
    // Debug-Logging aktivieren
    static bool EnableDebugLogging;
    
    // Chat-Verhalten
    static bool EnableChatLearning;
    static uint32 MaxLearnedPhrases;
    static uint32 ChatResponseChance; // Prozent
    
    // Kampfverhalten
    static bool EnableCombatLearning;
    static uint32 MaxCombatHistory;
    static bool AggressiveMode;
    
    // Exploration
    static bool EnableExploration;
    static float ExplorationRadius;
    static uint32 ExplorationCooldown;
    
    // Sozialverhalten
    static bool EnableSocialInteraction;
    static float SocialInteractionRadius;
    static uint32 RelationshipDecayTime;
    
    // Performance
    static uint32 AIUpdateInterval;
    static uint32 LearningUpdateInterval;
    static uint32 SocialUpdateInterval;
    
    // Datenbankoptionen
    static std::string LearningDataTable;
    static uint32 SaveInterval;
    
    // Initialisierung
    static void LoadConfig();
    static void ReloadConfig();
    static bool IsEnabled();
    
    // Hilfsfunktionen
    static uint32 GetActiveNPCCount();
    static bool CanSpawnNewNPC();
    static void NotifyNPCSpawned();
    static void NotifyNPCDespawned();
    
private:
    static uint32 s_activeNPCCount;
    static bool s_configLoaded;
};

// Standardwerte
constexpr uint32 DEFAULT_MAX_ACTIVE_NPCS = 25;
constexpr bool DEFAULT_RESPECT_PLAYER_CAP = true;
constexpr bool DEFAULT_AUTO_LOGOUT_ON_LIMIT = true;
constexpr bool DEFAULT_PERSIST_LEARNING_DATA = true;
constexpr bool DEFAULT_ENABLE_DEBUG_LOGGING = false;
constexpr bool DEFAULT_ENABLE_CHAT_LEARNING = true;
constexpr uint32 DEFAULT_MAX_LEARNED_PHRASES = 100;
constexpr uint32 DEFAULT_CHAT_RESPONSE_CHANCE = 30;
constexpr bool DEFAULT_ENABLE_COMBAT_LEARNING = true;
constexpr uint32 DEFAULT_MAX_COMBAT_HISTORY = 50;
constexpr bool DEFAULT_AGGRESSIVE_MODE = false;
constexpr bool DEFAULT_ENABLE_EXPLORATION = true;
constexpr float DEFAULT_EXPLORATION_RADIUS = 100.0f;
constexpr uint32 DEFAULT_EXPLORATION_COOLDOWN = 15000;
constexpr bool DEFAULT_ENABLE_SOCIAL_INTERACTION = true;
constexpr float DEFAULT_SOCIAL_INTERACTION_RADIUS = 15.0f;
constexpr uint32 DEFAULT_RELATIONSHIP_DECAY_TIME = 86400000; // 24 Stunden
constexpr uint32 DEFAULT_AI_UPDATE_INTERVAL = 2000;
constexpr uint32 DEFAULT_LEARNING_UPDATE_INTERVAL = 5000;
constexpr uint32 DEFAULT_SOCIAL_UPDATE_INTERVAL = 10000;
constexpr uint32 DEFAULT_SAVE_INTERVAL = 300000; // 5 Minuten

#endif // TRINITY_AUTONOMOUSNPCCONFIG_H