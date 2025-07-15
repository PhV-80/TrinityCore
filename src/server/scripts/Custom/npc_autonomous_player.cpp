#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "Player.h"
#include "Chat.h"
#include <random>

namespace {
    enum DynamicClass {
        CLASS_WARRIOR = 1,
        CLASS_MAGE = 8,
        CLASS_WARLOCK = 9,
        CLASS_PRIEST = 5
    };

    enum DynamicRace {
        RACE_HUMAN = 1,
        RACE_ORC = 2,
        RACE_NIGHTELF = 4,
        RACE_UNDEAD = 5
    };

    uint8 GetRandomRace() {
        uint8 races[] = { RACE_HUMAN, RACE_ORC, RACE_NIGHTELF, RACE_UNDEAD };
        return races[rand() % 4];
    }

    uint8 GetRandomClass() {
        uint8 classes[] = { CLASS_WARRIOR, CLASS_MAGE, CLASS_WARLOCK, CLASS_PRIEST };
        return classes[rand() % 4];
    }

    Gender GetRandomGender() {
        return Gender(rand() % 2);
    }
}

class npc_autonomous_player : public CreatureScript {
public:
    npc_autonomous_player() : CreatureScript("npc_autonomous_player") {}

    struct npc_autonomous_playerAI : public ScriptedAI {
        npc_autonomous_playerAI(Creature* creature) : ScriptedAI(creature) {}

        uint32 tickTimer = 10000;
        bool initialized = false;

        void Reset() override {
            if (!initialized) {
                initialized = true;
                InitializeNPC();
            }
        }

        void InitializeNPC() {
            // Zufällige Eigenschaften generieren
            uint8 race = GetRandomRace();
            uint8 cls = GetRandomClass();
            Gender gender = GetRandomGender();

            // Debug-Ausgabe
            char msg[128];
            snprintf(msg, 128, "Ich wurde geboren als Rasse %u, Klasse %u, Geschlecht %u!", race, cls, gender);
            me->Say(msg, LANG_UNIVERSAL, nullptr);

            // Setze Level, evtl. Teleport in Startgebiet
            me->SetLevel(1);
            // me->NearTeleportTo(...); // Startgebiet

            // Später: Zauber, Berufe, Stats etc. setzen
        }

        void UpdateAI(uint32 diff) override {
            if (tickTimer <= diff) {
                me->Say("Ich lebe!", LANG_UNIVERSAL, nullptr);
                tickTimer = 10000;
            }
            else {
                tickTimer -= diff;
            }

            // Später: Kampfverhalten, Analyse, Speicherzugriff
        }
    };

    CreatureAI* GetAI(Creature* creature) const override {
        return new npc_autonomous_playerAI(creature);
    }
};

// Registrieren
void AddSC_npc_autonomous_player() {
    new npc_autonomous_player();
}
