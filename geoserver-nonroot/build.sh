docker build --build-arg GEOSERVER_UID=1000 --build-arg GEOSERVER_GID=1000 \
  --build-arg GEOSERVER_VERSION=2.27.4-latest \
  -t geonode/geoserver-nonroot:2.27.4-latest .
