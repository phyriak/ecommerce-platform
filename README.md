# Ecommerce Platform Infrastructure

Central repository containing shared infrastructure for the Ecommerce Platform microservices ecosystem.

## Purpose

This repository provides a common runtime environment for all platform services, including:

* Payment Service
* Order Service
* Notification Service
* Future microservices

The infrastructure is deployed once and shared across all applications.

---

## Components

### Database

* PostgreSQL 16
* Single database: `ecommerce`
* Separate schemas per service
* Separate database users per service

Example:

```text
ecommerce
├── payment_service
├── order_service
└── notification_service
```

### Messaging

* Apache Kafka
* Zookeeper

Used for asynchronous communication between microservices.

### Observability

#### Metrics

* Prometheus

#### Dashboards

* Grafana

#### Distributed Tracing

* OpenTelemetry Collector
* Grafana Tempo

#### Centralized Logging

* Loki
* Promtail

---

## Repository Structure

```text
ecommerce-platform/

├── docker-compose.yml

├── postgres/
│   └── init/

├── prometheus/
│   └── prometheus.yml

├── loki/
│   └── loki-config.yml

├── promtail/
│   └── promtail-config.yml

├── tempo/
│   └── tempo.yml

├── otel/
│   └── otel-collector-config.yml

├── storage/
│   ├── postgres/
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   ├── tempo/
│   └── logs/

└── .github/
    └── workflows/
```

---

## Deployment

Infrastructure is automatically deployed through GitHub Actions.

### Workflow

1. Push changes to `main`
2. GitHub Actions validates Docker Compose configuration
3. Workflow connects to Hetzner VPS
4. Latest changes are pulled
5. Infrastructure is updated using Docker Compose

---

## Services

| Service                 | Port |
| ----------------------- | ---- |
| PostgreSQL              | 5433 |
| Kafka                   | 9092 |
| Zookeeper               | 2181 |
| Prometheus              | 9090 |
| Grafana                 | 3000 |
| Loki                    | 3100 |
| Tempo                   | 3200 |
| OpenTelemetry Collector | 4320 |

---

## Grafana Datasources

### Prometheus

```text
http://prometheus:9090
```

### Loki

```text
http://loki:3100
```

### Tempo

```text
http://tempo:3200
```

---

## Logging

Each microservice should write logs to:

```text
storage/logs/<service-name>/
```

Examples:

```text
storage/logs/payment-service/
storage/logs/order-service/
storage/logs/notification-service/
```

Logs are collected by Promtail and stored in Loki.

---

## Tracing

Applications should export traces to:

```text
http://otel-collector:4318/v1/traces
```

or externally:

```text
http://<SERVER_IP>:4320/v1/traces
```

Collected traces are stored in Tempo and visualized in Grafana.

---

## Monitoring

Applications should expose metrics through Spring Boot Actuator:

```text
/actuator/prometheus
```

Prometheus scrapes metrics and Grafana visualizes them.

---

## Future Services

Planned services:

* Payment Service
* Order Service
* Notification Service
* Product Service
* Inventory Service
* Customer Service

All services will use the shared infrastructure provided by this repository.
