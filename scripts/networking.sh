check_netstat_installed(){
    if ! netstat --version > /dev/null 2>&1; then
        echo "ERROR: netstat is not installed"
        echo "SOLUTION: install the dependency and try again!"
        return 1
    fi
}


check_curl_installed(){
    if ! curl --version > /dev/null 2>&1; then
        echo "ERROR: curl is not installed"
        echo "SOLUTION: install the dependency and try again!"
        return 1
    fi
}

check_http_availability(){
    url = $1
    if curl --output /dev/null --silent --head --fail $url; then
        echo "OK: Server is running on $url"
    else
        echo "ERROR: Server is not running on $url"
        echo "SOLUTION: Please check the logs and try again."
        return 1
    fi
}

check_local_mqtt_availability(){
    if netstat -lnt | awk '$6 == "LISTEN" && $4 ~ ".1883"' >/dev/null; then
        echo "OK: Mosquitto is running on port 1883"
    else
        echo "ERROR: Mosquitto is not running on port 1883"
        return 1
    fi
}

check_local_websockets_availability(){
    port=$1
    if netstat -an | grep "$port.*LISTEN" >/dev/null; then
        echo "OK: Websocket is running on port $port"
    else
        echo "ERROR: Websocket is not running on port $port"
        return 1
    fi
}
