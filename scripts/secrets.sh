load_secrets () {
    echo "INFO: Loading secrets from .env file..."
    if [ -f .env ]; then
        echo "INFO: .env file found"
        source .env
        echo "OK: secrets loaded from .env file."
    else
        echo "ERROR: .env file does not exist."
        echo "SOLUTION: Please create a .env file with the minimum values expected and try again."
        exit 1
    fi
}

check_secrets(){
    echo "INFO: Checking for expected environment variables..."
    if [ -z "$MY_SECRET" ]; then
        echo "ERROR: The environment variable MY_SECRET is not set"
        exit 1
    fi

    echo "OK: Expected environment variables are set."
}