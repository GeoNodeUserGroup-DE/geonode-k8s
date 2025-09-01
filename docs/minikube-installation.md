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
NAME                                             READY   STATUS      RESTARTS       AGE
pod/geonode-geonode-0                            2/2     Running     0              5m19s
pod/geonode-geonode-init-db-job-dqdhl            0/1     Completed   0              5m19s
pod/geonode-geonode-statics-job-9lpmk            0/1     Completed   0              5m19s
pod/geonode-geoserver-0                          1/1     Running     0              5m19s
pod/geonode-memcached-0                          1/1     Running     0              5m19s
pod/geonode-nginx-575d4fbc8f-pkj4b               1/1     Running     1 (4m8s ago)   5m19s
pod/geonode-postgres-0                           1/1     Running     0              5m10s
pod/geonode-postgres-operator-75d5bf84d8-clfkf   1/1     Running     0              5m19s
pod/geonode-pycsw-0                              1/1     Running     0              5m19s
pod/geonode-rabbitmq-0                           1/1     Running     0              5m19s

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                 AGE
service/geonode-geonode             ClusterIP   10.108.139.157   <none>        8000/TCP,8001/TCP,5555/TCP              5m19s
service/geonode-geoserver           ClusterIP   10.109.74.49     <none>        8080/TCP                                5m19s
service/geonode-memcached           ClusterIP   10.98.114.227    <none>        11211/TCP                               5m19s
service/geonode-nginx               ClusterIP   10.110.152.86    <none>        80/TCP                                  5m19s
service/geonode-postgres            ClusterIP   10.108.247.27    <none>        5432/TCP                                5m12s
service/geonode-postgres-config     ClusterIP   None             <none>        <none>                                  5m2s
service/geonode-postgres-operator   ClusterIP   10.102.184.20    <none>        8080/TCP                                5m19s
service/geonode-postgres-repl       ClusterIP   10.108.255.29    <none>        5432/TCP                                5m11s
service/geonode-pycsw               ClusterIP   10.101.67.39     <none>        8000/TCP                                5m19s
service/geonode-rabbitmq            ClusterIP   10.110.248.230   <none>        5672/TCP,4369/TCP,25672/TCP,15672/TCP   5m19s
service/geonode-rabbitmq-headless   ClusterIP   None             <none>        4369/TCP,5672/TCP,25672/TCP,15672/TCP   5m19s

NAME                                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pgdata-geonode-postgres-0   Bound    pvc-3f7a8ad8-83b5-410a-8b47-6778d97b2b98   2Gi        RWO            standard       5m10s
persistentvolumeclaim/pvc-geonode-geonode         Bound    pvc-264fdd95-beb6-416a-a7b3-a98834e461bf   2Gi        RWX            standard       5m19s

NAME                                                                    TYPE                 DATA   AGE
secret/geodata.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      53d
secret/geonode-geonode-secret                                           Opaque               12     5m19s
secret/geonode-geoserver-secret                                         Opaque               6      5m19s
secret/geonode-rabbitmq                                                 Opaque               2      5m19s
secret/geonode-rabbitmq-config                                          Opaque               1      5m19s
secret/geonode.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      53d
secret/postgres.geonode-postgres.credentials.postgresql.acid.zalan.do   Opaque               2      53d
secret/sh.helm.release.v1.geonode.v1                                    helm.sh/release.v1   1      5m19s
secret/standby.geonode-postgres.credentials.postgresql.acid.zalan.do    Opaque               2      53d

NAME                                        TEAM      VERSION   PODS   VOLUME   CPU-REQUEST   MEMORY-REQUEST   AGE     STATUS
postgresql.acid.zalan.do/geonode-postgres   geonode   15        1      2Gi      100m          0.5Gi            5m19s   Running
```

The initial start takes some time, due to init process of the django application. You can check the status via:
```bash
kubectl -n geonode logs pod/geonode-geonode-0 -f 
```
Furhter check that the `geonode-geonode-init-db-job` jobs is finished as this is setting the admin user password.

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
