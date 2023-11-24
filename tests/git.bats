#!/usr/bin/env bats

# Ignore SC2317 because we use mock functions
# shellcheck disable=SC2317
# shellcheck disable=SC2034

load "$(pwd)/scripts/git.sh"

setup() {
    # Mock git command
    git() {
        if [[ $1 == "--version" || $1 == "clone"  || $1 == "fetch" || $1 == "pull" || $1 == "checkout" ]]; then
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

@test "git_clone_private_project returns error if no repository URL is provided" {
    run git_clone_private_project
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: No repository URL provided" ]]
}

@test "git_clone_private_project returns error if GIT_USER or GIT_PASS is not set" {
    run git_clone_private_project "https://github.com/user/repo.git"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: GIT_USER or GIT_PASS is not set" ]]
}

@test "git_clone_private_project clones repository if repository URL, GIT_USER, and GIT_PASS are provided" {
    GIT_USER="testuser"
    GIT_PASS="testpass"
    run git_clone_private_project "https://github.com/user/repo.git"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Cloning https://github.com/user/repo.git" ]]
    [[ "${lines[1]}" == "OK: https://github.com/user/repo.git cloned." ]]
}

@test "git_checkout_branch returns error if no branch is provided" {
    run git_checkout_branch
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: Please provide a branch name" ]]
}

@test "git_checkout_branch returns error if branch does not exist" {
    # Mock git command
    git() {
        if [[ $1 == "ls-remote" && $2 == "--heads" && $3 == "origin" && $4 == refs/heads/nonexistentbranch ]]; then
            return 0
        fi
    }
    export -f git

    mkdir -p test/.git
    run git_checkout_branch "nonexistentbranch" "test"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "INFO: Checking out to branch nonexistentbranch in test..." ]]
    [[ "${lines[1]}" == "ERROR: Branch nonexistentbranch does not exist in test" ]]
    [[ "${lines[2]}" == "SOLUTION: Check the branch name and try again" ]]
    rm -rf test

    unset -f git
}

@test "git_checkout_branch checks out to branch if branch and folder are provided" {
    # Mock git command
    git() {
        if [[ $1 == "ls-remote" && $2 == "--heads" && $3 == "origin" && $4 == refs/heads/* ]]; then
            echo "testbranch"
        else
            return 0
        fi
    }
    export -f git

    run git_checkout_branch "testbranch" "test"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Checking out to branch testbranch in test..." ]]
    [[ "${lines[1]}" == "OK: Branch testbranch checked out in test" ]]

    unset -f git
}

@test "git_checkout_branch returns error if folder is not a git repository" {
    run git_checkout_branch "testbranch" "test2"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "INFO: Checking out to branch testbranch in test2..." ]]
    [[ "${lines[1]}" == "ERROR: test2 is not a git repository" ]]
    [[ "${lines[2]}" == "SOLUTION: Please check that the folder includes git historial and try again" ]]
}