HTTPS Ingress
-------------

To enable https for the given configuration: geonode.general.externalDomain in values.yaml. Set the externalScheme to "https" and define a secret which has to be
in the same namespace as the geonode installation.

```
geonode.general.externalScheme: https
geonode.ingress.tlsSecret: geonode-tls-secret
```

After configuring the ingress. The secret can be created via. It requires a cert.key and a cert.pem file. Find Kubernetes docs under (https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/)

```bash
kubectl create secret --namespace geonode tls geonode-tls-secret --key="cert.key" --cert="cert.pem"
```

## Login over plain HTTP (Secure cookies)

Starting with **GeoNode 5.1.0**, the upstream defaults of `SESSION_COOKIE_SECURE`
and `CSRF_COOKIE_SECURE` changed from `False` to `True` (in 5.0.x they were `False`).
With Secure cookies enabled, GeoNode sends the `sessionid` / `csrftoken` cookies with
the `Secure` flag, and browsers **only** accept those over HTTPS.

If you serve GeoNode over plain HTTP (`geonode.general.externalScheme: http`, e.g. the
minikube dev deployment), login silently fails: after submitting credentials you are
redirected back to the landing page still logged out, and the browser console shows:

> Cookie "sessionid" has been rejected because a non-HTTPS cookie can't be set as "secure".

The chart exposes this via `geonode.general.cookie_secure`, which drives both the
`SESSION_COOKIE_SECURE` and `CSRF_COOKIE_SECURE` env vars. When left unset it follows
`externalScheme` automatically (`https` => `True`, `http` => `False`), so an HTTP-only
deployment works out of the box:

```yaml
geonode:
  general:
    externalScheme: http
    cookie_secure:        # unset => follows externalScheme (http => Secure cookies off)
```

Set it explicitly to `true`/`false` to override the automatic behaviour. When serving
over HTTPS the derived value is already `True`; keep it that way for production.