FROM prom/prometheus:v3.2.1

# Enable lifecycle API to allow POST /-/reload for hot config reloading
CMD [ \
  "--config.file=/etc/prometheus/prometheus.yml", \
  "--storage.tsdb.path=/prometheus", \
  "--web.enable-lifecycle", \
  "--web.console.libraries=/usr/share/prometheus/console_libraries", \
  "--web.console.templates=/usr/share/prometheus/consoles" \
]
