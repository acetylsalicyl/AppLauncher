
include(${TEST_SOURCE_DIR}/AppLauncherTestMacros.cmake)
include(${TEST_BINARY_DIR}/AppLauncherTestPrerequisites.cmake)

# --------------------------------------------------------------------------
# Debug flags - Set to True to display the command as string
set(PRINT_COMMAND 0)

set(sys_env_var_name "CTKAPPLAUNCHER_TEST_ENV_EXPRESSION")
set(sys_env_var_value "Powder as in snow")
set(regular_env_var_name_1 "SOMETHING_NICE")
set(regular_env_var_value_1 "Chocolate")
set(regular_env_var_name_2 "SOMETHING_AWESOME")
set(regular_env_var_value_2 "Rock climbing !")
set(regular_env_var_name_3 "SOMETHING_GREAT")
set(regular_env_var_value_3 "<env:${sys_env_var_name}>")

set(ENV{${sys_env_var_name}} ${sys_env_var_value})

# --------------------------------------------------------------------------
# Configure settings file
file(WRITE "${launcher}LauncherSettings.ini" "
[General]

[Application]
path=${application}
arguments=--check-env

[LibraryPaths]
1\\path=${library_path}
size=1

[EnvironmentVariables]
${regular_env_var_name_1}=${regular_env_var_value_1}
${regular_env_var_name_2}=${regular_env_var_value_2}
${regular_env_var_name_3}=${regular_env_var_value_3}
")

# --------------------------------------------------------------------------
# Make sure the launcher passes the environment variable to the application
set(command ${launcher_exe} --launcher-no-splash)
execute_process(
  COMMAND ${command}
  WORKING_DIRECTORY ${launcher_binary_dir}
  ERROR_VARIABLE ev
  OUTPUT_VARIABLE ov
  RESULT_VARIABLE rv
  )

print_command_as_string("${command}")

if(rv)
  message(FATAL_ERROR "[${launcher_exe}] failed to start application [${application}] from "
                      "directory [${launcher_binary_dir}]\n${ev}")
endif()

set(expected_regular_env_var_name_1 "${regular_env_var_name_1}")
set(expected_regular_env_var_value_1 "${regular_env_var_value_1}")
set(expected_regular_env_var_name_2 "${regular_env_var_name_2}")
set(expected_regular_env_var_value_2 "${regular_env_var_value_2}")
set(expected_regular_env_var_name_3 "${regular_env_var_name_3}")
set(expected_regular_env_var_value_3 "${sys_env_var_value}")

set(expected_msg "${expected_regular_env_var_name_1}=${expected_regular_env_var_value_1}\n${expected_regular_env_var_name_2}=${expected_regular_env_var_value_2}\n${expected_regular_env_var_name_3}=${expected_regular_env_var_value_3}")
string(REGEX MATCH ${expected_msg} current_msg ${ov})
if(NOT "${expected_msg}" STREQUAL "${current_msg}")
  message(FATAL_ERROR "Failed to pass environment variable from ${launcher_name} "
                      "to ${application_name}.\n${ov}")
endif()

