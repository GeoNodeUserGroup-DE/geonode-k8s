# Upgrade Guide — Migrating to the Hardened Chart

A step-by-step runbook for upgrading an existing GeoNode-k8s release to the **hardened /
non-root** chart. Follow the steps **in order**. The dangerous part is storage: an
unprepared `helm upgrade` **deletes your old data volume**, so do not skip Steps 2 and 6.

> Conventions used below — substitute your own values:
> - `<release>` — your Helm release name (e.g. `geonode`)
> - `<ns>` — its namespace (e.g. `geonode`)
> - `<chart>` — path to the chart (e.g. `charts/geonode`)
> - `<values>` — your values file (e.g. `my-values.yaml`)

---

## What changes in this release (read first)

| Area | Before | After | Your action |
|------|--------|-------|-------------|
| **Storage** | one PVC `pvc-<release>-geonode` (sub-paths) | four PVCs: `-statics`, `-geoserver-data`, `-backup-restore`, `-data` | Steps 2 & 6 |
| **Runtime user** | root | non-root uid/gid **1000**, read-only rootfs, dropped caps | Step 7 |
| **Postgres** | root | non-root (spilo `101`/`103`); optional Kyverno policy | Step 7 |
| **Setup Jobs** | patched in place | pod template changed → **immutable**, must be deleted | Step 4 |
| **Custom settings** | `geonode-k8s-settings*.py` appended to `settings.py` | `settings_additions.py` via `settings_wrapper` on `PYTHONPATH` | Step 8 |
| **nginx** | `nginx:...` on :80 | `nginxinc/nginx-unprivileged` on :8080 (Service still :80) | none |
| **GeoServer** | root image | root by default; non-root needs a custom image | Step 9 (optional) |

⚠️ **The single most important fact:** the storage PVC is *renamed* in this release. On
`helm upgrade`, Helm sees the old name gone from the manifest and **deletes the old PVC**.
If its reclaim policy is `Delete` (the default for most dynamic provisioners), the backing
data is **erased immediately**. Step 2 prevents this.

---

## Step 0 — Prerequisites

- `kubectl` pointed at the **right cluster/context** — verify:
  ```bash
  kubectl config current-context
  ```
- The new chart checked out, dependencies built:
  ```bash
  helm dependency update <chart>
  ```
- A maintenance window: GeoNode will be down during the copy.

---

## Step 1 — Back up

Always take an independent backup before migrating.

```bash
# Database (most important — holds all users, resources, permissions)
kubectl -n <ns> exec <release>-postgres-0 -- \
  pg_dumpall -U postgres > geonode-db-$(date +%F).sql

# Note your current values / any custom settings you injected
helm -n <ns> get values <release> > geonode-values-backup.yaml
```

---

## Step 2 — Protect the old data volume (do this BEFORE upgrading)

Two independent safeguards so Helm cannot destroy the old data:

**2a. Tell Helm to keep the old PVC** (so it stays `Bound` after upgrade and the copy Job
can read it):

```bash
kubectl -n <ns> annotate pvc pvc-<release>-geonode \
  helm.sh/resource-policy=keep --overwrite
```

**2b. Belt-and-suspenders — set its PV to `Retain`** (so even an accidental PVC deletion
does not wipe the disk):

```bash
OLD_PV=$(kubectl -n <ns> get pvc pvc-<release>-geonode -o jsonpath='{.spec.volumeName}')
echo "Old PV: $OLD_PV"
kubectl patch pv "$OLD_PV" \
  -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

> If you skip Step 2, the old PVC is deleted during Step 5 and — with a `Delete` reclaim
> policy — the data is gone. There is no recovery.

---

## Step 3 — Fix known-invalid values

The chart now validates a few values at render time. Update your `<values>` before upgrading:

- **`geonode.register.email_verification`** must be `none` | `optional` | `mandatory`
  (the old boolean-style `"False"` is rejected). For "no verification" use:
  ```yaml
  geonode:
    register:
      email_verification: "none"
  ```
- **`geonode.version`** must be a real semver matching your image tag (e.g. `5.1.0`).

---

## Step 4 — Delete the immutable setup Jobs

A Job's pod template is immutable, and this release rewrites it, so the in-place patch
fails with `field is immutable`. Delete the completed one-shot Jobs — Helm recreates them:

```bash
kubectl -n <ns> delete job \
  <release>-geonode-init-db-job \
  <release>-geonode-statics-job --ignore-not-found
