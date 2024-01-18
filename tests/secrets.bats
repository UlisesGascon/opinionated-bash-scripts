#!/usr/bin/env bats

load "$(pwd)/scripts/secrets.sh"

setup() {
    # Create a temporary .env file for testing
    echo "MY_SECRET=test" > .env
    echo "MY_OTHER_SECRET=test" >> secrets
    export TEST_SECRET_ONE=one
    export TEST_SECRET_TWO=two
}

teardown() {
    # Remove the temporary .env file after testing
    rm .env
    rm secrets
    unset TEST_SECRET_ONE
    unset TEST_SECRET_TWO
}

@test "load_secrets loads secrets from .env file correctly" {
    run load_secrets
    [ "$status" -eq 0 ]
    [[ "${lines[2]}" == "OK: secrets loaded from .env file." ]]
}

@test "load_secrets loads secrets from custom file correctly" {
    run load_secrets secrets
    [ "$status" -eq 0 ]
    [[ "${lines[2]}" == "OK: secrets loaded from secrets file." ]]
}

@test "load_secrets returns error if the custom file does not exist" {
    run load_secrets notfound
    [ "$status" -eq 1 ]
    [[ "${lines[1]}" == "ERROR: notfound file does not exist." ]]
    [[ "${lines[2]}" == "SOLUTION: Please create a notfound file with the minimum values expected and try again." ]]
}

@test "load_secrets returns error if default file does not exist" {
    rm .env
    run load_secrets notfound
    [ "$status" -eq 1 ]
    [[ "${lines[1]}" == "ERROR: notfound file does not exist." ]]
    [[ "${lines[2]}" == "SOLUTION: Please create a notfound file with the minimum values expected and try again." ]]
}

@test "check_environmental_variables returns success if all environment variables are set" {
    run check_environmental_variables TEST_SECRET_ONE TEST_SECRET_TWO
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: TEST_SECRET_ONE is set." ]]
    [[ "${lines[1]}" == "OK: TEST_SECRET_TWO is set." ]]
}

@test "check_environmental_variables returns error if an environment variable is not set" {
    unset MY_SECRET
    run check_environmental_variables TEST_SECRET_ONE INVENTED TEST_SECRET_TWO
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "OK: TEST_SECRET_ONE is set." ]]
    [[ "${lines[1]}" == "ERROR: INVENTED is not set." ]]
    [[ "${lines[2]}" == "SOLUTION: Please set the INVENTED environment variable." ]]
}


@test "check_environmental_variable_value returns success if environment variable value is in the allowed values (case: single value)" {
    run check_environmental_variable_value "TEST_SECRET_ONE" "one"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Validated TEST_SECRET_ONE with the allowed values" ]]
}

@test "check_environmental_variable_value returns success if environment variable value is in the allowed values (case: multiple values)" {
    run check_environmental_variable_value "TEST_SECRET_ONE" "random" "one"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Validated TEST_SECRET_ONE with the allowed values" ]]
}

@test "check_environmental_variable_value returns error if environment variable is not set" {
    run check_environmental_variable_value INVENTED_VARIABLE "exists"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "Error: Invalid INVENTED_VARIABLE is not set" ]]
}

@test "check_environmental_variable_value returns error if environment variable value is not in the allowed values" {
    run check_environmental_variable_value TEST_SECRET_ONE "two", "other"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "Error: Invalid TEST_SECRET_ONE has an invalid value" ]]
}