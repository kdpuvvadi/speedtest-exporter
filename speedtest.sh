#!/bin/bash

# Define the output file
METRICS_FILE="/usr/share/nginx/html/metrics"

# Set the default interval (15 minutes) if not provided
SPEEDTEST_INTERVAL=${SPEEDTEST_INTERVAL:-900}

# Function to run the speed test and update metrics
run_speedtest() {
    echo "Running Speedtest..."

    # Run speedtest with license acceptance and capture JSON output
    SPEEDTEST_JSON=$(speedtest --accept-license --accept-gdpr --format=json-pretty)

    # If speedtest fails, exit
    if [[ $? -ne 0 ]] || [[ -z "$SPEEDTEST_JSON" ]]; then
        echo "Speedtest failed or returned empty data!" >&2
        exit 1
    fi

    # Extract values safely (handle missing fields)
    DOWNLOAD_SPEED=$(echo "$SPEEDTEST_JSON" | jq -r '.download.bandwidth // 0' | awk '{print $1 / 125000}')
    UPLOAD_SPEED=$(echo "$SPEEDTEST_JSON" | jq -r '.upload.bandwidth // 0' | awk '{print $1 / 125000}')
    LATENCY=$(echo "$SPEEDTEST_JSON" | jq -r '.ping.latency // 0')
    JITTER=$(echo "$SPEEDTEST_JSON" | jq -r '.ping.jitter // 0')
    JITTER_LOW=$(echo "$SPEEDTEST_JSON" | jq -r '.ping.low // 0')
    JITTER_HIGH=$(echo "$SPEEDTEST_JSON" | jq -r '.ping.high // 0')

    # Ensure .server is an object before extracting fields
    SERVER_ID=$(echo "$SPEEDTEST_JSON" | jq -r '.server.id // "unknown"')
    SERVER_NAME=$(echo "$SPEEDTEST_JSON" | jq -r '.server.name // "unknown"')
    SERVER_LOCATION=$(echo "$SPEEDTEST_JSON" | jq -r '.server.location // "unknown"')
    SERVER_COUNTRY=$(echo "$SPEEDTEST_JSON" | jq -r '.server.country // "unknown"')

    # ISP is a string, not an object
    ISP=$(echo "$SPEEDTEST_JSON" | jq -r '.isp // "unknown"')

    TIMESTAMP=$(echo "$SPEEDTEST_JSON" | jq -r '.timestamp | fromdate | strftime("%s") // 0')

    # Write Prometheus metrics
    {
        echo "# HELP speedtest_download_speed Download speed in Mbps"
        echo "# TYPE speedtest_download_speed gauge"
        echo "speedtest_download_speed $DOWNLOAD_SPEED"

        echo "# HELP speedtest_upload_speed Upload speed in Mbps"
        echo "# TYPE speedtest_upload_speed gauge"
        echo "speedtest_upload_speed $UPLOAD_SPEED"

        echo "# HELP speedtest_latency Ping latency in ms"
        echo "# TYPE speedtest_latency gauge"
        echo "speedtest_latency $LATENCY"

        echo "# HELP speedtest_jitter jitter in ms"
        echo "# TYPE speedtest_jitter gauge"
        echo "speedtest_jitter $JITTER"

        echo "# HELP speedtest_jitter_low Lowest jitter in ms"
        echo "# TYPE speedtest_jitter_low gauge"
        echo "speedtest_jitter_low $JITTER_LOW"

        echo "# HELP speedtest_jitter_high Highest jitter in ms"
        echo "# TYPE speedtest_jitter_high gauge"
        echo "speedtest_jitter_high $JITTER_HIGH"

        echo "# HELP speedtest_server_info Server metadata"
        echo "# TYPE speedtest_server_info gauge"
        echo "speedtest_server_info{server_id=\"$SERVER_ID\", server_name=\"$SERVER_NAME\", server_location=\"$SERVER_LOCATION\", server_country=\"$SERVER_COUNTRY\", isp=\"$ISP\"} 1"

        echo "# HELP speedtest_last_test_timestamp Timestamp of the last test"
        echo "# TYPE speedtest_last_test_timestamp gauge"
        echo "speedtest_last_test_timestamp $TIMESTAMP"
    } > "$METRICS_FILE"

    echo "Metrics updated at $(date)"
}

# Run the test at the given interval
while true; do
    run_speedtest
    echo "Waiting for $SPEEDTEST_INTERVAL seconds before next test..."
    sleep "$SPEEDTEST_INTERVAL"
done