```

---

## Step 5 — Run the upgrade

```bash
helm upgrade --namespace <ns> --create-namespace \
  <release> <chart> -f <values>
```

After this: the four new PVCs exist and are `Bound`; the **old PVC is still `Bound`** too
(thanks to Step 2a). Pods restart on the new — currently empty — volumes.

---

## Step 6 — Copy data from the old volume into the new PVCs

The mount paths are unchanged; only the backing volume and the removal of sub-paths. Copy
each old sub-folder into the **root** of its new PVC:

| Old sub-path (in `pvc-<release>-geonode`) | New PVC |
|---|---|
| `statics/` | `pvc-<release>-geonode-statics` |
| `geoserver-data-dir/` | `pvc-<release>-geonode-geoserver-data` |
| `backup-restore/` | `pvc-<release>-geonode-backup-restore` |
| `data/` | `pvc-<release>-geonode-data` |

**6a. Stop writers** so nothing changes mid-copy:

```bash
kubectl -n <ns> scale statefulset <release>-geonode --replicas=0
kubectl -n <ns> scale statefulset <release>-geoserver --replicas=0
```

**6b. Run the copy Job.** Save as `pvc-migrate.yaml` (replace `<release>`/`<ns>`, and set
`storageClassName` only if you use one):

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: geonode-pvc-migrate
  namespace: <ns>
spec:
  backoffLimit: 0
  template:
    spec:
      restartPolicy: Never
      securityContext:
        runAsUser: 0        # copy as root to preserve permissions
        fsGroup: 1000
      containers:
      - name: copy
        image: alpine:3.20
        command: ["sh","-c"]
        args:
          - |
            set -eux
            apk add --no-cache rsync
            rsync -aH --info=progress2 /old/statics/            /new/statics/
            rsync -aH --info=progress2 /old/geoserver-data-dir/ /new/geoserver/
            rsync -aH --info=progress2 /old/backup-restore/     /new/backup/
            rsync -aH --info=progress2 /old/data/               /new/data/
            # hand ownership to the non-root runtime user (uid/gid 1000)
            chown -R 1000:1000 /new/statics /new/geoserver /new/backup /new/data
        volumeMounts:
        - { name: old,       mountPath: /old }
        - { name: statics,   mountPath: /new/statics }
        - { name: geoserver, mountPath: /new/geoserver }
        - { name: backup,    mountPath: /new/backup }
        - { name: data,      mountPath: /new/data }
      volumes:
      - name: old
        persistentVolumeClaim: { claimName: pvc-<release>-geonode }
      - name: statics
        persistentVolumeClaim: { claimName: pvc-<release>-geonode-statics }
      - name: geoserver
        persistentVolumeClaim: { claimName: pvc-<release>-geonode-geoserver-data }
      - name: backup
        persistentVolumeClaim: { claimName: pvc-<release>-geonode-backup-restore }
      - name: data
        persistentVolumeClaim: { claimName: pvc-<release>-geonode-data }
```

```bash
kubectl apply -f pvc-migrate.yaml
kubectl -n <ns> wait --for=condition=complete job/geonode-pvc-migrate --timeout=600s
kubectl -n <ns> logs job/geonode-pvc-migrate
```

> Verify the old sub-folder names first if unsure:
> `kubectl -n <ns> debug ... ` or add a `ls -la /old` line to the Job. Very old installs
> may differ (e.g. `geoserver_data` vs `geoserver-data-dir`).

**6c. Bring the apps back up:**

```bash
kubectl -n <ns> scale statefulset <release>-geonode --replicas=1
kubectl -n <ns> scale statefulset <release>-geoserver --replicas=1
```

---

## Step 7 — Filesystem ownership (non-root)

Pods now run as **uid/gid 1000** with `fsGroup: 1000`. Step 6b already `chown`ed the four
new PVCs. Two things to watch:

- **Postgres:** the DB runs non-root now (spilo `101`/`103`). A DB volume created by the
  old root pod may need `chown` or a restore from your Step 1 dump if postgres fails to
  start with permission errors on `/home/postgres/pgdata`.
- **NFS / ReadWriteMany** backends often ignore `fsGroup`; if a pod crash-loops with
  `Permission denied`, `chown -R 1000:1000` the export directly.

