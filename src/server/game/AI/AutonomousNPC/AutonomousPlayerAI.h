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
#include "Creature.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "ObjectGuid.h"
#include "Position.h"
#include <map>
#include <vector>
#include <memory>

// Forward declarations
class Unit;
class Spell;
class Item;

// Enums for autonomous behavior
enum class PersonalityTrait : uint8
{
    AGGRESSIVE = 0,
    CAUTIOUS = 1,
    SOCIAL = 2,
    EXPLORER = 3,
    TRADER = 4,
    CRAFTER = 5,
    MAX_TRAITS = 6
};

enum class AutonomousGoal : uint8
{
    LEVEL_UP = 0,
    EXPLORE_ZONE = 1,
    LEARN_PROFESSION = 2,
    SOCIALIZE = 3,
    TRADE = 4,
    HUNT_TREASURE = 5,
    HELP_PLAYERS = 6,
    MAX_GOALS = 7
};

enum class CombatRole : uint8
{
    UNDECIDED = 0,
    MELEE_DPS = 1,
    RANGED_DPS = 2,
    TANK = 3,
    HEALER = 4,
    SUPPORT = 5,
    MAX_ROLES = 6
};

// Data structures for learning and memory
struct CombatExperience
{
    uint32 spellId;
    uint32 damageDealt;
    uint32 damageTaken;
    uint32 healingDone;
    bool wasSuccessful;
    uint32 timestamp;
    ObjectGuid targetGuid;
};

struct SocialInteraction
{
    ObjectGuid playerGuid;
    std::string playerName;
    uint32 interactionType; // 0=hostile, 1=neutral, 2=friendly, 3=helpful
    uint32 timestamp;
    std::string lastMessage;
};

struct ExplorationData
{
    uint32 zoneId;
    uint32 areaId;
    Position lastPosition;
    uint32 timeSpent;
    bool hasQuestObjectives;
    uint32 timestamp;
};

struct LearningData
{
    std::map<uint32, uint32> spellSuccessCount;
    std::map<uint32, uint32> spellFailureCount;
    std::map<uint32, float> spellEffectiveness; // damage/healing per cast
    std::map<PersonalityTrait, float> traitStrengths;
    std::vector<CombatExperience> combatHistory;
    std::vector<SocialInteraction> socialHistory;
    std::vector<ExplorationData> explorationHistory;
    CombatRole preferredRole;
    float adaptationRate;
};

struct AutonomousGoalData
{
    AutonomousGoal currentGoal;
    uint32 goalStartTime;
    uint32 goalTimeout;
    float goalProgress;
    std::map<AutonomousGoal, float> goalPriorities;
    ObjectGuid currentTarget;
    Position targetLocation;
};

class TC_GAME_API AutonomousPlayerAI : public CreatureAI
{
public:
    explicit AutonomousPlayerAI(Creature* creature);
    ~AutonomousPlayerAI() override = default;

    // Core AI Interface
    void Reset() override;
    void UpdateAI(uint32 diff) override;
    void InitializeAI() override;
    void JustAppeared() override;

    // Combat Events
    void JustEngagedWith(Unit* who) override;
    void JustDied(Unit* killer) override;
    void KilledUnit(Unit* victim) override;
    void DamageTaken(Unit* attacker, uint32& damage, DamageEffectType damagetype, SpellInfo const* spellInfo = nullptr) override;
    void HealReceived(Unit* healer, uint32& heal) override;
    void SpellHit(WorldObject* caster, SpellInfo const* spellInfo) override;
    void SpellHitTarget(WorldObject* target, SpellInfo const* spellInfo) override;

    // Social Events
    void ReceiveEmote(Player* player, uint32 emoteId) override;
    bool OnGossipHello(Player* player) override;
    bool OnGossipSelect(Player* player, uint32 menuId, uint32 gossipListId) override;

    // Movement Events
    void MovementInform(uint32 type, uint32 id) override;
    void JustReachedHome() override;

    // Learning and Adaptation
    void RecordCombatExperience(uint32 spellId, uint32 damage, uint32 healing, bool success, ObjectGuid target);
    void RecordSocialInteraction(Player* player, uint32 interactionType, const std::string& message = "");
    void RecordExploration(uint32 zoneId, uint32 areaId, Position pos);
    void AnalyzeAndAdapt();
    void UpdatePersonality();
    void DetermineOptimalRole();

    // Autonomous Behavior
    void SelectNewGoal();
    void PursueCurrentGoal();
    void EvaluateEnvironment();
    void MakeAutonomousDecision();

    // Character Creation Simulation
    void RandomizeAppearance();
    void AssignInitialStats();
    void DetermineStartingPersonality();

    // World Interaction
    void AttemptSocialInteraction();
    void ExploreNearbyArea();
    void SeekTradeOpportunities();
    void LookForQuests();
    void ConsiderProfessionTraining();

    // Utility Functions
    bool ShouldEngageTarget(Unit* target) const;
    uint32 SelectOptimalSpell(Unit* target) const;
    Position FindNearbyExplorationPoint() const;
    Player* FindNearbyPlayer() const;
    float CalculateSpellEffectiveness(uint32 spellId) const;
    bool IsLocationSafe(Position pos) const;

    // Getters for debugging/monitoring
    const LearningData& GetLearningData() const { return _learningData; }
    const AutonomousGoalData& GetGoalData() const { return _goalData; }
    PersonalityTrait GetDominantTrait() const;
    CombatRole GetCurrentRole() const { return _learningData.preferredRole; }

private:
    // Core Data
    LearningData _learningData;
    AutonomousGoalData _goalData;
    
    // Timers
    uint32 _updateTimer;
    uint32 _adaptationTimer;
    uint32 _goalEvaluationTimer;
    uint32 _socialTimer;
    uint32 _explorationTimer;
    
    // State Tracking
    bool _initialized;
    bool _isAdapting;
    uint32 _adaptationLevel;
    uint32 _experiencePoints;
    uint32 _socialPoints;
    uint32 _explorationPoints;
    
    // Behavior Flags
    bool _canChat;
    bool _canTrade;
    bool _canGroupUp;
    bool _canUseAuctionHouse;
    bool _canLearnProfessions;
    
    // Internal Helper Methods
    void InitializePersonality();
    void LoadPersistedData();
    void SavePersistedData();
    void ProcessCombatAI(uint32 diff);
    void ProcessSocialAI(uint32 diff);
    void ProcessExplorationAI(uint32 diff);
    void ProcessLearningAI(uint32 diff);
    
    // Combat Helpers
    void ExecuteCombatStrategy();
    void AdaptCombatTactics();
    bool ShouldUseSpell(uint32 spellId, Unit* target) const;
    void LearnFromCombatOutcome(bool victory, Unit* opponent);
    
    // Social Helpers
    void InitiateConversation(Player* player);
    void RespondToPlayer(Player* player, const std::string& message);
    std::string GenerateResponse(Player* player, const std::string& input);
    void UpdateSocialMemory(Player* player, uint32 interactionType);
    
    // Exploration Helpers
    void SetExplorationTarget();
    void EvaluateCurrentLocation();
    bool ShouldMoveToNewArea() const;
    void RecordAreaKnowledge();
    
    // Learning Helpers
    void UpdateSpellStatistics(uint32 spellId, bool success, float effectiveness);
    void RecalculateTraitStrengths();
    void AdjustGoalPriorities();
    float CalculateAdaptationProgress() const;
};

#endif // TRINITY_AUTONOMOUSPLAYERAI_H
