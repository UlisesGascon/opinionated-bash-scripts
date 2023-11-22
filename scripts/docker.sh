#!/bin/bash

check_docker_running(){
    if ! docker info > /dev/null 2>&1; then
        echo "ERROR: docker engine isn't running"
        echo "SOLUTION: please start docker and try again!"
        return 1
    fi
}

check_docker_compose_installed(){
    if docker-compose -v; then
        echo "OK: Docker-compose is installed..."
    else
        echo "ERROR: Docker-compose is not installed"
        echo "SOLUTION: Please install docker-compose and try again"
        return 1
    fi
}

check_docker_installed(){
    if docker -v; then
        echo "OK: Docker is installed..."
    else
        echo "ERROR: Docker is not running"
        echo "ERROR: Please start docker and try again"
        return 1
    fi
}

build_docker_simple_image(){
    folder=$1
    image_name=$2
    dockerfile=$3

    echo "INFO: Building docker image..."

    if [ -z "$dockerfile" ] then
        dockerfile="Dockerfile"
        echo "INFO: Dockerfile not defined, using $dockerfile as default"
    fi
    cd $folder
    docker build -t $image_name:latests -f $dockerfile .
    echo "OK: Docker image built."
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
        return 1
    fi
}
