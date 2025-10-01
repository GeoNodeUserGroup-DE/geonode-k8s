
![Version: 1.2.6](https://img.shields.io/badge/Version-1.2.6-informational?style=flat-square)

# Helm Chart for Geonode

- [GeoWhat?](#Geonode)
- [Geonode-k8s](#geonode-k8s)
- [Install Guilde](#install)

**Homepage:** <https://github.com/GeoNodeUserGroup-DE/geonode-k8s>

Geonode
-------

Geonode is a geospatial content management system, a platform for the management and publication of geospatial data. It brings together mature
and stable open-source software projects under a consistent and easy-to-use interface allowing non-specialized users to share data and
create interactive maps.

You can find the Sourcecode and more information about geonode under:
- Homepage: https://geonode.org/
- Github: https://github.com/GeoNode/geonode
- Docs: https://docs.geonode.org

Due to growing needs for high availability and scalability this repository aims at running Geonode with all required services in a cloud based manner. To due so we use Kubernetes (https://kubernetes.io/), a cloud management software, which runs on public and private clouds. As the Kubernetes echosystem can be confusing for people getting new to this field, there are packages for most services which are able to run on top of kubernetes. This packages are managed via helm (https://helm.sh/).

Geonode-k8s
-----------

This repository provides a helm chart for **geonode** including additional services as:
- geoserver: source server for sharing geospatial data  (https://geoserver.org/)
- rabbitmq: message broker (scalable)
- postgresql database: using zalando postgres-operator for distributed database for geonode and postgis db for geoserver (https://github.com/zalando/postgres-operator) (scalable)
- memcached (optional): as django cache (scalable)
- nginx: webserver to deliver static content (scalable)
- pycsw: CSW interface (scalable)
This helm chart provides the possibility to run most of the services redundant to increase performance on the one hand and increase fail safe on the other hand.

## Documentation


To get an overview of the available configuration check out the values [docs](charts/geonode/README.md). If you want to run the helm chart first on a minikube cluster check out the [minikube](docs/minikube-installation.md) guide. Also check the minikube-values.yaml for basic configuration. 

If you want to go straight for a production installation follow the [installation](#install) guide.

Furhter docs you can find on [readthedocs](https://geonode-k8s.readthedocs.io/en/latest/).

Install
-------

## Prerequisites

* A Kubernetes cluster (or [minikube](docs/minikube-installation.md))
* [Helm](https://helm.sh/)

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

## Install chart
```bash
helm upgrade --cleanup-on-fail   --install --namespace geonode --create-namespace --values my-values.yaml geonode charts/geonode
```

## Delete Installation
```bash
helm delete --namespace geonode geonode geonode
```

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
