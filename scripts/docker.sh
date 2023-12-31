#!/bin/bash

check_docker_running(){
    if ! docker info > /dev/null 2>&1; then
        echo "ERROR: docker engine isn't running"
        echo "SOLUTION: please start docker and try again!"
        exit 1
    fi
}

check_docker_compose_installed(){
    if docker-compose -v; then
        echo "OK: Docker-compose is installed..."
    else
        echo "ERROR: Docker-compose is not installed"
        echo "SOLUTION: Please install docker-compose and try again"
        exit 1
    fi
}

check_docker_installed(){
    if docker -v; then
        echo "OK: Docker is installed..."
    else
        echo "ERROR: Docker is not running"
        echo "ERROR: Please start docker and try again"
        exit 1
    fi
}

build_docker_simple_image(){
    image_name=$1
    dockerfile=$2
    target_directory=$3
    additional_args=$4

    echo "INFO: Building docker image..."

    if [ -z "$image_name" ]; then
        echo "ERROR: Image name not defined"
        exit 1
    fi

    if [ -z "$dockerfile" ]; then
        dockerfile="Dockerfile"
        echo "INFO: Dockerfile not defined, using $dockerfile as default"
    fi

    (
        if [ -n "$target_directory" ]; then
            cd "$target_directory" || exit 1
        fi

        if [ -n "$additional_args" ]; then
            # shellcheck disable=SC2086
            # Spread additional args is a expected behavior
            docker build -t "$image_name":latest -f "$dockerfile" $additional_args .
        else
            docker build -t "$image_name":latest -f "$dockerfile" .
        fi
    )
    echo "OK: Docker image $image_name:latest built."
}

upsert_docker_compose_file() {
    echo "
version: 3
services:
  hello_world:
    image: hello-world
" > docker-compose.yml
}

docker_compose_info() {
echo "Docker compose cheact sheet"
echo "Start:"
echo "docker-compose up"
echo "Start detached:"
echo "docker-compose up -d"
echo "Stop:"
echo "docker-compose down"
echo "Access logs:"
echo "docker-compose logs -f"
echo "Hard restart:"
echo "docker-compose down && docker-compose up -d --build --force-recreate --remove-orphans --renew-anon-volumes"
}

docker_compose_up_detached() {
    echo "INFO: Starting docker-compose in detached mode..."
    docker-compose up -d
    echo "OK: Docker-compose started."
}

check_docker_container_running_by_image_used () {
    image=$1
    if docker ps --format '{{.Image}}' | grep -q "$image"; then
        echo "OK: Docker container running image $image is running"
    else
        echo "ERROR: Docker container running image $image is not running"
        exit 1
    fi
}
