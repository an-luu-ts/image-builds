#!/bin/bash

set -eu -o pipefail

export TEMPORAL_ADDRESS="${BIND_ON_IP}:7233"

# Support TEMPORAL_CLI_ADDRESS for backwards compatibility.
# TEMPORAL_CLI_ADDRESS is deprecated and support for it will be removed in the future release.
if [[ -z "${TEMPORAL_CLI_ADDRESS:-}" ]]; then
    export TEMPORAL_CLI_ADDRESS="${TEMPORAL_ADDRESS}"
fi

dockerize -template /etc/temporal/config/config_template.yaml:/etc/temporal/config/docker.yaml

# Automatically setup Temporal Server (databases, Elasticsearch, default namespace) if "autosetup" is passed as an argument.
for arg; do [[ ${arg} == autosetup ]] && /etc/temporal/auto-setup.sh && break ; done

# Setup Temporal Server in development mode if "develop" is passed as an argument.
for arg; do [[ ${arg} == develop ]] && /etc/temporal/setup-develop.sh && break ; done

# Run bash instead of Temporal Server if "bash" is passed as an argument (convenient to debug docker image).
for arg; do [[ ${arg} == bash ]] && bash && exit 0 ; done

exec /etc/temporal/start-temporal.sh
