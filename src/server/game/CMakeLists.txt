# This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
#
# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, to the extent permitted by law; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

CollectSourceFiles(
  ${CMAKE_CURRENT_SOURCE_DIR}
  PRIVATE_SOURCES
  # Exclude
  ${CMAKE_CURRENT_SOURCE_DIR}/PrecompiledHeaders
  ${CMAKE_CURRENT_SOURCE_DIR}/AI/AutonomousNPC/AutonomousPlayerAI.cpp
)


if(USE_COREPCH)
  set(PRIVATE_PCH_HEADER PrecompiledHeaders/gamePCH.h)
endif()

GroupSources(${CMAKE_CURRENT_SOURCE_DIR})

CollectIncludeDirectories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  PUBLIC_INCLUDES
  # Exclude
  ${CMAKE_CURRENT_SOURCE_DIR}/PrecompiledHeaders)

# Provide an interface target for the game project to allow
# dependent projects to build meanwhile.
add_library(game-interface INTERFACE)

target_include_directories(game-interface
  INTERFACE
    ${PUBLIC_INCLUDES})

target_link_libraries(game-interface
  INTERFACE
    shared
    Detour)

add_library(game
  ${PRIVATE_SOURCES})

target_include_directories(game
  PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(game
  PRIVATE
    trinity-core-interface
    efsw
  PUBLIC
    game-interface)

set_target_properties(game
  PROPERTIES
    COMPILE_WARNING_AS_ERROR ${WITH_WARNINGS_AS_ERRORS}
    DEFINE_SYMBOL TRINITY_API_EXPORT_GAME
    FOLDER "server")

if(BUILD_SHARED_LIBS)
  if(UNIX)
    install(TARGETS game
      LIBRARY
        DESTINATION lib)
  elseif(WIN32)
    install(TARGETS game
      RUNTIME
        DESTINATION "${CMAKE_INSTALL_PREFIX}")
  endif()
endif()

# Generate precompiled header
if(USE_COREPCH)
  add_cxx_pch(game ${PRIVATE_PCH_HEADER})
endif()
