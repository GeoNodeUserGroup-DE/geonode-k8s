![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square)

# Helm Chart for Geonode

- [GeoWhat?](#Geonode)
- [Geonode-k8s](#geonode-k8s)
- [Install Guide](#install)

**Homepage:** <https://github.com/GeoNodeUserGroup-DE/geonode-k8s>

## Geonode

GeoNode is a geospatial content management system, a platform for the management and publication of geospatial data. It brings together mature
and stable open-source software projects under a consistent and easy-to-use interface allowing non-specialized users to share data and
create interactive maps.

You can find the Sourcecode and more information about geonode under:

- Homepage: https://geonode.org/
- Github: https://github.com/GeoNode/geonode
- Docs: https://docs.geonode.org

Due to growing needs for high availability and scalability this repository aims at running GeoNode with all required services in a cloud based manner. To do so, we use Kubernetes (https://kubernetes.io/), a cloud management software, which runs on public and private clouds. As the Kubernetes ecosystem can be confusing for people getting new to this field, there are packages for most services which are able to run on top of Kubernetes. These packages are managed via helm (https://helm.sh/).

## Geonode-k8s

This repository provides a helm chart for **geonode** including additional services as:

- geoserver: source server for sharing geospatial data (https://geoserver.org/)
- rabbitmq: message broker (scalable)
- postgresql database: using zalando postgres-operator for distributed database for geonode and postgis db for geoserver (https://github.com/zalando/postgres-operator) (scalable)
- memcached (optional): as django cache (scalable)
- nginx: webserver to deliver static content (scalable)
- pycsw: CSW interface (scalable)

This helm chart provides the possibility to run most of the services redundant to increase performance on the one hand and increase fail safe on the other hand.

## Documentation

To get an overview of the available configuration check out the values [docs](charts/geonode/README.md). If you want to run the helm chart first on a minikube cluster check out the [minikube](docs/minikube-installation.md) guide. Also check the minikube-values.yaml for basic configuration.

If you want to go straight for a production installation follow the [installation](#install) guide.

Further docs you can find on [readthedocs](https://geonode-k8s.readthedocs.io/en/latest/).

## Install

## Prerequisites

- A Kubernetes cluster (or [minikube](docs/minikube-installation.md))
- [Helm](https://helm.sh/)

The chart will automatically install required dependencies, i.e. a RabbitMQ broker and a Postgres database with `postgis` extensions installed, and link them up. If you want to run an older geonode version with geonode-k8s check the [release-to-version list](docs/list-of-releases-and-versions.md).

## Install chart dependencies

Update helm dependencies via:

```bash
helm repo add geonode https://GeoNodeUserGroup-DE.github.io/geonode-k8s/
helm repo update
```

## Override desired values in your own override file

Define your own values.yaml to configure your geonode installation. Use the [docs](charts/geonode/README.md) to understand the parameters.

```bash
vi my-values.yaml
```

## Hardened K8S environments

By default, this Helm Chart is intended to run in hardened K8S environments, notably with non-root permissions. To use it, ensure that your storage will be writeable by the geonode technical user; UID and GID can be configured in the values file.

There are two exceptions to this rule:
- the `geonode-postgres` Pod does not have full securityContext out-of-the-box, because the subchart `postgres-operator` does not support that yet. A workaround is available if you want the full securityContext, for that, set `postgres.kyvernoSecurityContext` to `enabled` in your values YAML.
- the `geonode/geoserver` Pod, because the current `geonode/geoserver` Docker Image does not support running as non-root out-of-the-box, therefore, default chart settings for this image are set to run as root. If you wish to run this Pod as non-root, proceed as follows:

Create a custom image with the provided script:
```bash
cd geoserver-nonroot
./build.sh
```
And then override the settings in your values file, for example:
```bash
geoserver:
  image:
    name: geonode/geoserver-nonroot
  securityContext:
    runAsNonRoot: true
    fsGroup: 1000
    runAsUser: 1000
    runAsGroup: 1000
```

## Install chart

```bash
helm upgrade --cleanup-on-fail --install --namespace geonode --create-namespace --values my-values.yaml geonode charts/geonode
```

## Delete Installation

```bash
helm delete --namespace geonode geonode
```

## Migrating from earlier versions of this Helm Chart

The `2.0.x` (hardened / non-root) release introduces breaking changes — most notably a
split from one common PVC into four distinct PVCs, and non-root runtime permissions. A
plain `helm upgrade` will **delete the old data volume**, so follow the step-by-step
runbook before upgrading:

**➡️ [Upgrade Guide — Migrating to Chart 2.0.x](docs/upgrade-to-2.0.x.md)**

## Contribution

### Create an Issue

You found a bug :lady_beetle:?
You have an idea how to improve :bulb:?
Feel free to [create an issue](https://github.com/GeoNodeUserGroup-DE/geonode-k8s/issues/new/choose)!

### Documentation

Ensure values.yaml documentation is up-to-date.
The [parameter documentation](charts/geonode/README.md) is generated via [`helm-docs`](https://github.com/norwoodj/helm-docs).
There is a pre-commit hook configuration so please ensure you install it into your local working copy via

```
pre-commit install
pre-commit install-hooks
```