**Optional — full "restricted" compliance for Postgres** (the operator can't inject a
complete securityContext). Requires [Kyverno](https://kyverno.io/) installed:

```yaml
postgres:
  kyvernoSecurityContext:
    enabled: true      # leave false unless Kyverno is present in the cluster
```

---

## Step 8 — Migrate custom Django settings

The old `geonode-k8s-settings*.py` append mechanism is gone (incompatible with a read-only
rootfs). Put custom settings in **`geonode.general.settings_additions`** (a Python snippet).

⚠️ **To make them load**, you must also point Django at the wrapper — it is **not** the
default:

```yaml
geonode:
  general:
    settings_module: settings_wrapper
    settings_additions: |
      THESAURUS_DEFAULT_LANG = "de"
      # ...your overrides...
```

Without `settings_module: settings_wrapper`, the additions ConfigMap is mounted but never
executed (Sentry init, `THESAURUS_DEFAULT_LANG`, your overrides all silently ignored).
Verify:

```bash
kubectl -n <ns> exec <release>-geonode-0 -c geonode -- \
  python -c "from django.conf import settings; print(settings.THESAURUS_DEFAULT_LANG)"
```

---

## Step 9 — GeoServer non-root (optional)

The stock `geonode/geoserver` image can't run non-root, so the chart defaults it to root.
To run it non-root, build the wrapper image and override the values:

```bash
cd geoserver-nonroot
# bump GEOSERVER_VERSION in build.sh to match geoserver.image.tag first
./build.sh          # builds geonode/geoserver-nonroot:<tag>; push to your registry
```

```yaml
geoserver:
  image:
    name: geonode/geoserver-nonroot
  securityContext:
    runAsNonRoot: true
    fsGroup: 1000
    runAsUser: 1000
    runAsGroup: 1000
```

---

## Step 10 — Verify

```bash
kubectl -n <ns> get pods          # all Running; no CrashLoopBackOff / CreateContainerConfigError
kubectl -n <ns> get pvc           # four new PVCs Bound
```

Then in the browser:
- Log in (over your `externalScheme`).
- Existing datasets/maps **still render** → GeoServer data copied correctly.
- A new **file upload** completes → statics + geoserver-data + celery all healthy.

---

## Step 11 — Clean up (only after you've verified)

```bash
# remove the retained old volume and its data
kubectl -n <ns> delete pvc pvc-<release>-geonode --ignore-not-found
kubectl delete pv "$OLD_PV"        # the PV from Step 2b, now Released
kubectl -n <ns> delete job geonode-pvc-migrate
```

---

## Rollback

If something goes wrong **before Step 11**, your old data is intact (Step 2). Roll back:

```bash
helm rollback <release>
kubectl -n <ns> scale statefulset <release>-geonode --replicas=1
```

The old PVC still holds the original data. Do **not** run Step 11 until you are confident.

---

## Troubleshooting

| Symptom | Cause & fix |
|---|---|
| `field is immutable` on `*-init-db-job` / `*-statics-job` | Job template can't be patched → **Step 4** (delete the Jobs, re-upgrade). |
| `email_verification must be one of: none, optional, mandatory (got: False)` | allauth 65+ dropped booleans → **Step 3** (`email_verification: "none"`). |
| Pod `CreateContainerConfigError` / `Permission denied` on a volume | Non-root uid 1000 can't write a root-owned volume → **Step 7** (`chown`, esp. on NFS). |
| Old data missing after upgrade | Step 2 was skipped → the old PVC was deleted. Restore from the Step 1 backup. |
| Custom settings / Sentry not applied | `settings_module` still `geonode.settings` → **Step 8**. |

---

## Known chart issues (candidates to fix upstream in the PR)

- **Setup Jobs are not Helm hooks.** Converting `geonode-init-db-job` /
  `geonode-statics-job` to hooks (`helm.sh/hook: post-install,post-upgrade`,
  `hook-delete-policy: before-hook-creation`) would remove the manual Step 4 on every upgrade.
- **PVC rename has no `helm.sh/resource-policy: keep`.** Because the chart renames the
  storage PVC without a keep policy, upgrades silently delete user data unless the operator
  performs Step 2 by hand. A keep annotation (or a documented migration hook) would make
  this safe by default.
- **`settings_additions` inert by default** — see Step 8.
- **Celery `celery-cmd-temporary-fix` keeps heavy autoscale defaults** (`10,5` + `15,10`),
  which can OOMKill the celery container on uploads unless `CELERY__AUTOSCALE_VALUES` /
  `CELERY__HARVESTER_AUTOSCALE_VALUES` are lowered.

---

## Fresh install (no existing data)

None of the migration steps apply. Review `global.securityContext`, set
`geonode.persistant.*.storageSize`, decide on GeoServer non-root (Step 9), and install
normally.
