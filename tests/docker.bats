#!/usr/bin/env bats

# Ignore SC2317 because we use mock functions
# shellcheck disable=SC2317

load "$(pwd)/scripts/docker.sh"

setup() {
    # Mock docker command
    docker() {
        if [[ $1 == "up" || $1 == "build" || $1 == "-v" || $1 == "info" || $1 == "ps" ]]; then
            return 0
        fi

        return 1
    }
    export -f docker
    # Mock docker-compose command
    docker-compose() {
        if [[ $1 == "-v" ]]; then
            return 0
        else
            return 1
        fi
    }
    export -f docker-compose
}

teardown() {
    unset -f docker
    unset -f docker-compose
}

@test "check_docker_running returns success if Docker is running" {
    run check_docker_running
    [ "$status" -eq 0 ]
}

@test "check_docker_running returns error if Docker is not running" {
    # Redefine docker command to simulate Docker not running
    docker() {
        if [[ $1 == "info" ]]; then
            return 1
        else
            return 0
        fi
    }
    export -f docker

    run check_docker_running
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: docker engine isn't running" ]]
    [[ "${lines[1]}" == "SOLUTION: please start docker and try again!" ]]
}

@test "check_docker_compose_installed returns success if Docker Compose is installed" {
    run check_docker_compose_installed
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Docker-compose is installed..." ]]
}

@test "check_docker_compose_installed returns error if Docker Compose is not installed" {
    # Redefine docker-compose command to simulate Docker Compose not installed
    docker-compose() {
        if [[ $1 == "-v" ]]; then
            return 1
        else
            return 0
        fi
    }
    export -f docker-compose

    run check_docker_compose_installed
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: Docker-compose is not installed" ]]
    [[ "${lines[1]}" == "SOLUTION: Please install docker-compose and try again" ]]
}

@test "check_docker_installed returns success if Docker is installed" {
    run check_docker_installed
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Docker is installed..." ]]
}

@test "check_docker_installed returns error if Docker is not installed" {
    # Redefine docker command to simulate Docker not installed
    docker() {
        if [[ $1 == "-v" ]]; then
            return 1
        else
            return 0
        fi
    }
    export -f docker

    run check_docker_installed
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: Docker is not running" ]]
    [[ "${lines[1]}" == "ERROR: Please start docker and try again" ]]
}

@test "build_docker_simple_image builds image with provided Dockerfile" {
    run build_docker_simple_image "test_image" "TestDockerfile"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Building docker image..." ]]
    [[ "${lines[1]}" == "OK: Docker image built." ]]
}

@test "build_docker_simple_image builds image with default Dockerfile if none provided" {
    run build_docker_simple_image "test_image"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Building docker image..." ]]
    [[ "${lines[1]}" == "INFO: Dockerfile not defined, using Dockerfile as default" ]]
    [[ "${lines[2]}" == "OK: Docker image built." ]]
}

@test "build_docker_simple_image returns error if cd to provided folder fails" {
    # Mock cd command to simulate failure
    cd() {
        return 1
    }
    export -f cd

    run build_docker_simple_image "test_image" "TestDockerfile" "nonexistent_folder"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "INFO: Building docker image..." ]]

    # Unset mock cd command
    unset -f cd
}

@test "upsert_docker_compose_file creates docker-compose.yml file" {
    run upsert_docker_compose_file
    [ "$status" -eq 0 ]
    # Check if docker-compose.yml file exists
    [ -f docker-compose.yml ]
}

@test "docker_compose_info prints correct information" {
    run docker_compose_info
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "Docker compose cheact sheet" ]]
    [[ "${lines[1]}" == "Start:" ]]
    [[ "${lines[2]}" == "docker-compose up" ]]
    [[ "${lines[3]}" == "Start detached:" ]]
    [[ "${lines[4]}" == "docker-compose up -d" ]]
    [[ "${lines[5]}" == "Stop:" ]]
    [[ "${lines[6]}" == "docker-compose down" ]]
    [[ "${lines[7]}" == "Access logs:" ]]
    [[ "${lines[8]}" == "docker-compose logs -f" ]]
    [[ "${lines[9]}" == "Hard restart:" ]]
    [[ "${lines[10]}" == "docker-compose down && docker-compose up -d --build --force-recreate --remove-orphans --renew-anon-volumes" ]]
}

@test "docker_compose_up_detached starts docker-compose in detached mode" {
    run docker_compose_up_detached
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "INFO: Starting docker-compose in detached mode..." ]]
    [[ "${lines[1]}" == "OK: Docker-compose started." ]]
}

@test "check_docker_container_running_by_image_used returns success if Docker container is running" {
    docker() {
        if [[ $1 == "ps" ]]; then
            echo "test_image"
        fi
    }
    export -f docker
    
    run check_docker_container_running_by_image_used "test_image"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" == "OK: Docker container running image test_image is running" ]]
}

@test "check_docker_container_running_by_image_used returns error if Docker container is not running" {
    run check_docker_container_running_by_image_used "nonexistent_image"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" == "ERROR: Docker container running image nonexistent_image is not running" ]]
}