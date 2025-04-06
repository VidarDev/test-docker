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

The setup uses three isolated Docker networks:

- `ps-internal-network`: For internal application communication
- `ps-traefik-network`: For reverse proxy communication
- `ps-monitoring-network`: For monitoring components

## Security Features

- Non-root container execution
- Network isolation
- Environment variable management with .env file
- HTTPS support with Traefik
- Secure headers configuration

## Setup Instructions

### Prerequisites

- Docker and Docker Compose
- Git
- Make

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/prestashop-devops.git
   cd prestashop-devops
   ```

2. Configure environment variables:

   ```
   cp infra/.env.example infra/.env
   # Edit the .env file with your settings
   ```

3. Start the infrastructure:

   ```
   make up
   ```

4. Access the applications:
   - PrestaShop: https://prestashop.localhost
   - phpMyAdmin: https://phpmyadmin.ps.localhost
   - Traefik Dashboard: https://traefik.ps.localhost
   - Grafana: https://grafana.ps.localhost (default login: admin/admin)
   - Prometheus: https://prometheus.ps.localhost
   - Alertmanager: https://alertmanager.ps.localhost

### Managing the Infrastructure

Common commands:

- `make up`: Start all containers
- `make down`: Stop and remove containers
- `make restart`: Restart containers
- `make build`: Rebuild images
- `make db`: Access the database CLI
- `make prestashop`: Access the PrestaShop container shell

## Backup System

Backups are automatically performed every 6 hours using restic. The database is dumped and stored in a dedicated Docker volume. The backup script also handles rotation to keep only the last 7 backups.

To manually trigger a backup:

```
docker compose exec backup /scripts/backup.sh
```

To list backups:

```
docker compose exec backup restic snapshots
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

Default alerts are configured for:

- Instance down
- High CPU load
- High memory usage
- Low disk space

Alerts are sent via email to the configured address in the Alertmanager configuration.

## License

MIT
