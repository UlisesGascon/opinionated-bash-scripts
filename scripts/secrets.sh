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
        exit 1
    fi
}

check_environmental_variables() {
    for var in "$@"; do
        if [ -z "${!var}" ]; then
            echo "ERROR: $var is not set."
            echo "SOLUTION: Please set the $var environment variable."
            exit 1
        else
            echo "OK: $var is set."
        fi
    done
}

check_environmental_variable_value() {
  local var_name="$1"
  shift
  local valid_values=("$@")
  local value="${!var_name}"

  if [ -z "$value" ]; then
    echo "Error: Invalid ${var_name} is not set" >&2
    exit 1
  fi

  for valid_value in "${valid_values[@]}"; do
    if [ "$value" == "$valid_value" ]; then
      echo "OK: Validated ${var_name} with the allowed values"
      return 0
    fi
  done

  echo "Error: Invalid ${var_name} has an invalid value" >&2
  exit 1
}
