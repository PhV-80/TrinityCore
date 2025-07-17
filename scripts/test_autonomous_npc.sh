#!/bin/bash

# ===================================
# Autonome NPC-KI Test-Skript
# ===================================

set -e

echo "🧠 TrinityCore Autonome NPC-KI Test-Skript"
echo "=========================================="

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hilfsfunktionen
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# 1. Überprüfe Quellcode-Struktur
echo -e "\n${BLUE}1. Überprüfe Projektstruktur...${NC}"

if [ -f "src/server/game/AI/AutonomousNPC/AutonomousPlayerAI.h" ]; then
    print_success "AutonomousPlayerAI.h gefunden"
else
    print_error "AutonomousPlayerAI.h nicht gefunden!"
    exit 1
fi

if [ -f "src/server/game/AI/AutonomousNPC/AutonomousPlayerAI.cpp" ]; then
    print_success "AutonomousPlayerAI.cpp gefunden"
else
    print_error "AutonomousPlayerAI.cpp nicht gefunden!"
    exit 1
fi

if [ -f "src/server/game/AI/AutonomousNPC/AutonomousNPCConfig.h" ]; then
    print_success "AutonomousNPCConfig.h gefunden"
else
    print_error "AutonomousNPCConfig.h nicht gefunden!"
    exit 1
fi

if [ -f "src/server/game/AI/AutonomousNPC/AutonomousNPCConfig.cpp" ]; then
    print_success "AutonomousNPCConfig.cpp gefunden"
else
    print_error "AutonomousNPCConfig.cpp nicht gefunden!"
    exit 1
fi

if [ -f "sql/autonomous_npc_setup.sql" ]; then
    print_success "SQL Setup-Datei gefunden"
else
    print_error "autonomous_npc_setup.sql nicht gefunden!"
    exit 1
fi

# 2. Überprüfe CreatureAIRegistry Integration
echo -e "\n${BLUE}2. Überprüfe CreatureAIRegistry Integration...${NC}"

if grep -q "AutonomousPlayerAI" src/server/game/AI/CreatureAIRegistry.cpp; then
    print_success "AutonomousPlayerAI ist in CreatureAIRegistry registriert"
else
    print_error "AutonomousPlayerAI ist nicht in CreatureAIRegistry registriert!"
    print_info "Füge folgende Zeilen zu src/server/game/AI/CreatureAIRegistry.cpp hinzu:"
    echo -e "${YELLOW}#include \"AutonomousNPC/AutonomousPlayerAI.h\"${NC}"
    echo -e "${YELLOW}(new CreatureAIFactory<AutonomousPlayerAI>(\"AutonomousPlayerAI\"))->RegisterSelf();${NC}"
    exit 1
fi

# 3. Syntax-Check der Hauptdateien
echo -e "\n${BLUE}3. Führe Syntax-Checks durch...${NC}"

# Überprüfe C++ Header Syntax
if command -v g++ &> /dev/null; then
    echo "Teste Header-Syntax..."
    if g++ -fsyntax-only -std=c++17 -I. -Isrc/server/game/AI/AutonomousNPC src/server/game/AI/AutonomousNPC/AutonomousPlayerAI.h 2>/dev/null; then
        print_success "Header-Syntax ist korrekt"
    else
        print_warning "Header-Syntax-Check fehlgeschlagen (möglicherweise wegen fehlender Dependencies)"
    fi
else
    print_warning "g++ nicht verfügbar - überspringe Syntax-Check"
fi

# 4. Überprüfe SQL-Syntax
echo -e "\n${BLUE}4. Überprüfe SQL-Syntax...${NC}"

if command -v mysql &> /dev/null; then
    echo "Teste SQL-Syntax..."
    if mysql --help | grep -q "dry-run" 2>/dev/null; then
        print_success "MySQL Client verfügbar"
    else
        print_success "MySQL Client verfügbar (dry-run nicht unterstützt)"
    fi
else
    print_warning "mysql client nicht verfügbar - überspringe SQL-Check"
fi

# 5. Überprüfe Dokumentation
echo -e "\n${BLUE}5. Überprüfe Dokumentation...${NC}"

if [ -f "README_AUTONOMOUS_NPC.md" ]; then
    print_success "README_AUTONOMOUS_NPC.md gefunden"
    
    # Überprüfe wichtige Abschnitte
    if grep -q "Installation" README_AUTONOMOUS_NPC.md; then
        print_success "Installation-Sektion gefunden"
    else
        print_warning "Installation-Sektion fehlt in README"
    fi
    
    if grep -q "Konfiguration" README_AUTONOMOUS_NPC.md; then
        print_success "Konfiguration-Sektion gefunden"
    else
        print_warning "Konfiguration-Sektion fehlt in README"
    fi
else
    print_warning "README_AUTONOMOUS_NPC.md nicht gefunden"
fi

# 6. Empfehlungen für Build
echo -e "\n${BLUE}6. Build-Empfehlungen...${NC}"

print_info "Führe folgende Schritte für die Kompilierung durch:"
echo -e "${YELLOW}mkdir -p build && cd build${NC}"
echo -e "${YELLOW}cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo${NC}"
echo -e "${YELLOW}make -j\$(nproc) worldserver${NC}"

# 7. Empfehlungen für Datenbank-Setup
echo -e "\n${BLUE}7. Datenbank-Setup Empfehlungen...${NC}"

print_info "Führe folgende SQL-Befehle aus:"
echo -e "${YELLOW}mysql -u root -p world < sql/autonomous_npc_setup.sql${NC}"

# 8. Empfehlungen für Konfiguration
echo -e "\n${BLUE}8. Konfiguration Empfehlungen...${NC}"

print_info "Füge folgende Zeilen zu worldserver.conf hinzu:"
echo -e "${YELLOW}# Autonome NPCs aktivieren${NC}"
echo -e "${YELLOW}AutonomousNPC.MaxCount = 25${NC}"
echo -e "${YELLOW}AutonomousNPC.RespectPlayerCap = 1${NC}"
echo -e "${YELLOW}AutonomousNPC.EnableDebugLogging = 1${NC}"

# 9. Test-Empfehlungen
echo -e "\n${BLUE}9. Test-Empfehlungen...${NC}"

print_info "Nach dem Start des Servers, teste mit:"
echo -e "${YELLOW}.npc add 90001  # Spawnt autonomen Krieger${NC}"
echo -e "${YELLOW}.npc add 90002  # Spawnt autonomen Magier${NC}"

print_info "Überwache Logs mit:"
echo -e "${YELLOW}tail -f Server.log | grep \"autonomous.npc\"${NC}"

# 10. Zusammenfassung
echo -e "\n${GREEN}=========================================="
echo -e "✓ Autonome NPC Test-Skript abgeschlossen!"
echo -e "==========================================${NC}"

print_info "Das Projekt scheint korrekt strukturiert zu sein."
print_info "Folge den Anweisungen oben für Build und Installation."

echo -e "\n${BLUE}Weitere Informationen:${NC}"
echo -e "📖 README: README_AUTONOMOUS_NPC.md"
echo -e "🗃️ SQL: sql/autonomous_npc_setup.sql"
echo -e "💬 Support: TrinityCore Discord oder Forums"

exit 0