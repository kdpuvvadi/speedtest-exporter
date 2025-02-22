# Speedtest Exporter

Speedtest Exporter periodically measures internet speed and exposes the results in Prometheus metrics format via an Nginx web server.

## Features

- Runs Ookla's Speedtest CLI at a configurable interval.
- Outputs results in Prometheus metrics format.
- Serves metrics via Nginx at `/metrics`.

## Directory Structure

```
.
├── Dockerfile
├── compose.yaml
├── speedtest.sh
├── nginx/
│   ├── nginx.conf
│   ├── index.html
```

## Installation & Usage

### Prerequisites

- Docker
- Docker Compose
- Prometheus
- Grafana

### Setup

Docker compose

```yaml
services:
  speedtest-exporter:
    image: kdpuvvadi/speedtest-exporter:latest
    container_name: speedtest-exporter
    ports:
      - "9798:80"
    environment:
      - SPEEDTEST_INTERVAL=900
    restart: unless-stopped
```

Start the container:

```sh
docker compose up -d
```

### Access the Web Interface

- Landing Page: [http://localhost:9798](http://localhost:9798)
- Metrics Endpoint: [http://localhost:9798/metrics](http://localhost:9798/metrics)

## Configuration

- Modify `SPEEDTEST_INTERVAL` in `compose.yaml` to change the interval between tests.
- Update `nginx/nginx.conf` for custom Nginx configurations.

## Adding to Prometheus

To scrape the Speedtest metrics using Prometheus, add the following job to your `prometheus.yml` configuration:

```yaml
scrape_configs:
  - job_name: 'speedtest-exporter'
    static_configs:
      - targets: ['speedtest-exporter:9798']
```

Restart Prometheus after updating the configuration to apply the changes.

## License

This project is licensed under the MIT License.
