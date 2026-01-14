# How to get started with OpenTelemetry and Grafana

This repository contains the sample application that is used in the Grafana
webinar [How to get started with OpenTelemetry and Grafana](https://grafana.com/go/webinar/how-to-instrument-apps-with-otel-and-grafana/?pg=videos&plcmt=upcoming-webinars).
It consists of a minimal Python Flask web application and is based on the [OpenTelemetry Getting Started guide for Python](https://opentelemetry.io/docs/languages/python/getting-started/).

## Overview

This repository demonstrates two approaches to implementing OpenTelemetry with Grafana Cloud:

| Approach | Description | Best For |
|----------|-------------|----------|
| **[Basic](#basic-run-the-sample-application-with-direct-export-to-grafana-cloud)** | Direct export to Grafana Cloud | Learning, development, simple applications |
| **[Production-ready](#production-ready-run-the-sample-application-and-alloy-send-to-grafana-cloud)** | Via Grafana Alloy collector | Production environments, advanced processing |

## Basic: run the sample application with direct export to Grafana Cloud

This is a simplified example - we're going to run the application and send its telemetry directly to Grafana Cloud. It's best for learning OpenTelemetry basics and quick prototyping.

### Requirements

* [Python 3.13+](https://www.python.org/downloads/)
* Active Grafana Cloud account (or local OTel LGTM setup)

### Instructions

1. Set up a local project directory:

   ```sh
   git clone https://github.com/grafana/webinar-opentelemetry-getting-started/
   cd webinar-opentelemetry-getting-started
   python3 -m venv venv
   source ./venv/bin/activate
   ```

   See [Creating Virtual Environments](https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-virtual-environments) in the official Python documentation for more information.

2. Install dependencies:

   ```sh
   pip install flask
   ```

3. (Optional) Test the application before adding OpenTelemetry:

   ```sh
   flask run -p 8080
   ```

   With the application running, you should be able to see random dice rolls at [http://localhost:8080/rolldice](http://localhost:8080/rolldice).

4. Install the OpenTelemetry distro and instrumentation:

   ```sh
   pip install opentelemetry-distro
   opentelemetry-bootstrap -a install
   ```

5. Run the instrumented application with telemetry exported to the console:

   ```sh
   export OTEL_PYTHON_LOGGING_AUTO_INSTRUMENTATION_ENABLED=true
   opentelemetry-instrument \
     --traces_exporter console \
     --metrics_exporter console \
     --logs_exporter console \
     --service_name dice-server \
     flask run -p 8080
   ```

   With the application running, you should be able to see random dice rolls at
   [http://localhost:8080/rolldice](http://localhost:8080/rolldice). On the
   console, you will see telemetry (metrics, logs, and traces) that is created by
   your application.

6. Obtain and set up environment variables to send telemetry data to Grafana Cloud via OTLP:

   Follow these steps to get the environment variable values needed for your Grafana Cloud stack:

   * Navigate to the [Grafana Cloud Portal page](https://grafana.com/orgs/{profile})
   * Click **Details** on your stack
   * Click **Configure** in the OpenTelemetry section
   * Click **Generate now** to generate a new API token
   * Copy the pre-configured environment variables to your console:

     ```sh
     export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
     export OTEL_EXPORTER_OTLP_ENDPOINT="https://otlp-gateway-prod-us-east-0.grafana.net/otlp"
     export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic%20..."
     ```

   > [!NOTE]
   > For local testing and learning purposes, you can run the [Grafana OTel LGTM](https://github.com/grafana/docker-otel-lgtm/)
   > Docker container locally instead of sending data to Grafana Cloud.

   Start the OTel LGTM container with the following command:

   ```sh
   docker run -p 3000:3000 -p 4317:4317 -p 4318:4318 --rm -ti grafana/otel-lgtm
   ```

   When using the local LGTM stack, make sure the `OTEL_EXPORTER_OTLP_PROTOCOL`, `OTEL_EXPORTER_OTLP_ENDPOINT`,
   and `OTEL_EXPORTER_OTLP_HEADERS` environment variables are **not set**. The OpenTelemetry distro will default
   to using the `grpc` protocol and `http://localhost:4317` endpoint with no `Authorization` header, which works with
   the local OTel LGTM container.

7. Run the instrumented application:

   ```sh
   opentelemetry-instrument \
     --service_name dice-server \
     flask run -p 8080
   ```

8. Test the application and verify telemetry:

   * Open [http://localhost:8080/rolldice](http://localhost:8080/rolldice) in your browser
   * Generate some dice rolls to create telemetry data
   * Wait for data to appear in Grafana Cloud (or check local Grafana at [http://localhost:3000](http://localhost:3000) if using OTel LGTM)
   * Check your Grafana dashboard for:
     - **Traces**: Navigate to Explore → Tempo
     - **Metrics**: Navigate to Explore → Prometheus
     - **Logs**: Navigate to Explore → Loki


## Production-ready: run the sample application and Alloy, send to Grafana Cloud

This approach uses [Grafana Alloy](https://grafana.com/docs/alloy/latest/) to receive, process, and forward telemetry data to Grafana Cloud. This provides more flexibility for telemetry processing and is closer to a production setup.

### Requirements

* [Docker](https://docs.docker.com/engine/install/) and Docker Compose
* Active Grafana Cloud account

### Instructions

1. If you haven't done it yet, clone this repository:

   ```sh
   git clone https://github.com/grafana/webinar-opentelemetry-getting-started/
   cd webinar-opentelemetry-getting-started
   ```

2. Set up environment variables for Grafana Cloud:

   Follow the steps below to obtain the environment variable values necessary
   to send data to your Grafana Cloud stack:

   * Navigate to the [Grafana Cloud Portal page](https://grafana.com/orgs/{profile}).
   * Click **Details** on your stack.
   * Click **Configure** in the OpenTelemetry section.
   * Click **Generate now** to generate a new API token.
   * Replace the example OTLP endpoint details in the `.env` file with your actual Grafana Cloud credentials:

     ```text
     GRAFANA_CLOUD_OTLP_ENDPOINT="https://otlp-gateway-prod-us-east-0.grafana.net/otlp"
     GRAFANA_CLOUD_INSTANCE_ID=1234567890
     GRAFANA_CLOUD_API_KEY=glc_...
     ```

   > [!NOTE]
   > Instead of sending data to Grafana Cloud, you can leverage OTLP endpoints
   > available for Loki, Tempo, and Mimir. Check out the [OTLP endpoint](https://grafana.com/docs/opentelemetry/ingest/#self-managed-observability)
   > article for more details.

3. Run the instrumented application with telemetry exported to Grafana Cloud:

   ```sh
   docker compose up --build
   ```

4. Test and validate the setup:

   * Test the application: [http://localhost:8080/rolldice](http://localhost:8080/rolldice)
   * Generate several dice rolls to create telemetry data
   * Wait for data to appear in Grafana Cloud


After generating telemetry data, metrics, logs, and traces should be visible in Grafana Cloud.

## Next Steps

- [OpenTelemetry at Grafana Labs](https://grafana.com/docs/opentelemetry/)
- [Grafana Alloy Documentation](https://grafana.com/docs/alloy/latest/)
- [OpenTelemetry Python Documentation](https://opentelemetry.io/docs/languages/python/)

