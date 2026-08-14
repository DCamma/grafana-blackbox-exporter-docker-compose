# Agent Onboarding & Development Guide

This guide is designed for AI coding agents to quickly understand the structure, execution flow, and development workflows of this local Prometheus and Blackbox Exporter repository.

---

## 🏗️ Architecture & Component Overview

This repository runs a local monitoring stack using Docker Compose:

1. **Prometheus (`prometheus`)**: Scrapes and stores metrics. Started with `--web.enable-lifecycle` to allow HTTP-based configuration reloads.
2. **Blackbox Exporter (`blackbox-exporter`)**: Probes endpoints over HTTP/S, TCP, ICMP, DNS, etc., and returns metrics to Prometheus.
3. **Config Watcher (`watcher`)**: A sidecar container running `inotifywait`. It monitors the `config/` directory and automatically issues POST requests to reload configurations on both Prometheus and Blackbox Exporter immediately after any file change.

---

## 📁 Repository Layout

Below are the key files and folders you need to interact with:

- [`docker-compose.yml`](docker-compose.yml): Services orchestration, healthchecks, and mounts.
- [`Makefile`](Makefile): Shortcuts for managing the stack (`make up`, `make status`, `make reload`, `make down`).
- [`config/`](config/):
  - [`blackbox/blackbox.yml`](config/blackbox/blackbox.yml): Defines probe configurations (e.g., HTTP request methods, timeout, expected status codes, SSL settings, and header checks).
  - [`prometheus/prometheus.yml`](config/prometheus/prometheus.yml): Configures scraper jobs. Notice how target groups are separated by file.
  - [`prometheus/targets/`](config/prometheus/targets/): Contains separate target files for modular management.
    - [`http_targets.yml`](config/prometheus/targets/http_targets.yml): General websites/endpoints.
    - [`mp4_targets.yml`](config/prometheus/targets/mp4_targets.yml): Targets specifically for MP4/media stream checks.
  - [`grafana/`](config/grafana/): Grafana provisioning and dashboard configurations to run fully-configured dashboards automatically.

---

## 🛠️ Workflows for Common Tasks

### 1. Adding a New Probe Type (Module)
1. Open [`config/blackbox/blackbox.yml`](config/blackbox/blackbox.yml).
2. Define a new module under `modules:`. Choose the appropriate prober type (e.g., `http`, `tcp`, `dns`).
3. Set specialized rules. For example, to avoid downloading large files:
   ```yaml
   check_something:
     prober: http
     http:
       method: HEAD  # Fetches headers only (avoids downloading entire payloads)
   ```
4. Save the file. The `watcher` sidecar automatically reloads the Blackbox config.

### 2. Monitoring New Targets
1. **For existing modules**: Open the corresponding target file in [`config/prometheus/targets/`](config/prometheus/targets/) and add the target under `targets:`.
2. **For new modules**: 
   - Create a targets file (e.g., `xyz_targets.yml`).
   - Add a new job block to [`config/prometheus/prometheus.yml`](config/prometheus/prometheus.yml):
     ```yaml
     - job_name: "blackbox_xyz_targets"
       metrics_path: /probe
       params:
         module: [xyz_module_name]
       file_sd_configs:
         - files:
             - /etc/prometheus/targets/xyz_targets.yml
           refresh_interval: 10s
       relabel_configs:
         - source_labels: [__address__]
           target_label: __param_target
         - source_labels: [__param_target]
           target_label: instance
         - target_label: __address__
           replacement: blackbox-exporter:9115
     ```

### 3. Testing/Debugging Probes Directly
You can run a query directly against the Blackbox Exporter from the command line using `curl`:
```bash
curl -s "http://localhost:9115/probe?module=<MODULE_NAME>&target=<TARGET_URL>"
```
Adding `&debug=true` to the URL provides detailed logs of the connection stages (DNS resolution, TCP connection, TLS handshake, HTTP redirects, and header/body checks).

---

## ⚡ Development Commands Quick Reference

- **Start Stack**: `make up`
- **Stop Stack**: `make down`
- **Check Logs**: `make logs`
- **Force Reload**: `make reload`
- **Reset Volume Data**: `make clean`
