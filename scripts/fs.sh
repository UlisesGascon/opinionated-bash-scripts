#!/bin/bash

check_directory() {
    if [ -d "$1" ]; then
        echo "OK: Directory $1 exists."
    else
        echo "ERROR: Directory $1 does not exist."
        echo "ERROR: Please create the directory $1 try again."
        exit 1
    fi
}