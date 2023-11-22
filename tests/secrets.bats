#!/usr/bin/env bats

load "$(pwd)/scripts/secrets.sh"

setup() {
    # Create a temporary .env file for testing
    echo "MY_SECRET=test" > .env
    echo "MY_OTHER_SECRET=test" >> secrets
}

teardown() {
    # Remove the temporary .env file after testing
    rm .env
    rm secrets
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




