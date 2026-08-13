# Keycloak + Postgres — Lab en CRC (OpenShift Local)

Manifiestos para levantar Keycloak con base de datos Postgres persistente en un
cluster CRC, pensados para poder reinstalar rápido cada vez que se actualiza CRC.

## Componentes

| Recurso | Descripción |
|---|---|
| `00-namespace.yaml` | Namespace `keycloak-lab` |
| `01-postgres-secret.yaml` | Credenciales de Postgres |
| `02-postgres-pvc.yaml` | PVC de 2Gi (`standard-csi`, storage class default de CRC) |
| `03-postgres-deployment.yaml` | Deployment de Postgres (imagen `quay.io/sclorg/postgresql-16-c9s`, compatible con SCC `restricted-v2`) |
| `04-postgres-service.yaml` | Service ClusterIP `postgresql:5432` |
| `05-keycloak-secret.yaml` | Credenciales de admin de Keycloak y de conexión a DB |
| `06-keycloak-deployment.yaml` | Deployment de Keycloak `26.7.0` (modo `start-dev`) |
| `07-keycloak-service.yaml` | Service ClusterIP `keycloak:8080` |
| `08-keycloak-route.yaml` | Route edge TLS para acceso externo |
| `install.ps1` / `uninstall.ps1` | Scripts para Windows PowerShell |
| `install.sh` / `uninstall.sh` | Scripts equivalentes para bash |

## Requisitos previos

- CRC corriendo (`crc start`) y logueado con `oc login -u kubeadmin ...`
- Usuario con permisos para crear namespaces (o pedile a un admin que cree
  `keycloak-lab` de antemano)
- `oc` en el PATH (tanto en PowerShell como en bash)

## Instalación

**Windows / PowerShell:**

```powershell
git clone <tu-repo>
cd keycloak-lab-crc
.\install.ps1
```

Si PowerShell bloquea la ejecución de scripts, corré una sola vez (como admin
o para el usuario actual):

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

**Linux / bash** (Fedora, WSL, etc.):

```bash
git clone <tu-repo>
cd keycloak-lab-crc
chmod +x install.sh uninstall.sh
./install.sh
```

Al finalizar el script imprime la URL del Route. Login con el usuario definido
en `manifests/05-keycloak-secret.yaml` (por defecto `admin` / `keycloak-admin-pass`).

## Desinstalación

```powershell
.\uninstall.ps1
```

```bash
./uninstall.sh
```

Esto borra el namespace completo, **incluyendo el PVC** (se pierden los datos).

## Notas / decisiones de diseño

- **Manifiestos directos en vez de Operator**: para un laboratorio en CRC (recursos
  limitados) es más liviano y más fácil de entender/debuggear que el Keycloak Operator.
- **Imagen `sclorg/postgresql-16-c9s`**: soporta UID arbitrario asignado por la
  SCC `restricted-v2` de OpenShift. No fijar `runAsUser` en el manifest (misma
  lección aprendida en el PoC de Prometheus remote_write).
- **`start-dev`**: modo simplificado de Keycloak para lab (sin HTTPS interno,
  sin caché distribuida). No usar en producción.
- **`KC_BOOTSTRAP_ADMIN_USERNAME` / `KC_BOOTSTRAP_ADMIN_PASSWORD`**: forma
  vigente en Keycloak 26.x de crear el usuario admin inicial (reemplaza a
  `KEYCLOAK_ADMIN` de versiones anteriores).

## Para actualizar credenciales

Editá `manifests/01-postgres-secret.yaml` y `manifests/05-keycloak-secret.yaml`
**antes** de correr `install.sh` en un entorno que no sea 100% descartable.

## Próximos pasos sugeridos

- Crear un realm `demo` para integrarlo con el lab de OAuth2 Proxy / Kong.
- Cambiar a modo `start` (no `start-dev`) + certificados propios si se quiere
  acercar el lab a un despliegue productivo.
