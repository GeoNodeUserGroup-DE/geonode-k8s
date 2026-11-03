docker build --build-arg GEOSERVER_UID=1000 --build-arg GEOSERVER_GID=1000 \
  --build-arg GEOSERVER_VERSION=2.28.6-latest \
  -t geonode/geoserver-nonroot:2.28.6-latest .
