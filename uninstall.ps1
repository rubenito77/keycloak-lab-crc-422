#Requires -Version 5.1
$ErrorActionPreference = "Stop"

Write-Host "==> Eliminando namespace keycloak-lab (borra todo, incluido el PVC)..." -ForegroundColor Yellow
oc delete namespace keycloak-lab --ignore-not-found=true

Write-Host "==> Listo." -ForegroundColor Green
