#!/bin/bash

load_secrets () {
    file=${1:-.env}
    echo "INFO: Loading secrets from $file file..."
    if [ -f "$file" ]; then
        echo "INFO: $file file found"
        # shellcheck disable=SC1090
        source "$file"
        echo "OK: secrets loaded from $file file."
    else
        echo "ERROR: $file file does not exist."
        echo "SOLUTION: Please create a $file file with the minimum values expected and try again."
        return 1
    fi
}

check_environmental_variables() {
    for var in "$@"; do
        if [ -z "${!var}" ]; then
            echo "ERROR: $var is not set."
            echo "SOLUTION: Please set the $var environment variable."
            return 1
        else
            echo "OK: $var is set."
        fi
    done
}