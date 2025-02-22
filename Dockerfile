FROM debian:12

# Install dependecies & speedtest
# hadolint ignore=DL3006,DL3008,DL3009,DL4006
RUN apt-get update && apt-get install -y curl jq gnupg nginx --no-install-recommends && apt-get clean \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash \
    apt-get update && apt-get install -y speedtest --no-install-recommends && apt-get clean \
    speedtest --version || echo "Speedtest CLI failed to install!"

# Copy the speedtest script
COPY speedtest.sh /usr/local/bin/speedtest.sh
RUN chmod +x /usr/local/bin/speedtest.sh && \
    mkdir -p /usr/share/nginx/html

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy landng page
COPY nginx/index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Start both Speedtest and Nginx
CMD ["/bin/bash", "-c", "/usr/local/bin/speedtest.sh & nginx -g 'daemon off;'"]
