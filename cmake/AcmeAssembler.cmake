function(add_acme_target TARGET_NAME SOURCE OUTPUT)
    cmake_parse_arguments(ACME_ARG "" "VERBOSITY" "DEPENDS" ${ARGN})

    # Default to -v2 if not specified
    if(NOT ACME_ARG_VERBOSITY)
        set(ACME_ARG_VERBOSITY 2)
    endif()

    set(ALL_DEPS ${SOURCE})
    if(ACME_ARG_DEPENDS)
        list(APPEND ALL_DEPS ${ACME_ARG_DEPENDS})
    endif()

    set(REPORT_FILE ${CMAKE_BINARY_DIR}/${TARGET_NAME}.report)
    set(LABELS_FILE ${CMAKE_BINARY_DIR}/${TARGET_NAME}.labels)

    add_custom_command(
        OUTPUT  ${OUTPUT}
        BYPRODUCTS  ${REPORT_FILE} ${LABELS_FILE}
        COMMAND ${ACME_EXECUTABLE}
                --cpu 6510
                -f cbm
                -v${ACME_ARG_VERBOSITY}
                -o ${OUTPUT}
                -r ${CMAKE_BINARY_DIR}/${TARGET_NAME}.report
                --vicelabels ${CMAKE_BINARY_DIR}/${TARGET_NAME}.labels
                ${SOURCE}
        DEPENDS ${ALL_DEPS}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/src
        COMMENT "ACME: assembling ${SOURCE} -> ${OUTPUT}"
        VERBATIM
    )

    add_custom_target(${TARGET_NAME} ALL DEPENDS ${OUTPUT})
endfunction()
