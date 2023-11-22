#!/usr/bin/env bats

# Ignore SC2317 because we use mock functions
# shellcheck disable=SC2317
# shellcheck disable=SC2034

load "$(pwd)/scripts/git.sh"

setup() {
    # Mock git command
    git() {
        if [[ $1 == "--version" || $1 == "clone"  || $1 == "fetch" || $1 == "pull" || $1 == "show-ref" || $1 == "checkout" ]]; then
            return 0
        fi
        
        return 1
    }
    export -f git
    mkdir -p test/.git
    mkdir -p test2
}

teardown() {
    unset -f git
    unset GIT_USER 
    unset GIT_PASS
    rm -rf test
    rm -rf test2
}

@test "check_git_installed returns success if git is installed" {
    run check_git_installed
    [ "$status" -eq 0 ]
}

@test "check_git_installed returns error if git is not installed" {
    # Unset mock git command to simulate git not being installed
    unset -f git

    run check_git_installed
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: git is not installed" ]]
    [[ "${lines[1]}" == "SOLUTION: please install git and try again!" ]]
}


@test "git_clone_public_project returns error if no repository URL is provided" {
    run git_clone_public_project
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: No repository URL provided" ]]
}

@test "git_clone_public_project clones repository if repository URL is provided" {
    run git_clone_public_project "https://github.com/user/repo.git"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Cloning https://github.com/user/repo.git" ]]
    [[ "${lines[1]}" == "OK: https://github.com/user/repo.git cloned." ]]
}