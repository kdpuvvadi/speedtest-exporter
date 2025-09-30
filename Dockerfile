FROM debian:13

# Install dependencies
# hadolint ignore=DL3006,DL3008,DL3009,DL4006
RUN apt-get update && \
    apt-get install -y curl jq gnupg apt-transport-https ca-certificates nginx && \
    rm -rf /var/lib/apt/lists/*

# Add Ookla's GPG key
RUN curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/ookla-speedtest.gpg

# Add Ookla repo
RUN cat <<EOF > /etc/apt/sources.list.d/ookla-speedtest.sources
Types: deb
URIs: https://packagecloud.io/ookla/speedtest-cli/debian/
Suites: trixie
Components: main
Signed-By: /etc/apt/trusted.gpg.d/ookla-speedtest.gpg
EOF

# Install speedtest
RUN apt-get update && apt-get install -y speedtest && \
    rm -rf /var/lib/apt/lists/* && \
    speedtest --version || (echo "Speedtest CLI failed!" && false)

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
