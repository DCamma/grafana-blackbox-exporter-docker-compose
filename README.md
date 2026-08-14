# Local Prometheus & Blackbox Exporter Setup

A lightweight, on-demand local setup for running **Prometheus** and **Blackbox Exporter** using Docker Compose. Features automatic config hot-reloading when editing configuration files.

---

## 🚀 Quick Start

Since this setup is meant to run on-demand when needed:

### Start Services
```bash
make up
# or: docker compose up -d --build
```

### Check Service Status
```bash
make status
```

### View Live Logs
```bash
make logs
```

### Stop Services
```bash
make down
# or: docker compose down
```

---

## 🔗 Endpoints & Web UI

- **Grafana (Blackbox Dashboard)**: [http://localhost:3000/d/xtkCtBkiz/prometheus-blackbox-exporter](http://localhost:3000/d/xtkCtBkiz/prometheus-blackbox-exporter)
  - Default credentials: `admin` / `admin`
- **Prometheus UI**: [http://localhost:9090](http://localhost:9090)
  - Targets status page: [http://localhost:9090/targets](http://localhost:9090/targets)
- **Blackbox Exporter**: [http://localhost:9115](http://localhost:9115)

---

## 🔄 Automatic Hot-Reload on Config Changes

You do **not** need to restart containers when modifying target or module configs:

1. **Config Watcher Sidecar**: The `watcher` container monitors the `./config` directory using `inotify`. Whenever `prometheus.yml` or `blackbox.yml` is saved/modified, it automatically sends an HTTP POST request to:
   - `http://prometheus:9090/-/reload`
   - `http://blackbox-exporter:9115/-/reload`

2. **File Target Discovery (`file_sd`)**: Target files in `./config/prometheus/targets/*.yml` are dynamically picked up by Prometheus without needing full reload.

3. **Manual Reload**:
   ```bash
   make reload
   ```

---

## 📁 Repository Layout

```
.
├── docker-compose.yml
├── Makefile
├── README.md
├── config/
│   ├── blackbox/
│   │   └── blackbox.yml           # Blackbox module probes (http_2xx, icmp, tcp, etc.)
│   ├── grafana/
│   │   ├── dashboards/
│   │   │   └── blackbox.json      # Provisioned Blackbox dashboard config (ID 7587)
│   │   └── provisioning/          # Grafana automated datasources/dashboards config
│   └── prometheus/
│       ├── prometheus.yml         # Main Prometheus scrape config
│       └── targets/
│           ├── http_targets.yml   # Target list (scraped via file_sd_configs)
│           └── mp4_targets.yml    # MP4 target list
└── docker/
    ├── blackbox/
    │   └── Dockerfile             # Blackbox Exporter container
    ├── prometheus/
    │   └── Dockerfile             # Prometheus container
    └── watcher/
        ├── Dockerfile             # alpine sidecar watcher container
        └── watch.sh               # inotify watcher script
```

---

## 📊 Sample Queries in Prometheus UI

- **Probe Success Status**: `probe_success`
- **Probe Duration (seconds)**: `probe_duration_seconds`
- **HTTP Status Code**: `probe_http_status_code`
- **SSL Certificate Expiry (seconds)**: `probe_ssl_earliest_cert_expiry - time()`
