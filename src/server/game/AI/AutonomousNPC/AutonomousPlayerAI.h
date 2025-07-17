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

#ifndef TRINITY_AUTONOMOUSPLAYERAI_H
#define TRINITY_AUTONOMOUSPLAYERAI_H

#include "CreatureAI.h"
#include "ObjectMgr.h"
#include "Timer.h"
#include <map>
#include <vector>
#include <random>

enum class AutonomousRole : uint8
{
    ROLE_UNDEFINED = 0,
    ROLE_DPS_MELEE,
    ROLE_DPS_RANGED,
    ROLE_DPS_CASTER,
    ROLE_TANK,
    ROLE_HEALER,
    ROLE_SUPPORT,
    ROLE_EXPLORER,
    ROLE_TRADER
};

enum class LearningPhase : uint8
{
    PHASE_INITIALIZATION = 0,    // Level 1-5: Lernt Grundlagen
    PHASE_ROLE_DISCOVERY,        // Level 6-10: Experimentiert mit Rollen
    PHASE_SPECIALIZATION,        // Level 11-20: Fokussiert auf gewählte Rolle
    PHASE_MASTERY,              // Level 21+: Meistert komplexe Strategien
    PHASE_SOCIAL_INTEGRATION    // Alle Level: Lernt soziale Interaktion
};

enum class BehaviorState : uint8
{
    STATE_IDLE = 0,
    STATE_EXPLORING,
    STATE_COMBAT,
    STATE_SOCIALIZING,
    STATE_TRADING,
    STATE_LEARNING,
    STATE_CRAFTING,
    STATE_RESTING
};

struct CombatExperience
{
    uint32 enemyEntry;
    uint32 enemyLevel;
    uint32 damageDealt;
    uint32 damageTaken;
    uint32 healingDone;
    uint32 manaUsed;
    uint32 combatDuration;
    bool victory;
    std::vector<uint32> spellsUsed;
    std::map<uint32, uint32> spellEffectiveness; // Spell ID -> Effectiveness Score
    
    CombatExperience() : enemyEntry(0), enemyLevel(0), damageDealt(0), 
                        damageTaken(0), healingDone(0), manaUsed(0), 
                        combatDuration(0), victory(false) { }
};

struct SocialMemory
{
    std::map<ObjectGuid, uint32> playerInteractions; // GUID -> Interaction Count
    std::map<ObjectGuid, int32> relationshipValues;  // GUID -> Relationship (-100 to +100)
    std::vector<std::string> learnedPhrases;
    uint32 lastChatTime;
    
    SocialMemory() : lastChatTime(0) { }
};

struct LearningData
{
    // Kampfstatistiken
    uint32 totalCombats;
    uint32 wins;
    uint32 losses;
    float averageCombatTime;
    std::map<uint32, float> spellSuccessRates;
    
    // Rollenverteilung basierend auf Erfahrung
    std::map<AutonomousRole, float> roleAffinities;
    AutonomousRole primaryRole;
    AutonomousRole secondaryRole;
    
    // Exploration
    std::vector<uint32> visitedZones;
    std::map<uint32, uint32> zonePreferences; // Zone ID -> Preference Score
    
    LearningData() : totalCombats(0), wins(0), losses(0), averageCombatTime(0.0f),
                    primaryRole(AutonomousRole::ROLE_UNDEFINED),
                    secondaryRole(AutonomousRole::ROLE_UNDEFINED) { }
};

class TC_GAME_API AutonomousPlayerAI : public CreatureAI
{
    public:
        explicit AutonomousPlayerAI(Creature* creature);
        virtual ~AutonomousPlayerAI();

        // Basis CreatureAI Overrides
        void Reset() override;
        void UpdateAI(uint32 diff) override;
        void JustEnteredCombat(Unit* who) override;
        void JustDied(Unit* killer) override;
        void KilledUnit(Unit* victim) override;
        void EnterEvadeMode(EvadeReason why = EVADE_REASON_OTHER) override;
        void MoveInLineOfSight(Unit* who) override;

        // Autonome Funktionen
        void InitializeAsNewCharacter();
        void UpdateBehavior(uint32 diff);
        void UpdateLearning(uint32 diff);
        void UpdateSocialBehavior(uint32 diff);
        
        // Kampfsystem
        void AnalyzeCombatResult(bool victory, Unit* opponent);
        void LearnFromCombat(const CombatExperience& experience);
        void OptimizeSpellRotation();
        
        // Rollenermittlung
        void EvaluateRoleAffinity();
        void SetPrimaryRole(AutonomousRole role);
        AutonomousRole DetermineOptimalRole();
        
        // Verhalten
        void ExecuteIdleBehavior();
        void ExecuteExplorationBehavior();
        void ExecuteSocialBehavior();
        void ExecuteCraftingBehavior();
        
        // Hilfsfunktionen
        bool ShouldEngageTarget(Unit* target);
        void RandomizeCharacteristics();
        void SaveLearningData();
        void LoadLearningData();
        
        // Chat und Kommunikation
        void ProcessChatMessage(Player* sender, const std::string& message);
        void SendRandomChat();
        void RespondToPlayer(Player* player, const std::string& context);
        
        // Getter
        AutonomousRole GetPrimaryRole() const { return m_learningData.primaryRole; }
        LearningPhase GetCurrentPhase() const { return m_currentPhase; }
        BehaviorState GetCurrentState() const { return m_currentState; }

    private:
        // Zustandsverwaltung
        LearningPhase m_currentPhase;
        BehaviorState m_currentState;
        BehaviorState m_previousState;
        
        // Lernkomponenten
        LearningData m_learningData;
        std::vector<CombatExperience> m_combatHistory;
        SocialMemory m_socialMemory;
        
        // Timer
        uint32 m_behaviorUpdateTimer;
        uint32 m_learningUpdateTimer;
        uint32 m_socialUpdateTimer;
        uint32 m_explorationTimer;
        uint32 m_chatTimer;
        
        // Kampfvariablen
        uint32 m_combatStartTime;
        uint32 m_totalDamageDealt;
        uint32 m_totalDamageTaken;
        uint32 m_totalHealingDone;
        uint32 m_totalManaUsed;
        std::vector<uint32> m_currentCombatSpells;
        
        // Persönlichkeitsmerkmale
        uint8 m_aggressiveness;    // 0-100
        uint8 m_curiosity;         // 0-100  
        uint8 m_sociability;       // 0-100
        uint8 m_intelligence;      // 0-100
        uint8 m_patience;          // 0-100
        
        // Hilfsvariablen
        std::mt19937 m_randomGenerator;
        ObjectGuid m_currentTarget;
        uint32 m_lastDecisionTime;
        
        // Private Hilfsfunktionen
        void UpdatePhaseProgression();
        void SelectBestSpell(Unit* target);
        void EvaluateCurrentSituation();
        void MakeAutonomousDecision();
        uint32 CalculateSpellEffectiveness(uint32 spellId, Unit* target);
        void LogExperience(const std::string& event, const std::string& details);
        bool IsInSafeZone() const;
        void SeekNearbyInteractions();
        void ProcessNearbyCreatures();
        void ProcessNearbyPlayers();
};

#endif // TRINITY_AUTONOMOUSPLAYERAI_H