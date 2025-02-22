FROM debian:12

# Install dependencies
RUN apt update && apt install -y curl jq gnupg nginx && apt clean

# Add Ookla's official Speedtest CLI repository
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash

# Update package lists and install Speedtest CLI
RUN apt update && apt install -y speedtest

# Verify installation
RUN speedtest --version || echo "Speedtest CLI failed to install!"

# Copy the speedtest script
COPY speedtest.sh /usr/local/bin/speedtest.sh
RUN chmod +x /usr/local/bin/speedtest.sh

# Create directory for metrics
RUN mkdir -p /usr/share/nginx/html

# Copy Nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy landng page
COPY nginx/index.html /usr/share/nginx/html/index.html

# Expose port
EXPOSE 80

# Start both Speedtest and Nginx
CMD ["/bin/bash", "-c", "/usr/local/bin/speedtest.sh & nginx -g 'daemon off;'"]
