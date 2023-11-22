#!/usr/bin/env bats

load "$(pwd)/scripts/fs.sh"

@test "check_directory with existing directory" {
    run check_directory "/tmp"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "OK: Directory /tmp exists." ]
}

@test "check_directory with non-existing directory" {
    run check_directory "/non/existent/directory"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ERROR: Directory /non/existent/directory does not exist." ]
    [ "${lines[1]}" = "ERROR: Please create the directory /non/existent/directory try again." ]
}