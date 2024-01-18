#!/usr/bin/env bats

load "$(pwd)/scripts/version.sh"

@test "get_version outputs the correct version and source code URL" {
    run get_version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "Current version: 0.6.1" ]]
    [[ "${lines[1]}" == "Source code: https://github.com/UlisesGascon/opinionated-bash-scripts/releases/tag/0.6.1" ]]
}