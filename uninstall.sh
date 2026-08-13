#!/usr/bin/env bash
set -euo pipefail

echo "==> Eliminando namespace keycloak-lab (borra todo, incluido el PVC)..."
oc delete namespace keycloak-lab --ignore-not-found=true

echo "==> Listo."
