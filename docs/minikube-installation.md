# Installation guide for Minikube

## Install Minikube

To install minikube itself follow the instruction on https://kubernetes.io/de/docs/tasks/tools/install-minikube/

## Install chart dependencies

Download or update latest helm chart dependencies listed in /chart.yaml.

```bash
helm dependency update charts/geonode
```

## Edit Minikube values

View and edit the predefined minikube values under /minikube-values.yaml

## Run Installation

To run the installation on minikube run:

```bash
helm upgrade --cleanup-on-fail   --install --namespace geonode --create-namespace --values minikube-values.yaml geonode charts/geonode
```

You can check the installtion process with:

```bash
watch kubectl get pods,services,pvc,secrets,postgresql -n geonode

# this will give you an overview over all running pods, services, pvcs,sts and the postgresql class
NAME                                             READY   STATUS    RESTARTS      AGE
pod/geonode-geonode-0                            2/2     Running   1 (78s ago)   6m32s
pod/geonode-geoserver-0                          1/1     Running   0             6m32s
pod/geonode-memcached-0                          1/1     Running   0             6m32s
pod/geonode-nginx-b84df5d5c-2vb7m                1/1     Running   5 (31s ago)   6m32s
pod/geonode-postgres-0                           1/1     Running   0             5m11s
pod/geonode-postgres-operator-75d5bf84d8-zqcgz   1/1     Running   0             6m32s
pod/geonode-pycsw-0                              1/1     Running   0             6m32s
pod/geonode-rabbitmq-0                           1/1     Running   0             6m32s

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                 AGE
service/geonode-geonode             ClusterIP   10.103.1.134     <none>        8000/TCP,8001/TCP,5555/TCP              6m32s
service/geonode-geoserver           ClusterIP   10.110.143.116   <none>        8080/TCP                                6m32s
service/geonode-memcached           ClusterIP   10.104.83.107    <none>        11211/TCP                               6m32s
service/geonode-nginx               ClusterIP   10.99.36.115     <none>        80/TCP                                  6m32s
service/geonode-postgres            ClusterIP   10.102.16.9      <none>        5432/TCP                                5m12s
service/geonode-postgres-config     ClusterIP   None             <none>        <none>                                  5m5s
service/geonode-postgres-operator   ClusterIP   10.99.14.191     <none>        8080/TCP                                6m32s
service/geonode-postgres-repl       ClusterIP   10.103.190.145   <none>        5432/TCP                                5m12s
service/geonode-pycsw               ClusterIP   10.105.243.111   <none>        8000/TCP                                6m32s
service/geonode-rabbitmq            ClusterIP   10.111.234.134   <none>        5672/TCP,4369/TCP,25672/TCP,15672/TCP   6m32s
service/geonode-rabbitmq-headless   ClusterIP   None             <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP   6m32s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pgdata-geonode-postgres-0   Bound    pvc-a8c32d09-5b03-439b-b77d-2084de13f8dc   2Gi        RWO            standard       5m11s
persistentvolumeclaim/pvc-geonode-geonode         Bound    pvc-4b141032-08df-4712-883c-1eb2243ff496   2Gi        RWX            standard       6m32s

NAME                                                                    TYPE                 DATA   AGE
secret/geodata.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      5m12s
secret/geonode-geonode-secret                                           Opaque               11     6m32s
secret/geonode-geoserver-secret                                         Opaque               6      6m32s
secret/geonode-rabbitmq                                                 Opaque               2      6m32s
secret/geonode-rabbitmq-config                                          Opaque               1      6m32s
secret/geonode.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      5m12s
secret/postgres.geonode-postgres.credentials.postgresql.acid.zalan.do   Opaque               2      5m12s
secret/sh.helm.release.v1.geonode.v1                                    helm.sh/release.v1   1      6m32s
secret/sh.helm.release.v1.geonode.v2                                    helm.sh/release.v1   1      5m12s
secret/standby.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      5m11s

NAME                                        TEAM      VERSION   PODS   VOLUME   CPU-REQUEST   MEMORY-REQUEST   AGE     STATUS
postgresql.acid.zalan.do/geonode-postgres   geonode   15        1      2Gi                                     5m12s   Running
```

The initial start takes some time, due to init process of the django application. You can check the status via:
```bash
kubectl -n geonode logs pod/geonode-geonode-0 -f 
```

## Expose Service to outside world

This installation requires to access geonode via "geonode" (or the value in .Values.geonode.general.externalDomain) dns entry.  So, add an entry to your /etc/hosts. First of all find the related ip addr from kubernetes service like:

```bash
# list all services in geonode namespace
kubectl -n geonode get services

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                 AGE
service/geonode-geonode             ClusterIP   10.107.192.66    <none>        8000/TCP,8001/TCP                       19m
service/geonode-geoserver           ClusterIP   10.101.184.88    <none>        8080/TCP                                19m
service/geonode-memcached           ClusterIP   10.109.197.248   <none>        11211/TCP                               19m
service/geonode-nginx               ClusterIP   10.97.10.57      <none>        80/TCP                                  19m
service/geonode-postgres-operator   ClusterIP   10.108.39.88     <none>        8080/TCP                                19m
service/geonode-postgresql          ClusterIP   10.104.181.46    <none>        5432/TCP                                18m
service/geonode-postgresql-config   ClusterIP   None             <none>        <none>                                  18m
service/geonode-postgresql-repl     ClusterIP   10.100.210.207   <none>        5432/TCP                                18m
service/geonode-rabbitmq            ClusterIP   10.109.132.35    <none>        5672/TCP,4369/TCP,25672/TCP,15672/TCP   19m
service/geonode-rabbitmq-headless   ClusterIP   None             <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP   19m
```

Find the ip addr of the geonode-nginx service. and add an entry to your hosts file:

```
10.97.10.57   geonode.local
```

After that the service has to be exposed form minikube. I prefer to use minikube tunnel. Start it via, it will require root access:

```bash
minikube tunnel
```

There are several ways to expose services from minikube, find information in the minikube docs under: https://minikube.sigs.k8s.io/docs/handbook/accessing/

Now you are able to access the geonode installation by opening your browser and open http://geonode.local for geonode and http://geonode.local/geoserver for geoserver

Have Fun!
