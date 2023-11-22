#!/bin/bash

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
    url="$1"

    if [ -z "$url" ]; then
        return 1
    fi

    if curl --output /dev/null --silent --head --fail "$url"; then
        echo "OK: Server is running on $url"
    else
        echo "ERROR: Server is not running on $url"
        echo "SOLUTION: Please check the logs and try again."
        return 1
    fi
}

check_local_mqtt_availability(){
    if netstat -lnt | grep ':1883 .*LISTEN' >/dev/null; then
        echo "OK: MQTT is running on port 1883"
    else
        echo "ERROR: MQTT is not running on port 1883"
        return 1
    fi
}

check_local_websockets_availability() {
    port=$1
    if [ -z "$port" ]; then
        return 1
    fi
    response=$(curl --include --no-buffer --header "Connection: Upgrade" --header "Upgrade: websocket" --header "Host: localhost:$port" --header "Origin: http://localhost:$port" --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" --header "Sec-WebSocket-Version: 13" "http://localhost:$port" 2>/dev/null)
    if echo "$response" | grep "HTTP/1.1 101 Switching Protocols" >/dev/null; then
        echo "OK: WebSocket is running on port $port"
    else
        echo "ERROR: WebSocket is not running on port $port"
        return 1
    fi
}
