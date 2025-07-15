#!/bin/bash

# Namespace (change if needed)
NAMESPACE=geonode

# Get the ClusterIP of the geonode-nginx service
IP=$(kubectl get svc geonode-nginx -n $NAMESPACE -o jsonpath='{.spec.clusterIP}')

if [[ -z "$IP" ]]; then
    echo "Failed to get IP for service geonode-nginx"
    exit 1
fi

HOSTS_LINE="$IP geonode.local"
HOSTS_FILE="/etc/hosts"

# Update or add entry
if grep -q "geonode.local" "$HOSTS_FILE"; then
    echo "Updating existing geonode.local entry..."
    sudo sed -i.bak "/geonode.local/c\\$HOSTS_LINE" "$HOSTS_FILE"
else
    echo "Adding new geonode.local entry..."
    echo "$HOSTS_LINE" | sudo tee -a "$HOSTS_FILE" > /dev/null
fi

echo "Updated /etc/hosts:"
grep "geonode.local" "$HOSTS_FILE"