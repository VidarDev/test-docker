# PrestaShop DevOps Infrastructure

This repository contains a complete containerized infrastructure for running PrestaShop in a production-like environment with monitoring, backup, and security features.

## Architecture

The infrastructure includes:

- **PrestaShop**: Main application with a customized Dockerfile (French language and Hummingbird theme)
- **MariaDB**: Database for PrestaShop
- **phpMyAdmin**: Web interface for database management
- **Traefik**: Reverse proxy with HTTPS support
- **Monitoring Stack**:
  - Prometheus: Metrics collection
  - Grafana: Dashboards for visualization
  - cAdvisor: Container metrics
  - Node Exporter: Host metrics
  - Alertmanager: Alert processing and notifications
- **Backup System**: Automated backup with restic
- **SMTP Server**: For email notifications
- **CI/CD Pipeline**: GitHub Actions for continuous integration and deployment

## Network Architecture

The setup uses two Docker networks:

- `internal`: For internal application communication (database, backup, etc.)
- `traefik`: For reverse proxy communication and exposure to the outside world

## Security Features

- Non-root container execution
- Network isolation through separate Docker networks
- Environment variable management with .env file
- HTTPS support with Traefik
- Secure headers configuration
- Automatic HTTP to HTTPS redirection
- Basic auth for admin panels

## Setup Instructions

### Prerequisites

- Docker and Docker Compose
- Git
- Make

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/prestashop-devops.git
   cd prestashop-devops
   ```

2. Configure environment variables:

   ```bash
   cp infra/.env.example infra/.env
   # Edit the .env file with your settings
   ```

3. Start the infrastructure:

   ```bash
   make up
   ```

4. Access the applications:
   - PrestaShop: <https://prestashop.localhost>
   - phpMyAdmin: <https://phpmyadmin.localhost>
   - Traefik Dashboard: <https://traefik.localhost>
   - Grafana: <https://grafana.localhost> (default login: admin/admin)
   - Prometheus: <https://prometheus.localhost>
   - Alertmanager: <https://alertmanager.localhost>
   - cAdvisor: <https://cadvisor.localhost>
   - Node Exporter: <https://node-exporter.localhost>

### Managing the Infrastructure

Common commands:

- `make up`: Start all containers
- `make stop`: Stop containers
- `make down`: Stop and remove containers
- `make restart`: Restart containers
- `make build`: Rebuild images
- `make db`: Access the database CLI
- `make prestashop`: Access the PrestaShop container shell
- `make health-check`: Run a health check on all containers
- `make backup`: Trigger a manual backup
- `make restore`: Restore from the latest backup
- `make clean`: Clean up unused Docker resources

## Backup System

Backups are automatically performed every 6 hours using restic. The database is dumped and stored in a dedicated Docker volume. The backup script also handles rotation to keep only the last 7 backups (configurable via .env).

To manually trigger a backup:

```bash
make backup
```

To restore from the latest backup:

```bash
make restore
```

To list available backups:

```bash
docker compose exec restic restic snapshots
```

## CI/CD Pipeline

The repository includes a GitHub Actions workflow for continuous integration and deployment:

1. On push to main or when tagging, the workflow builds and pushes the PrestaShop image to Docker Hub.
2. For non-PR events, it deploys the updated infrastructure to the production server.

Required GitHub secrets:

- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token
- `DEPLOY_SSH_KEY`: SSH private key for deployment
- `DEPLOY_USER`: SSH username for deployment
- `DEPLOY_HOST`: SSH host for deployment

## Monitoring

Monitoring is provided by:

- Prometheus for metrics collection
- Grafana for dashboards
- cAdvisor for container metrics
- Node Exporter for host metrics
- Alertmanager for alerting

Default dashboards include:

- System Overview: CPU, RAM, disk usage, and uptime
- Container Metrics: Per-container CPU, memory, network, and disk I/O

Default alerts are configured for:

- Instance down
- High CPU load
- High memory usage
- Low disk space
- High container resource usage

Alerts are sent via email and Slack (configurable in alertmanager.yml).

## Customization

### Adding Custom Themes/Modules

To add custom themes or modules to PrestaShop, modify the `infra/docker/prestashop/Dockerfile` to include the installation steps.

### Modifying Monitoring

To add new dashboards, place JSON dashboard files in `infra/docker/monitoring/grafana/dashboards/prestashop/`.

To add new alerts, modify `infra/docker/monitoring/prometheus/rules/alerts.yml`.

## Troubleshooting

### Common Issues

1. **Network Issues**:
   If containers can't communicate, check that networks are properly created:

   ```
   make create-networks
   ```

2. **HTTPS Not Working**:
   Ensure your browser trusts the self-signed certificates or set up Let's Encrypt for production.

3. **Backup Failures**:
   Check the backup logs:

   ```
   docker compose exec restic cat /backup/logs/backup.log
   ```

### Logs

To view logs from any container:

```bash
docker compose logs <container-name>
```

For example, to view PrestaShop logs:

```bash
docker compose logs prestashop
```

## License

MIT

## Author

Your Name
