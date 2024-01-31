#!/bin/bash

load_secrets () {
    file=${1:-.env}
    mode=${2:-hard}
    echo "INFO: Loading secrets from $file file in mode: $mode."
    if [ -f "$file" ]; then
        echo "INFO: $file file found"
        # Load the file directly (hard mode)
        if [ "$mode" == "hard" ]; then
            # shellcheck disable=SC1090
            source "$file"
        # Load only the variables that are not already set (soft mode)
        elif [ "$mode" == "soft" ]; then
            # shellcheck disable=SC1090
            while IFS='=' read -r var_name var_value; do
                if [ -z "${!var_name}" ]; then
                    export "$var_name"="$var_value"
                fi
            done < "$file"
        else
            echo "ERROR: Invalid mode $mode"
            echo "SOLUTION: Please use either hard or soft mode"
            exit 1
        fi
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
