function(add_hatoucan_target TARGET_NAME SOURCE OUTPUT)
    add_custom_command(
        OUTPUT  ${OUTPUT}
        COMMAND ${CMAKE_COMMAND}
                -DPYTHON3_EXECUTABLE=${PYTHON3_EXECUTABLE}
                -DHATOUCAN_SCRIPT=${HATOUCAN_SCRIPT}
                -DINPUT_FILE=${SOURCE}
                -DOUTPUT_FILE=${OUTPUT}
                -P ${CMAKE_SOURCE_DIR}/cmake/run_hatoucan.cmake
        DEPENDS ${SOURCE}
        COMMENT "hatoucan: tokenizing ${SOURCE} -> ${OUTPUT}"
    )
    add_custom_target(${TARGET_NAME} ALL DEPENDS ${OUTPUT})
endfunction()
