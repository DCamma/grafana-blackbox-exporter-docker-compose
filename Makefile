.PHONY: up down restart logs status reload clean help

help:
	@echo "Usage:"
	@echo "  make up       - Start Prometheus, Blackbox Exporter & Watcher (in background)"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - Follow logs for all services"
	@echo "  make status   - Show running container status"
	@echo "  make reload   - Manually trigger config reload for Prometheus & Blackbox"
	@echo "  make clean    - Stop services and remove persistent data volumes"

up:
	docker compose up -d --build
	@echo ""
	@echo "=========================================================================================="
	@echo "Services started successfully!"
	@echo "Grafana Dashboard Link (Blackbox Overview):"
	@echo "http://localhost:3000/d/xtkCtBkiz/prometheus-blackbox-exporter"
	@echo "Credentials: admin / admin"
	@echo "=========================================================================================="
	@echo ""

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

status:
	docker compose ps

reload:
	@echo "Triggering manual reload for Prometheus..."
	@curl -s -X POST http://localhost:9090/-/reload && echo "Prometheus reloaded." || echo "Failed to reload Prometheus."
	@echo "Triggering manual reload for Blackbox Exporter..."
	@curl -s -X POST http://localhost:9115/-/reload && echo "Blackbox Exporter reloaded." || echo "Failed to reload Blackbox Exporter."

clean:
	docker compose down -v
