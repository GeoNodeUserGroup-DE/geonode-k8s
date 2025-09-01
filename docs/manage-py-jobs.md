Manage.py Jobs for GeoNode
--------------------------
This document describes the Kubernetes Job configurations for managing GeoNode tasks such as migrations, static files collection, and fixture loading. These jobs are essential for maintaining and updating your GeoNode instance. With geonode-k8s 1.30.0 and later, these jobs are included by default in the Helm chart.

This jobs are defined in the following files (invoke tasks):
- `charts/geonode/templates/geonode/jobs/geonode-init-db-job.yaml`
  - run migrations (waitfordbs, migration)
  - insert fixtures (prepare, fixtures)
  - create geoserver store via geserver rest (waitforgeoserver, geoserverfixture)
  - updates geonode admin user password (updateadmin)
- `charts/geonode/templates/geonode/jobs/geonode-statics-job.yaml`
  - build statics (initialized, statics)

Each job is configured to run specific management commands using the `invoke` tool, which is a task execution tool used in GeoNode for various administrative tasks.
This jobs are usually executed automatically during the deployment process, but they can also be run manually if needed. To rerun one of these jobs manually, you have to delete the existing job and create a new one. For example, to rerun the init-db-job job, you can use the following commands:
```
# list all jobs
kubectl get Jobs

# delete the init-db job
kubectl delete job geonode-geonode-init-db-job

# recreate job
helm template --values values.yaml -s templates/geonode/jobs/-init-db-job.yaml  charts/geonode/ | kubectl apply -f -
```

Rerunning a job could be necessary, when updating geonode version.