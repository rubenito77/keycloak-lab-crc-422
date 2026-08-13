#Requires -Version 5.1
$ErrorActionPreference = "Stop"

Write-Host "==> Aplicando manifiestos en orden..." -ForegroundColor Cyan
Get-ChildItem -Path "manifests" -Filter "*.yaml" | Sort-Object Name | ForEach-Object {
    Write-Host "  - $($_.Name)"
    oc apply -f $_.FullName
    if ($LASTEXITCODE -ne 0) {
        throw "Fallo aplicando $($_.Name)"
    }
}

Write-Host "==> Esperando a que Postgres esté disponible..." -ForegroundColor Cyan
oc rollout status deployment/postgresql -n keycloak-lab --timeout=180s
if ($LASTEXITCODE -ne 0) { throw "Postgres no llegó a estar disponible" }

Write-Host "==> Esperando a que Keycloak esté disponible..." -ForegroundColor Cyan
oc rollout status deployment/keycloak -n keycloak-lab --timeout=300s
if ($LASTEXITCODE -ne 0) { throw "Keycloak no llegó a estar disponible" }

$routeHost = oc get route keycloak -n keycloak-lab -o jsonpath='{.spec.host}'

Write-Host ""
Write-Host "==> Listo. Keycloak disponible en: https://$routeHost" -ForegroundColor Green
Write-Host "==> Admin user: admin (ver/editar manifests\05-keycloak-secret.yaml)" -ForegroundColor Green
