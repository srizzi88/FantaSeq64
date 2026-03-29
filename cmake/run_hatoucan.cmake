# Called at build time by add_hatoucan_target.
# Variables passed in via -D on the command line.
execute_process(
    COMMAND         ${PYTHON3_EXECUTABLE} ${HATOUCAN_SCRIPT}
    INPUT_FILE      ${INPUT_FILE}
    OUTPUT_FILE     ${OUTPUT_FILE}
    RESULT_VARIABLE result
)
if(NOT result EQUAL 0)
    message(FATAL_ERROR "hatoucan failed with exit code ${result}")
endif()
