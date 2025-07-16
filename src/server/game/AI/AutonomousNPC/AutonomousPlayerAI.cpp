#include "AutonomousPlayerAI.h"
#include "Chat.h"
#include "Player.h"
#include "CreatureAIRegistry.h"

AutonomousPlayerAI::AutonomousPlayerAI(Creature* creature)
    : CreatureAI(creature) {
}

void AutonomousPlayerAI::Reset()
{
    if (!initialized)
    {
        Initialize();
        initialized = true;
    }
}

void AutonomousPlayerAI::Initialize()
{
    me->SetLevel(1);
    me->Say("Ich bin ein autonomer KI-NPC.", LANG_UNIVERSAL);
}

void AutonomousPlayerAI::UpdateAI(uint32 diff)
{
    if (tickTimer <= diff)
    {
        me->Say("Ich analysiere meine Umgebung...", LANG_UNIVERSAL);
        tickTimer = 5000;
    }
    else
    {
        tickTimer -= diff;
    }
}

// Registrierung beim Core
CreatureAI* GetAutonomousPlayerAI(Creature* creature)
{
    return new AutonomousPlayerAI(creature);
}

void AddAutonomousPlayerAI()
{
    CreatureAIRegistry::RegisterAI("AutonomousPlayerAI", GetAutonomousPlayerAI);
}
