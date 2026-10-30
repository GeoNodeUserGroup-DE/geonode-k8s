# Running on ARM64

`geonode-k8s` does not run on `linux/arm64` nodes with its default values, because several of the images it deploys are only published for `linux/amd64`. The [GeoNode4Arm64](https://github.com/mwallschlaeger/GeoNode4Arm64) project fills that gap: it builds the missing images and provides `geonode-k8s-arm`, an umbrella chart that wraps this chart.

## What is different on ARM64

| Component | Problem | What `geonode-k8s-arm` does |
|---|---|---|
| GeoNode, GeoServer | No upstream `linux/arm64` images | Pins the images to arm64 builds |
| GeoServer | The stock image cannot start with a read-only root filesystem | Uses the [`geoserver-nonroot`](https://github.com/GeoNodeUserGroup-DE/geonode-k8s/tree/main/geoserver-nonroot) image from this repository |
| PostgreSQL | Zalando Spilo has no arm64 build, so `postgres-operator` cannot be used | Disables the operator and deploys its own PostgreSQL + PostGIS StatefulSet, connected via `postgres.type: external` |
| pyCSW | `geopython/pycsw` has no arm64 build | Sets `pycsw.enabled=false`, so GeoNode uses its built-in `geonode-pycsw` backend |

## Install

You need an arm64 build host, Docker with buildx, a registry you can push to, Helm 3.8 or newer and a cluster with arm64 nodes. The [GeoNode4Arm64 README](https://github.com/mwallschlaeger/GeoNode4Arm64#requirements) lists the full requirements and explains how to set up the build host.

Build the images, including `geoserver-nonroot`, and push them to your registry:

```bash
git clone https://github.com/GeoNodeUserGroup-DE/geonode-k8s.git
git clone --recurse-submodules https://github.com/mwallschlaeger/GeoNode4Arm64.git
cd GeoNode4Arm64/build
cp env.local.example .env.local && chmod 600 .env.local
vi .env.local   # set REGISTRY and token
./login-registry.sh
GEONODE_K8S_SRC="$(realpath ../../geonode-k8s)" WITH_NONROOT=1 PUSH=1 ./build-all.sh
cd ..
```

Before installing, edit `charts/geonode-k8s-arm/values.yaml`. Replace the `changeme-*` passwords and, if you pushed to a different registry than the default, update the image names. Then install the chart:

```bash
helm dependency build charts/geonode-k8s-arm
helm install geonode charts/geonode-k8s-arm -n geonode --create-namespace
```

`geonode-k8s` values go under the `geonode-k8s:` key of the umbrella chart, for example `geonode-k8s.geonode.general.externalDomain`. The [chart README](https://github.com/mwallschlaeger/GeoNode4Arm64/tree/main/charts/geonode-k8s-arm) covers passwords, private images and settings for small clusters.

## Limitations

GeoNode4Arm64 has been verified with GeoNode 5.1.0 on single-node k3s. Multi-node and mixed-architecture clusters are untested. Because the PostgreSQL StatefulSet replaces `postgres-operator`, there is no HA, no connection pooling and no automatic backup.
