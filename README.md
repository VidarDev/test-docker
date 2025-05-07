# PrestaShop Production Infrastructure

Complete production-ready infrastructure for PrestaShop, fully containerized with Docker and orchestrated with Docker Compose.

## Overview

This infrastructure provides:

- PrestaShop application with preinstalled language
- MySQL database with phpMyAdmin
- NGINX reverse proxy with HTTPS
- Prometheus and Grafana monitoring
- Email and Slack alerts
- Automated database backups
- CI/CD pipeline with GitHub Actions

## Architecture

The architecture consists of the following services:

- **prestashop**: Main PrestaShop application
- **mysql**: Database for PrestaShop
- **phpmyadmin**: MySQL administration interface
- **nginx**: Reverse proxy with HTTPS
- **prometheus**: Metrics collection
- **grafana**: Metrics visualization dashboard
- **cadvisor**: Container metrics
- **node-exporter**: Host system metrics
- **alertmanager**: Alert management (email/Slack)
- **backup**: Periodic database backup

### Docker Networks

Containers are distributed across different Docker networks for optimal isolation:

- **prestashop_network**: Internal PrestaShop/MySQL communication
- **nginx_network**: NGINX communication
- **monitoring_network**: Monitoring tools communication
- **backup_network**: Backup and MySQL communication

### Persistent Volumes

Data is stored in persistent volumes:

- **prestashop_data**: PrestaShop files
- **mysql_data**: MySQL data
- **prometheus_data**: Prometheus metrics
- **grafana_data**: Grafana configuration
- **alertmanager_data**: Alertmanager configuration
- **backup_data**: Database backups

## Prerequisites

- Docker Engine 20.10.0+
- Docker Compose 2.0.0+
- Git
- 4 GB RAM minimum
- 20 GB disk space minimum

## Installation

1. Clone the repository:

```bash
git clone https://github.com/your-organization/prestashop-devops.git
cd prestashop-devops
```
