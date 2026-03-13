# GeoNode Kubernetes Jobs

GeoNode uses Kubernetes Jobs to run one-off administrative tasks during deployment and upgrades. This document describes the available jobs, how they run automatically, and how to manage them manually.

## Jobs overview

Two jobs are included in the chart:

### `geonode-init-db-job`
**File:** `charts/geonode/templates/geonode/jobs/geonode-init-db-job.yaml`

Runs database and GeoServer initialisation tasks via the `invoke` tool:

- `waitfordbs` — waits for the database to be ready
- `migrations` — runs Django database migrations
- `prepare` / `fixtures` — inserts initial fixture data
- `waitforgeoserver` / `geoserverfixture` — creates the GeoServer data store
- `updateadmin` — sets the GeoNode admin user password

### `geonode-statics-job`
**File:** `charts/geonode/templates/geonode/jobs/geonode-statics-job.yaml`

Collects and publishes static assets via the `invoke` tool:

- `initialized` — waits for GeoNode to be ready
- `statics` — builds and copies static files

---

## Automatic cleanup on upgrade

Kubernetes Jobs have an **immutable `spec.template`** field. When Helm upgrades a release with a new GeoNode image version, it cannot update the existing jobs in-place, causing the upgrade to fail:

```
Error: UPGRADE FAILED: cannot patch "geonode-geonode-init-db-job" with kind Job:
Job.batch "geonode-geonode-init-db-job" is invalid:
spec.template: Invalid value: ...: field is immutable
```

A pre-upgrade Helm hook (`geonode-cleanup-job.yaml`) solves this by automatically deleting both jobs before Helm applies the new ones.

### How the hook works

The hook consists of two template files:

- `geonode-cleanup-rbac.yaml` — creates a ServiceAccount, Role, and RoleBinding scoped to `batch/jobs` in the release namespace
- `geonode-cleanup-job.yaml` — the pre-upgrade Job that runs `kubectl delete job` for both jobs

At template-render time, the hook uses Helm's `lookup` function to read the currently deployed `init-db-job` from the cluster. It compares the container image of the existing job against the desired image (`geonode.image.name:geonode.image.tag`):

- **Same image** — the hook is skipped entirely, no cleanup resources are rendered
- **Different image** (or no existing job) — the hook runs and deletes both old jobs so Helm can recreate them with the new image

All deletes use `--ignore-not-found=true`, so the hook succeeds even when the jobs are not present.

The `hook-delete-policy: before-hook-creation,hook-succeeded` ensures:
- **`before-hook-creation`** — any previous cleanup job is removed before a new one is created, preventing "already exists" errors on repeated upgrades
- **`hook-succeeded`** — the completed cleanup job is removed after it finishes, keeping the cluster tidy

### Hook execution order

| Weight | Resource |
|---|---|
| `-10` | ServiceAccount, Role, RoleBinding (`geonode-cleanup-rbac.yaml`) |
| `-5` | Cleanup Job (`geonode-cleanup-job.yaml`) |

### Configuration

```yaml
geonode:
  hooks:
    # Enable automatic cleanup of old jobs before helm upgrade
    cleanupOnUpgrade: true

    # Official Kubernetes project kubectl image (distroless — no shell)
    kubectlImage: registry.k8s.io/kubectl
    kubectlTag: "v1.32.0"
```

!!! note
    The `registry.k8s.io/kubectl` image is distroless (no shell). The Job uses
    `initContainers` to invoke `kubectl` directly as the container entrypoint,
    with one init container per deletion.

---

## Manual re-execution

In some cases it may be necessary to manually rerun a job — for example after a failed deployment or to re-apply fixtures. Delete the existing job and recreate it from the chart:

```bash
# List all jobs
kubectl get jobs -n <namespace>

# Delete the job to rerun (example: init-db-job)
kubectl delete job geonode-geonode-init-db-job -n <namespace>

# Recreate from chart
helm template --values values.yaml \
  -s templates/geonode/jobs/geonode-init-db-job.yaml \
  charts/geonode/ | kubectl apply -f -
```

---

## Troubleshooting

### Upgrade fails: pre-upgrade hooks failed

If the cleanup Job fails (e.g. RBAC misconfiguration, image pull error), it is left in the cluster. The `before-hook-creation` policy will delete and recreate it on the next upgrade attempt, so in most cases simply retrying the upgrade is sufficient.

To inspect or manually clear a stuck cleanup job:

```bash
# Describe the failed job for details
kubectl describe job geonode-geonode-cleanup -n <namespace>

# Delete it manually if needed
kubectl delete job geonode-geonode-cleanup -n <namespace>
```

### Disable the hook for a single upgrade

```bash
helm upgrade --install --namespace <namespace> \
  --values values.yaml \
  --set geonode.hooks.cleanupOnUpgrade=false \
  geonode charts/geonode
```

