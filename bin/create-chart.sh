#!/bin/bash

cat > "${FISSILE_OUTPUT_DIR}/Chart.yaml" << EOF
apiVersion: v1
appVersion: "1.0"
description: A Helm chart for Kubernetes
name: nginx
version: 0.1.0
EOF
