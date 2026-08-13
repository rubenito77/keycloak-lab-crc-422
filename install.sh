#!/usr/bin/env bash
set -euo pipefail

echo "==> Aplicando manifiestos en orden..."
for f in manifests/*.yaml; do
  echo "  - $f"
  oc apply -f "$f"
done

echo "==> Esperando a que Postgres esté disponible..."
oc rollout status deployment/postgresql -n keycloak-lab --timeout=180s

echo "==> Esperando a que Keycloak esté disponible..."
oc rollout status deployment/keycloak -n keycloak-lab --timeout=300s

ROUTE_HOST=$(oc get route keycloak -n keycloak-lab -o jsonpath='{.spec.host}')
echo ""
echo "==> Listo. Keycloak disponible en: https://${ROUTE_HOST}"
echo "==> Admin user: admin (ver/editar manifests/05-keycloak-secret.yaml)"
