cmake_minimum_required(VERSION 3.5)
project(FantaSeq64 NONE)

set(ACME_EXECUTABLE "acme" CACHE FILEPATH "Path to the ACME assembler binary")

find_program(_ACME_FOUND ${ACME_EXECUTABLE})
if(NOT _ACME_FOUND)
    message(WARNING
        "ACME assembler not found at '${ACME_EXECUTABLE}'.\n"
        "Install it or pass -DACME_EXECUTABLE=/full/path/to/acme to cmake.")
endif()

set(HATOUCAN_SCRIPT "" CACHE FILEPATH "Path to the hatoucan script (hatoucan/script/hatoucan)")

find_program(PYTHON3_EXECUTABLE python3)
if(NOT PYTHON3_EXECUTABLE)
    message(WARNING "python3 not found in PATH.")
endif()
if(NOT HATOUCAN_SCRIPT)
    message(WARNING
        "HATOUCAN_SCRIPT not set.\n"
        "Pass -DHATOUCAN_SCRIPT=/path/to/hatoucan/script/hatoucan to cmake.")
endif()

include(cmake/AcmeAssembler.cmake)
include(cmake/HatoucanBasic.cmake)

add_acme_target(
    fantaseq64
    ${CMAKE_SOURCE_DIR}/src/all.asm
    ${CMAKE_BINARY_DIR}/fantaseq64.prg
    VERBOSITY 2          # ← change to 1, 2, or 3
    DEPENDS
        ${CMAKE_SOURCE_DIR}/src/constants.h
        ${CMAKE_SOURCE_DIR}/src/variables.asm
        ${CMAKE_SOURCE_DIR}/src/irq.asm
        ${CMAKE_SOURCE_DIR}/src/main.asm
)

add_hatoucan_target(
    loader
    ${CMAKE_SOURCE_DIR}/src/loader.bas
    ${CMAKE_BINARY_DIR}/loader.prg
)

add_dependencies(loader fantaseq64)
