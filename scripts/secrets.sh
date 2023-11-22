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

check_secrets(){
    echo "INFO: Checking for expected environment variables..."
    if [ -z "$MY_SECRET" ]; then
        echo "ERROR: The environment variable MY_SECRET is not set"
        return 1
    fi

    echo "OK: Expected environment variables are set."
}