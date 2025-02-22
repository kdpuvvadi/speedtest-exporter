FROM debian:12

# Install dependecies & speedtest
RUN apt-get update && apt-get install -y curl jq gnupg nginx && apt clean \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash \
    apt-get update && apt-get install -y speedtest \
    speedtest --version || echo "Speedtest CLI failed to install!"

# Copy the speedtest script
COPY speedtest.sh /usr/local/bin/speedtest.sh
RUN chmod +x /usr/local/bin/speedtest.sh \
    mkdir -p /usr/share/nginx/html

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy landng page
COPY nginx/index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Start both Speedtest and Nginx
CMD ["/bin/bash", "-c", "/usr/local/bin/speedtest.sh & nginx -g 'daemon off;'"]
