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

#ifndef TRINITY_GAMEEVENT_MGR_H
#define TRINITY_GAMEEVENT_MGR_H

#include "Common.h"
#include "SharedDefines.h"
#include "Define.h"
#include "ObjectGuid.h"
#include <list>
#include <map>
#include <set>
#include <unordered_map>
#include <vector>

#define max_ge_check_delay DAY  // 1 day in seconds

enum GameEventState
{
    GAMEEVENT_NORMAL           = 0, // standard game events
    GAMEEVENT_WORLD_INACTIVE   = 1, // not yet started
    GAMEEVENT_WORLD_CONDITIONS = 2, // condition matching phase
    GAMEEVENT_WORLD_NEXTPHASE  = 3, // conditions are met, now 'length' timer to start next event
    GAMEEVENT_WORLD_FINISHED   = 4, // next events are started, unapply this one
    GAMEEVENT_INTERNAL         = 5  // never handled in update
};

struct GameEventFinishCondition
{
    float reqNum;  // required number // use float, since some events use percent
    float done;    // done number
    uint32 max_world_state;  // max resource count world state update id
    uint32 done_world_state; // done resource count world state update id
};

struct GameEventQuestToEventConditionNum
{
    uint16 event_id;
    uint32 condition;
    float num;
};

typedef std::map<uint32 /*condition id*/, GameEventFinishCondition> GameEventConditionMap;

struct GameEventData
{
    GameEventData() : start(1), end(0), nextstart(0), occurence(0), length(0), holiday_id(HOLIDAY_NONE), holidayStage(0), state(GAMEEVENT_NORMAL),
                      announce(0) { }
    time_t start;           // occurs after this time
    time_t end;             // occurs before this time
    time_t nextstart;       // after this time the follow-up events count this phase completed
    uint32 occurence;       // time between end and start
    uint32 length;          // length of the event (minutes) after finishing all conditions
    HolidayIds holiday_id;
    uint8 holidayStage;
    GameEventState state;   // state of the game event, these are saved into the game_event table on change!
    GameEventConditionMap conditions;  // conditions to finish
    std::set<uint16 /*gameevent id*/> prerequisite_events;  // events that must be completed before starting this event
    std::string description;
    uint8 announce;         // if 0 dont announce, if 1 announce, if 2 take config value

    bool isValid() const { return length > 0 || state > GAMEEVENT_NORMAL; }
};

struct ModelEquip
{
    uint32 modelid;
    uint32 modelid_prev;
    uint8 equipment_id;
    uint8 equipement_id_prev;
};

class Creature;
class Player;
class Quest;
struct VendorItem;

class TC_GAME_API GameEventMgr
{
    private:
        GameEventMgr();
        ~GameEventMgr();

    public:
        GameEventMgr(GameEventMgr const&) = delete;
        GameEventMgr(GameEventMgr&&) = delete;
        GameEventMgr& operator=(GameEventMgr const&) = delete;
        GameEventMgr& operator=(GameEventMgr&&) = delete;

        static GameEventMgr* instance();

        typedef std::set<uint16> ActiveEvents;
        typedef std::vector<GameEventData> GameEventDataMap;
        ActiveEvents const& GetActiveEventList() const { return m_ActiveEvents; }
        GameEventDataMap const& GetEventMap() const { return mGameEvent; }
        bool CheckOneGameEvent(uint16 entry) const;
        uint32 NextCheck(uint16 entry) const;
        void LoadFromDB();
        uint32 Update();
        bool IsActiveEvent(uint16 event_id) const { return (m_ActiveEvents.contains(event_id)); }
        uint32 StartSystem();
        void Initialize();
        void StartArenaSeason();
        void StartInternalEvent(uint16 event_id);
        bool StartEvent(uint16 event_id, bool overwrite = false);
        void StopEvent(uint16 event_id, bool overwrite = false);
        void HandleQuestComplete(uint32 quest_id);  // called on world event type quest completions
        uint64 GetNPCFlag(Creature* cr);

