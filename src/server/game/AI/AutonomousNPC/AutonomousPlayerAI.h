#pragma once

#include "CreatureAI.h"
#include "Creature.h"
#include "ScriptMgr.h"

class AutonomousPlayerAI : public CreatureAI
{
public:
    explicit AutonomousPlayerAI(Creature* creature);
    ~AutonomousPlayerAI() override = default;

    void Reset() override;
    void UpdateAI(uint32 diff) override;

private:
    uint32 tickTimer = 5000;
    bool initialized = false;

    void Initialize();
};
