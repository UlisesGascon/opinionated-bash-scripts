#!/usr/bin/env bats

# Ignore SC2317 because we use mock functions
# shellcheck disable=SC2317

load "$(pwd)/scripts/networking.sh"

setup() {
    # Mock curl command
    curl() {
        echo "curl: command not found"
        return 1
    }
    export -f curl

    # Mock netstat command
    netstat() {
        if [[ $1 == "--version" ]]; then
            echo "net-tools 2.10-alpha"
            return 0
        fi

        if [[ $1 == "-an" ]]; then
            echo "tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN"
        fi

        if [[ $1 == "-lnt" ]]; then
            echo "tcp        0      0 0.0.0.0:1883            0.0.0.0:*               LISTEN"
        fi
    }
    export -f netstat

}

teardown() {
    # Unmock stuff
    unset -f curl
    unset -f netstat
}

@test "check_curl_installed returns success if curl is installed" {
    curl() {
        echo "curl 7.64.1"
        return 0
    }
    export -f curl
    run check_curl_installed
    [ "$status" -eq 0 ]
}

@test "check_curl_installed returns failure if curl is not installed" {
    run check_curl_installed
    [ "$status" -eq 1 ]
}

@test "check_netstat_installed returns success if netstat is installed" {
    run check_netstat_installed
    [ "$status" -eq 0 ]
}

@test "check_netstat_installed returns error if netstat is not installed" {
    # Mock netstat command to simulate it not being installed
    netstat() {
        if [[ $1 == "--version" ]]; then
            return 1
        fi
    }
    run check_netstat_installed
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: netstat is not installed" ]]
    [[ "${lines[1]}" == "SOLUTION: install the dependency and try again!" ]]
}

@test "check_http_availability returns error if no URL is provided" {
    run check_http_availability ""
    [ "$status" -eq 1 ]
}

@test "check_http_availability returns success if server is running at URL" {
    # Mock curl command to simulate successful HTTP request
    curl() {
        if [[ $1 == "--output" && $3 == "--silent" && $4 == "--head" && $5 == "--fail" && $6 == "http://localhost:8080" ]]; then
            return 0
        else
            return 1
        fi
    }
    export -f curl

    run check_http_availability "http://localhost:8080"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Server is running on http://localhost:8080" ]]
}

@test "check_http_availability returns error if server is not running at URL" {
    # Mock curl command to simulate unsuccessful HTTP request
    curl() {
        if [[ $1 == "--output" && $3 == "--silent" && $4 == "--head" && $5 == "--fail" && $6 == "http://localhost:8081" ]]; then
            return 1
        else
            return 0
        fi
    }
    export -f curl

    run check_http_availability "http://localhost:8081"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: Server is not running on http://localhost:8081" ]]
    [[ "${lines[1]}" == "SOLUTION: Please check the logs and try again." ]]
}