    private:
        void SendWorldStateUpdate(Player* player, uint16 event_id);
        void AddActiveEvent(uint16 event_id);
        void RemoveActiveEvent(uint16 event_id);
        void ApplyNewEvent(uint16 event_id);
        void UnApplyEvent(uint16 event_id);
        void GameEventSpawn(int16 event_id);
        void GameEventUnspawn(int16 event_id);
        void ChangeEquipOrModel(int16 event_id, bool activate);
        void UpdateEventQuests(uint16 event_id, bool activate);
        void UpdateWorldStates(uint16 event_id, bool Activate);
        void UpdateEventNPCFlags(uint16 event_id);
        void UpdateEventNPCVendor(uint16 event_id, bool activate);
        void RunSmartAIScripts(uint16 event_id, bool activate);    //!< Runs SMART_EVENT_GAME_EVENT_START/_END SAI
        bool CheckOneGameEventConditions(uint16 event_id);
        void SaveWorldEventStateToDB(uint16 event_id);
        bool hasCreatureQuestActiveEventExcept(uint32 quest_id, uint16 event_id);
        bool hasGameObjectQuestActiveEventExcept(uint32 quest_id, uint16 event_id);
        bool hasCreatureActiveEventExcept(ObjectGuid::LowType creature_guid, uint16 event_id);
        bool hasGameObjectActiveEventExcept(ObjectGuid::LowType go_guid, uint16 event_id);
        void SetHolidayEventTime(GameEventData& event);
        time_t GetLastStartTime(uint16 event_id) const;

        typedef std::list<ObjectGuid::LowType> GuidList;
        typedef std::list<uint32> IdList;
        typedef std::vector<GuidList> GameEventGuidMap;
        typedef std::vector<IdList> GameEventIdMap;
        typedef std::pair<ObjectGuid::LowType, ModelEquip> ModelEquipPair;
        typedef std::list<ModelEquipPair> ModelEquipList;
        typedef std::vector<ModelEquipList> GameEventModelEquipMap;
        typedef std::pair<uint32, uint32> QuestRelation;
        typedef std::list<QuestRelation> QuestRelList;
        typedef std::vector<QuestRelList> GameEventQuestMap;
        typedef std::unordered_map<uint32, std::vector<VendorItem>> NPCVendorMap;
        typedef std::vector<NPCVendorMap> GameEventNPCVendorMap;
        typedef std::map<uint32 /*quest id*/, GameEventQuestToEventConditionNum> QuestIdToEventConditionMap;
        typedef std::pair<ObjectGuid::LowType /*guid*/, uint64 /*npcflag*/> GuidNPCFlagPair;
        typedef std::list<GuidNPCFlagPair> NPCFlagList;
        typedef std::vector<NPCFlagList> GameEventNPCFlagMap;
        GameEventQuestMap mGameEventCreatureQuests;
        GameEventQuestMap mGameEventGameObjectQuests;
        GameEventNPCVendorMap mGameEventVendors;
        GameEventModelEquipMap mGameEventModelEquip;
        //GameEventGuidMap  mGameEventCreatureGuids;
        //GameEventGuidMap  mGameEventGameobjectGuids;
        GameEventIdMap    mGameEventPoolIds;
        GameEventDataMap  mGameEvent;
        QuestIdToEventConditionMap mQuestToEventConditions;
        GameEventNPCFlagMap mGameEventNPCFlags;
        ActiveEvents m_ActiveEvents;
        bool isSystemInit;

    public:
        GameEventGuidMap  mGameEventCreatureGuids;
        GameEventGuidMap  mGameEventGameobjectGuids;
};

#define sGameEventMgr GameEventMgr::instance()

TC_GAME_API bool IsHolidayActive(HolidayIds id);
TC_GAME_API bool IsEventActive(uint16 eventId);

#endif
